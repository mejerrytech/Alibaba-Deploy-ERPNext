# ERPNext Deployment on Alibaba Cloud ECS Using Terraform

## 🧾 What is ERPNext?

[ERPNext](https://erpnext.com) is a modern, open-source ERP system for small and medium-sized businesses. It includes modules for accounting, CRM, inventory, HR, projects, and more.

---

## 🔧 What is Terraform?

Terraform is an open-source infrastructure as code tool that allows you to define and provision cloud resources declaratively using `.tf` files.

---

## 🧱 What Does This Project Do?

This project uses Terraform to:

- Provision an **ECS (Elastic Compute Service)** instance on **Alibaba Cloud**
- Configure security groups, VPC, and other infrastructure
- Automatically run an **ERPNext deployment script** (`erpnext_install.sh`) on the ECS instance after provisioning

---

## 🚀 Setup & Deployment

### 1. Clone the Repository


git clone https://github.com/your-org/Alibaba-Deploy-ERPNext.git
cd Alibaba-Deploy-ERPNext

---
---
### 2. Initialize Terraform

terraform init


### 3. Plan Infrastructure


terraform plan


### 4. Apply Infrastructure                     

terraform apply




### 5. Outputs

Terraform will show:

 ECS Public IP Address

ERPNext Web Interface URL: http://<ecs-public-ip>:8000
