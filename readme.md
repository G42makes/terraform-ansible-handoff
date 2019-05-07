# Terraform to Ansible Handoff Example

The goal of this code is to show a basic example of terraform handing off to ansible using the ansible-pull style and an AWS(or other) git repo.

## Flow
1. The initial task is just to build an EC2 instance in AWS with a specific user_data script
2. The userdata script installs the required tools and then executes the ansible-pull request
3. Ansible completes the system setup, in this case some basic filler tasks

## Terraform

## User Data

### Variables/Tags

## Ansible
