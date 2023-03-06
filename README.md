# Terraform_ALB_TG

On this Main.tf I've configured for the Application LB and Target Group 

-> VPC I've used the default (existing_vpc)

-> Subnets-1 scripted using Terraform (Name = "Terraform-Owned-VPC")

-> Subnet-2 Reusing Subnet into terraform to attach ALB (Name = "Main-2")

-> Subnet-3 Reusing Subnet into terraform to attach ALB (Name = "Main-1")

-> Target Group 
           Created Manually on AWS Console and Imported to the terraform using: 
           Run Command on Terminal after creating resource "aws_lb_target_group" with the same name of TG it will create a diffrent arn with (Manually created)same configuration
           ->> terraform import aws_lb_target_group.<Name of the Target Group> <arn:aws Target Group>
           Now Taget Group is manged by Terraform Sucessfully, able to make any changes using Terraform script
           
-> ALB 
           Created Manually on AWS Console and Imported to the terraform using: 
           Run Command on Terminal after creating resource "aws_lb" with the same name of ALB, but it will create a diffrent arn with (Manually created)same configuration
           ->> terraform import aws_lb.<Name of the ALB> <arn:aws ALB>
           Now ALB is manged by Terraform Sucessfully, able to make any changes using Terraform script
           
-> ALB Listener
           Created Manually on AWS Console and Imported to the terraform using: 
           Run Command on Terminal after creating resource "aws_alb_listener" with the same name of ALB
           ->> terraform import aws_alb_listener.<Name of the listerner> <arn:aws Listener>
           Now ALB Listener is manged by Terraform Sucessfully, able to make any changes using Terraform script
           
-> EC2 Instance Reusing Instance to attach target groups. 


NOTE:

Terraform plan --> Best to check the before applying the changes peer review.

Terraform apply --> Changes will be appiled.

Terraform destory --> On the Testing process I've Iomported the Subnets to the Terraform Script. For the changes when I appy
                      Terraform destroy subnet and Vpc Id changes has been noticed and agian have to add the new ID's in Terraform Script. 
