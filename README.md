# How to make a Minecraft server using Terraform
This `README` will give step by step instructions on how to create a Minecraft server using Terraform to create EC2 instances on AWS. This will not go over how to set up the scripts needed to perform this action as they can be seen in the `minecraft.tf` file prodived in this repo.
This will be broken up into three sections:

* Installing and setting up needed tools
* Creating EC2 Instance With Terraform
* Creating Minecraft Server
* Adding Restart Functionallity to Server

Resources used can be found at the bottom of the readme.

## Section 1: Installing and Setting Up Tools
This section will go over the installation and needed tools required to get started.
### Step 1: Install Terraform 
Follow the following link and install the Terraform CLI, following the directions for your system.
Terraform: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
### Step 2: Install AWS CLI
Inorder to be able to create an EC2 instance with Terraform you will need have AWS CLI installed so Terraform can access your credentials so it can create AWS EC2 Instances. Follow the tutorial with the following link:
AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
### Step 3: Setting AWS Credentials
In order to create an EC2 instance with Terraform we will need AWS credentials. The following are two ways to find your credentials:
#### AWS Learner Lab
If you have access to an AWS learner lab perform the following:
1. Start your learner lab
2. Click on AWS Details
3. Click `Show` next to AWS CLI.

#### AWS Management Console
If you have access to an AWS Management Console perform the following
1. Log in as an IAM user
2. Click on your user and then select `My Security Credentials`
3. Select `create access key` in the Access keys for CLI, SDK, and API access

#### Setting AWS credentials and config
Now that you have access to AWS CLI credentials, you now want to store them on to your machine so Terraform can access them.
To do this perform the following: 
1. Go to `~/.aws/` or `<userhere>/.aws/`
2. Create a file called `credentials`
3. Copy and paste your AWS CLI credentials into this file
4. Open your terminal and type `aws configure`. Your AWS Access Key and Secret Access Key should look like this: 
    `example [**************************THIS]`
This means that your credentials have been auto filled. 
5. Next fill in your region name for the region you are connecting to. You can leave default output format blank.

You have now configured your credentials and config with AWS and are now ready to create and instance with Terraform

## Section 2: Creating the EC2 Instance with Terraform

This section will go over how to create the EC2 instance for the Minecraft server using Terraform. If you want to know about the scripts used to create the server please look at `minecraft.tf`. 

### Step 1: Terraform Init and Apply
Download or clone the repository to a folder on your computer and perform `terraform init`. This will cause terraform to download all of the providers that it needs inorder to create the EC2 instance. 
### Step 2: Create an ssh key
Next is to create an ssh key so you can connect to the instance. Run the following command using AWS CLI in order to get your ssh key:
`aws ec2 create-key-pair --key-name "PUT NAME HERE" --query 'KeyMaterial' --output text >  "PUT NAME HERE".pem`
This line will create a .pem file with the key needed to access your EC2 instance. Replace `PUT NAME HERE` with the name you want to name your key. Once this is created go to the `minecraft.tf` file and put the name of your key into the `key_name = ""` portion of the `aws_instance` block. This will allow the instance that is created to use the key you created.
### Step 3: Terraform Apply
Next you want to run `terraform apply`. This will build and create the EC2 instance as it is layed out in `minecraft.tf`. After a few seconds you will be prompted by the console. Type `yes` and wait a few more seconds. Your EC2 instance is now created and ready to be sshed into. Take note of the outputed outputs at the end of `terraform apply`. These will allow for the connection to the server as well as restarting and starting the server from AWS CLI.

## Section 3: Creating the Minecraft Server      
This section will go over how to create the Minecraft server once the EC2 instance is running.

### Step 1: Connect to the server
To connect to the instance run the following:
`ssh -i "KEY NAME HERE" ubuntu@public_ip`
* `KEY NAME HERE` is the key you created to access the server
* `public_ip` is the public ip for the EC2 instance. This can be found at the end of the `terraform apply` output or by running `terraform refresh`

When prompted after sshing to the server, type yes and you will be connected to the EC2 instance.

### Step 2: Update, Upgrade, and Install Java
Once connected run the following commands ot update and upgrade system packages:
* sudo apt update
* sudo apt upgrade 

