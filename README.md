# Terraform-Azure-VM

A simple project on Terraform to create Azure Virtual Machine with Docker installed.

## Pre-requisite

1. Ensure Azure CLI is installed & Logged in
2. Have Terraform installed

## Installation

1. Clone the repository
``` bash
git clone https://github.com/czhaoyiii/Terraform-Azure-VM
```

2. Navigate to the Project Directory
``` bash
cd Terraform-Azure-VM
```

## Usage

1. Initialise Terraform
``` bash
terraform init
```

2. Create an execution plan
``` bash
terraform plan
```

3. Execute the action proposed in terraform plan
``` bash
terraform apply -auto-approve
```

4. See your virtual machine be created and check if docker is installed
``` bash
docker --version
```

5. Delete the resources that you've created
``` bash
terraform destroy
```

## Takeaway
- Develop a strong understanding of writing basic HCL scripts by leveraging comprehensive documentation and examples provided.
- Gain insights into the use of template files, which are essentially shell scripts, to automate the installation and configuration of software on your virtual machine.
- Experience the practical benefits of using Terraform for IaC, demonstrating how a simple script can automate the deployment of infrastructure on Azure.
