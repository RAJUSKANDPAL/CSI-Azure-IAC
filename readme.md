# 🚀 Automated Web Hosting Solution with Single-Click Replication

This project demonstrates a dynamic and scalable **Infrastructure as Code (IaC)** solution using **Terraform** and **Node.js**, enabling single-click deployments of web-hosting environments (Development, UACT, Production) on **Microsoft Azure**.

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
├── public/ # Frontend HTML + CSS  
│ └── index.html  
├── terraform/ # Terraform infrastructure files  
│ ├── main.tf
│ ├── variables.tf
│ ├── dev.tfvars
│ ├── uact.tfvars
│ └── prod.tfvars
├── server.js # Express backend to handle deployment
├── package.json
└── README.md # This file

---

## ⚙️ Prerequisites

- Node.js and npm installed
- Terraform installed
- Azure Subscription with:
  - Service Principal (or logged-in via `az login`)
  - SSH key pair
- Basic knowledge of Azure networking & resources

---

## 🚦 Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/auto-deployer.git
cd auto-deployer
# 2. Install Dependencies
```

npm install
``

# Configure Terraform Files

Edit the terraform/variables.tf and each .tfvars file to match your:

Azure Region

Environment name

VM size, etc.

Also ensure your provider block includes your credentials.
