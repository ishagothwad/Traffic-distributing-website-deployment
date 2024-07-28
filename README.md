# Traffic-distributing-website-deployment
This Terraform project sets up a highly available web application on AWS. The infrastructure includes a VPC, subnets, an internet gateway, route tables, security groups, EC2 instances, an Application Load Balancer (ALB), and an S3 bucket.

## Architecture Overview
![S3pro](https://github.com/user-attachments/assets/afa71f99-38e1-4df5-baf7-cba8b3605788)

## Components

- 🌐 **VPC**: A Virtual Private Cloud with two subnets in different availability zones.
- 🌍 **Internet Gateway**: Enables internet connectivity for the VPC.
- 🛣️ **Route Tables**: Direct traffic to the internet gateway.
- 🔒 **Security Group**: Controls inbound and outbound traffic for the EC2 instances and ALB.
- 🖥️ **EC2 Instances**: Two instances initialized with user data scripts, placed in different subnets.
- ⚖️ **Application Load Balancer (ALB)**: Distributes incoming traffic across the EC2 instances.
- 📦 **S3 Bucket**: Storage for various application data.

## Prerequisites

- Terraform installed on your local machine.
- AWS CLI configured with appropriate permissions.
- AWS credentials configured.

## Getting Started

### Clone the Repository

```sh
git clone https://github.com/ishagothwad/Traffic-distributing-website-deployment
cd Traffic-distributing-website-deployment
```


### Initialize Terraform

Initialize the Terraform working directory:

```sh
terraform init
```

### Plan the Deployment

Generate and show an execution plan:

```sh
terraform plan
```

### Apply the Deployment

Apply the changes required to reach the desired state of the configuration:

```sh
terraform apply
```

### Output

After applying, Terraform will output the DNS name of the load balancer:

```sh
Outputs:

loadbalancerdns = "your-alb-dns-name"
```

Use this DNS name to access your web application.

## File Structure

- **main.tf**: Contains the main Terraform configuration.
- **variables.tf**: Defines variables used in the configuration.
- **userdata.sh**: Initialization script for the first EC2 instance.
- **userdata1.sh**: Initialization script for the second EC2 instance.
- **README.md**: This readme file.
- **.gitignore**: Specifies files to be ignored by git.

## Clean Up

To destroy the infrastructure created by Terraform:

```sh
terraform destroy
```

