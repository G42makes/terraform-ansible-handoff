# userdata
## installs
apt install apt install ec2-api-tools awscli

## extracting keys to var pairs on host
aws ec2 describe-tags --region=us-east-1 --filters "Name=resource-id,Values=$(< /var/lib/cloud/data/instance-id)" | jq '[.Tags[] | {(.Key): .Value}] | add'

# ansible
## include_vars
https://docs.ansible.com/ansible/latest/modules/include_vars_module.html

#terraform
## create json from vars
jsonencode sucks on v<0.12, everything is a string
value = "${jsonencode(map("test1", var.test1, "test2", var.test2))}"
  this works only with basic data types, nesting is impossible without creativity
## multipart mime handlers
http://foss-boss.blogspot.com/2011/01/advanced-cloud-init-custom-handlers.html
https://cloudinit.readthedocs.io/en/latest/topics/format.html

#cloud-init
/run/cloud-init
/var/lib/cloud
