curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version


aws configure
aws sts get-caller-identity

sudo apt update
sudo apt install -y jq
jq --version


# Required Permissions:
# EC2:

# DescribeInstances
# DescribeVolumes
# DescribeSnapshots
# DeleteSnapshot
# DeleteVolume
# TerminateInstances
# Elastic IPs:

# DescribeAddresses
# ReleaseAddress
# AMIs:

# DescribeImages
# DeregisterImage
# Load Balancers:

# DescribeLoadBalancers
# DescribeInstanceHealth
# DeleteLoadBalancer



DRY_RUN=true
chmod 600 .env
./aws_cost_optimizer.sh
crontab -e
0 0 * * * /path/to/aws_cost_optimizer.sh >> /path/to/aws_cost_optimizer.log 2>&1


https://chatgpt.com/share/677ebd82-0018-8004-a680-20e242db6e8a