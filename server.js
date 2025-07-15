const express = require('express');
const bodyParser = require('body-parser');
const { exec, spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = 3000;

app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static('public'));

app.post('/submit-deployment', (req, res) => {
  const { environment, region } = req.body;

  // Validate inputs
  if (!environment || !region) {
    return res.status(400).json({
      success: false,
      error: 'Environment and region are required'
    });
  }

  const tfvarsPath = path.join(__dirname, 'terraform', 'env', `${environment}.tfvars`);

  // Ensure tfvars exists or create it with location and environment override
  fs.writeFileSync(
    tfvarsPath,
    `location = "${region}"
environment = "${environment}"
`,
    'utf-8'
  );

  // Live logs for terraform apply
  const terraformInit = spawn('terraform', ['init', '-input=false'], {
    cwd: path.join(__dirname, 'terraform'),
    shell: true
  });

  terraformInit.stdout.on('data', (data) => {
    process.stdout.write(`[terraform init] ${data}`);
  });
  terraformInit.stderr.on('data', (data) => {
    process.stderr.write(`[terraform init] ${data}`);
  });

  terraformInit.on('close', (code) => {
    if (code !== 0) {
      return res.status(500).json({
        success: false,
        error: `Terraform init failed with code ${code}`
      });
    }

    const terraformApply = spawn('terraform', [
      'apply',
      '-auto-approve',
      `-var-file=env/${environment}.tfvars`
    ], {
      cwd: path.join(__dirname, 'terraform'),
      shell: true
    });

    terraformApply.stdout.on('data', (data) => {
      process.stdout.write(`[terraform apply] ${data}`);
    });
    terraformApply.stderr.on('data', (data) => {
      process.stderr.write(`[terraform apply] ${data}`);
    });

    terraformApply.on('close', (applyCode) => {
      if (applyCode !== 0) {
        return res.status(500).json({
          success: false,
          error: `Terraform apply failed with code ${applyCode}`
        });
      }

      exec(`cd terraform && terraform output -json`, (err, output) => {
        if (err) {
          console.error('Terraform Output Error:', err.message);
          return res.status(500).json({
            success: false,
            error: 'Deployment completed, but unable to fetch outputs'
          });
        }

        try {
          const tfOutput = JSON.parse(output);

          const vm1Ip = tfOutput?.vm1_public_ip?.value || 'Not Available';
          const vm2Ip = tfOutput?.vm2_public_ip?.value || 'Not Available';
          const lbIp = tfOutput?.lb_public_ip?.value || 'Not Available';

          res.json({
            success: true,
            data: {
              environment,
              region,
              loadBalancerIp: lbIp,
              vm1Ip,
              vm2Ip
            }
          });
        } catch (parseError) {
          console.error('Error parsing Terraform output JSON:', parseError.message);
          return res.status(500).json({
            success: false,
            error: 'Failed to parse Terraform output JSON'
          });
        }
      });
    });
  });
});

// Global error handler (must be after all other app.use/app.post)
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({
    success: false,
    error: 'Internal server error'
  });
});

const server = app.listen(PORT, () => {
  console.log(`🚀 Server running at http://localhost:${PORT}`);
});
server.setTimeout(900000); 