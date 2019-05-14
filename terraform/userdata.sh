#!/bin/sh

USER_VARS="/run/cloud-init/user-vars.json"

#setup local tools
#  In prod I would have these as part of the AMI
setup_tools() {
  apt update
  apt upgrade -y
  apt install -y jq
  apt install -y awscli
}

#functionto call if the /run/cloud-init/user-vars.json does not exist
# due to being called for the tags variant
create_user_vars () {
  aws ec2 describe-tags \
    --region=us-east-1 \
    --filters "Name=resource-id,Values=`cat /var/lib/cloud/data/instance-id`" \
    | jq '[.Tags[] | {(.Key): .Value}] | add' \
    > $USER_VARS
}

#Run our script
setup_tools
if [ ! -f $USER_VARS ]; then
  create_user_vars
fi
#handoff to ansible-pull
