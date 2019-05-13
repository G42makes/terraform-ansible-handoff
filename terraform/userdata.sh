#!/bin/sh

#setup local tools
#  In prod I would have these as part of the AMI
apt update
apt upgrade -y
apt install -y jq

#handoff to ansible-pull
