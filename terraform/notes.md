# userdata
## isntalls
apt install apt install ec2-api-tools awscli

## extracting keys to var pairs
aws ec2 describe-tags --region=us-east-1 --filters "Name=resource-id,Values=$(< /var/lib/cloud/data/instance-id)" | jq '[.Tags[] | {(.Key): .Value}] | add'

# ansible
## include_vars
https://docs.ansible.com/ansible/latest/modules/include_vars_module.html
