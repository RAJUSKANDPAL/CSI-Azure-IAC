![](https://github.com/RAJUSKANDPAL/CSI-Azure-IAC/blob/e1dfe6da4509421cd576a1edb37a9d60afec213a/celabal.jpeg)
# 🚀 Automated Web Hosting Solution with Single-Click Replication  
- Rajus Kandpal (Cloud Infra Security Batch 2)    

This project demonstrates a dynamic and scalable **Infrastructure as Code (IaC)** solution using **Terraform** and **Node.js**, enabling single-click deployments of web-hosting environments (Development, UACT, Production) on **Microsoft Azure**.  
Deployment ![View Live Deployment](https://csi-azure-iac.vercel.app/)  

---

## 📌 Features

- 🌐 Deploys 2 Azure Virtual Machines behind a Load Balancer
- 🧑‍💻 Website hosted automatically using `cloud-init`
- ☁️ Dynamic environment support: `Development`, `UACT`, `Production`
- 📩 HTML form to collect deployment inputs
- ⚙️ Node.js backend to trigger Terraform with parameters
- 🔁 Future-ready for CI/CD, secrets management, cost optimization, and logging

---

## 📁 Project Structure

auto-deployer/    
├── public/    
│ └── index.html  
├── terraform/    
│ ├── main.tf  
│ ├── variables.tf  
│ ├── dev.tfvars  
│ ├── uact.tfvars  
│ └── prod.tfvars  
├── server.js    
├── package.json  
└── README.md    

---

## ⚙️ Prerequisites

- Node.js and npm installed
- Terraform installed
- Azure Subscription with:
  - Service Principal (or logged-in via `az login`)
  - SSH key pair
- Basic knowledge of Azure networking & resources

``

# Configure Terraform Files

Edit the terraform/variables.tf and each .tfvars file to match your:

Azure Region

Environment name

VM size, etc.

Also ensure your provider block includes your credentials.  

### How to Clone the Repository

```bash
git clone https://github.com/RAJUSKANDPAL/CSI-Azure-IAC.git
cd CSI-Azure-IAC   
# 2. Install Dependencies  
```
npm install
``

# 🚀 How to Deploy  
- Ensure you have Node.js installed.   
- Navigate to the project directory:
  ``` cd "envs and web app"```
- Install dependencies:
  ```npm install```
- Start the server:
  ``` node server.js```
- After deployment, get the public IP address of your VM or hosting environment.

---  
# IMPORTANT NOTICE  
After deployment, please wait for 1 minute before accessing the application.    

When copying the IP address URL, make sure to:  

Remove the s from https, so it becomes http  

Example: change https://<your-ip> to http://<your-ip>  

This ensures successful connection to the backend service running on the VM.  


# Output Screens  
**Screen One**     

![](https://github.com/RAJUSKANDPAL/CSI-Azure-IAC/blob/f8b2c7b20aee628ba95d206df697bd4620fda269/sc1.png)  

**Screen Two Step Two - Choose Deployment Region and the Environment**    

![](https://github.com/RAJUSKANDPAL/CSI-Azure-IAC/blob/f8b2c7b20aee628ba95d206df697bd4620fda269/sc2.png)  

**Screen Three**  

![](https://github.com/RAJUSKANDPAL/CSI-Azure-IAC/blob/f8b2c7b20aee628ba95d206df697bd4620fda269/op0.png )  

**Screen Four - Loaad Balancer OP**    

![](https://github.com/RAJUSKANDPAL/CSI-Azure-IAC/blob/f8b2c7b20aee628ba95d206df697bd4620fda269/oplb.png)  

**Screen Five - VM 0 OP**    

![](https://github.com/RAJUSKANDPAL/CSI-Azure-IAC/blob/f8b2c7b20aee628ba95d206df697bd4620fda269/opvm0.png)  

**Screen Six - VM 1 OP**  

![](https://github.com/RAJUSKANDPAL/CSI-Azure-IAC/blob/f8b2c7b20aee628ba95d206df697bd4620fda269/opvm1.png)  

**Screen Seven - Azure Portal**  

![](https://github.com/RAJUSKANDPAL/CSI-Azure-IAC/blob/f8b2c7b20aee628ba95d206df697bd4620fda269/az%20prtl.png)  
