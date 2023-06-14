terraform{
    required_providers{
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.16"
        }
    }
    required_version = ">= 1.2.0"
}

provider "aws" {
    region = "us-west-2"
}

resource "aws_security_group" "minecraftFinal"{
    name = "minecraft-final-group"
    description = "Final Minecraft Server SG"

    ingress{
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress{
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "minecraft" {
    ami = "ami-03f65b8614a860c29"
    instance_type = "t2.small"
    key_name = "minecraft-final"
    vpc_security_group_ids = [aws_security_group.minecraftFinal.id]  
   
   
    tags = {
        name = "minecraft-server-final"
    }
}


output "public_ip"{
    value = aws_instance.minecraft.public_ip
}

output "instance_id"{
    value = aws_instance.minecraft.id
}
