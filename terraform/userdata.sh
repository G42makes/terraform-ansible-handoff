#!/bin/bash

USER_VARS="/run/cloud-init/user-vars.json"

#setup local tools
#  In prod I would have these as part of the AMI
setup_tools() {
  #Get the latest repo data
  apt update
  #Upgrade all local packages that have updates(can be skipped)
  apt upgrade -y
  #Add the ansible official repo.
  #   Some systems will need apt install software-properties-common
  #   -yu: y: no prompts, u: update repo data but only pull from this repo
  apt-add-repository -yu ppa:ansible/ansible
  #And install the tools we need in this script. Everything else should be
  #   installed via ansible if at all possible.
  apt install -y jq awscli ansible
}

#functiont call if the /run/cloud-init/user-vars.json does not exist
create_user_vars_tags () {
  aws ec2 describe-tags \
    --region=us-east-1 \
    --filters "Name=resource-id,Values=`cat /var/lib/cloud/data/instance-id`" \
    | jq '[.Tags[] | {(.Key): .Value}] | add' \
    > $USER_VARS
}

#Function to setup and run the ansible-pull command we are using
ansible_pull () {
  REPO=`jq -r .Repo $USER_VARS`
  echo $REPO
  if [[ $REPO =~ "amazonaws" ]]
  then
    echo "AWS Repo"
    #Info on git pull via AWS - tested with my current cloudwatch policy and it works
    # see bottom of page
    #   https://blog.0x427567.com/2016/08/13/How-to-clone-AWS-CodeCommit-repository-from-EC2-instance/

    # aws --region=us-east-1 codecommit list-repositories
    # aws --region=us-east-1 codecommit get-repository --repository-name=terraform-ansible-handoff
    # git config --global credential.helper '!aws codecommit credential-helper $@'
    # git config --global credential.UseHttpPath true
    # git clone https://git-codecommit.us-east-1.amazonaws.com/v1/repos/terraform-ansible-handoff
    git config --global credential.helper '!aws codecommit credential-helper $@'
    git config --global credential.UseHttpPath true
  fi

  #We pull the repo and execute it, including our vars file here.
  # https://docs.ansible.com/ansible/latest/cli/ansible-pull.html
  ansible-pull -U $REPO -e @$USER_VARS -i localhost,
}

#Run our script
setup_tools
if [ ! -f $USER_VARS ]; then
  create_user_vars_tags
fi
ansible_pull