Once this has been done run the following command:
* `sudo apt install openjdk-17-jdk` 

This will install java onto the server. 

### Step 3: Download, Run , and Connect to the -Minecraft Server

### Download Server.jar
Go to this link: https://www.minecraft.net/en-us/download/server and copy the url to the server download.
Then run the command `wget {minecraft server download url}` to download the server.

### Running the Server
Then run the following command `java -Xmx1024M -Xms1024M -jar server.jar nogui`
This will run the server for the first time but then will exit with an error. This is normal. In order to fix this error the eula must be updated. To do this open eula.txt in vim using `vim eula.txt` and change `eula=true`.
Run `java -Xmx1024M -Xms1024M -jar server.jar nogui` a second time and the server will start up. After a few minutes the server will have generated the spawn area of the world and players can now connect

### Connecting to the server
This version of the Minecraft server is running the latest version of the game, version 1.20.1. To connect to the server launch the game in this version. This version will be the default option when starting the game. If it is not then follow this tutorial made by the Minecraft developers on how to change game versions: https://help.minecraft.net/hc/en-us/articles/360034754852-Change-Game-Version-for-Minecraft-Java-Edition#:~:text=Click%20Installations%20on%20the%20launcher,Play%20on%20the%20top%20menu

Once you have the game loaded to 1.20.1, select multiplayer, and then add server. In the server address field input the following:
`public_ip:25565`
`public_ip` is the same ip used to connect to the instance and `25565` is the default port for a Minecraft server. 
After inputing the server address hit done, select the server and hit join. Congradulations you just connected to the Minecraft server. 

## Section 4: Adding Restart Functionallity to the Server

Although you can play on the server as it is, if the instance goes down then then you have to log into the instance to restart it. Now is time to add the restarting functionality to the server.

### Making server into a background service

To have the server run in the background on start up do the following:
1. run sudo vim /etc/systemd/system/minecraft.service
2. add the following section
    >[Unit]  
    >
    >Description = Minecraft Server  
    >
    >After=network.target  
    >
    >[Service]  
    >
    >WorkingDirectory=/home/ubuntu  
    >
    >ExecStart=/user/bin/java -Xmx1024M - Xms1024M -jar /home/ubuntu/server.jar nogui  
    >
    >ExecStop=/home/ubuntu/stop_minecraft.sh  
    >
    >User=Ubuntu  
    >
    >Restart=on-failure  
    >
    >[Install]  
    >
    >multi-user.target  
    >
3. sudo systemctl enable minecraft
4. sudo systemctl start minecraft

This will create a service that will start when the instance starts up, starting the Minecraft server when the instance starts.

### Proper Server Shutdown 

If you need to shut down the server it is important to do so properly in order to prevent errors from occuring. In order to do this do the following:
1. Create a shell script called `stop_minecraft.sh` inside put the following:
    >#!/bin/bash  
    >
    >screen -S minecraft -p 0 -X stuff "stop$(printf '\r')"  
    >

    This will go into the minecraft.service and stop the server. Make sure to run `chmod +x stop_minecraft.sh` to allow the execution of this file 
2. Create a new service for detecting when the server is going to encounter some for of stop. To do this:
    1.  run `sudo vim /etc/systemd/system/minecraft-stop.service`
    2.  enter the following into it
        >[Unit]  
        >
        >Description=Minecraft Server Stop  
        >
        >DefaultDependencies=no  
        >
        >Before=shutdown.target reboot.target halt.target  
        >
        >[Service]  
        >
        >Type=oneshot  
        >
        >ExecStart=/bin/true  
        >
        >ExecStop=/path/to/stop_minecraft.sh  
        >
        >[Install]  
        >
        >WantedBy=halt.target reboot.target shutdown.target  
    

    3. run `sudo systemctl enable minecraft-stop` to enable this service. There is no need to run the start command as it will attempt to stop the server when doing so.
    
Now when the server is being shut down, the minecraft-stop service will stop the Minecraft server properly.

# Resources

The following are the resources that I used for my research on how to do this project:  

Build Infrastructure Tutorial from hashicorp: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-build  

Lab 9 | Infrastructure as Code from Canvas.  

ChatGPT: See `CHATGPTLogs.pdf` to see all of the conversation that helped me in this project  

    
























