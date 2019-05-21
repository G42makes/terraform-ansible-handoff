#We create a codecommit repo for this git repo, and upload this to it.
#   From there we pull it locally on the host as part of the ansible pull.

#Create the repo we will be using.
resource "aws_codecommit_repository" "terraform_ansible_handoff" {
  count = "${var.repo_type == "AWS" ? 1 : 0}"
  repository_name = "${var.codecommit_repo}"
  description = "Test Repo for handoff from terrafrom to ansible with variable passing."
}

#Ensure that var.codecommit_user has the local ssh user key uploaded.
resource "aws_iam_user_ssh_key" "codecommit_user_key" {
  count = "${var.repo_type == "AWS" ? 1 : 0}"
  username = "${data.aws_iam_user.codecommit_user.user_name}"
  encoding = "SSH"
  public_key = "${file("${var.public_key_filename}")}"
}

#Make sure our user has codecommit access permissions on thier user.
resource "aws_iam_user_policy_attachment" "codecommit_access" {
  count = "${var.repo_type == "AWS" ? 1 : 0}"
  user = "${data.aws_iam_user.codecommit_user.user_name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeCommitFullAccess"
}

#We now push our repo to aws for it's use.
#I didn't find any good terraform providers for git management like this.
#   We need teh GIT_SSH_COMMAND to ensure we use the right key and key id as username
resource "null_resource" "git_push" {
  count = "${var.repo_type == "AWS" ? 1 : 0}"
  provisioner "local-exec" {
    command = "git push ${aws_codecommit_repository.terraform_ansible_handoff.clone_url_ssh}"
    environment = {
      GIT_SSH_COMMAND = "ssh -i ${var.private_key_filename} -l ${aws_iam_user_ssh_key.codecommit_user_key.ssh_public_key_id}"
    }
  }
}

#We need to create and attach a policy to the EC2 instances as well, giving acces to this repo.
data "aws_iam_policy_document" "codecommit_policy" {
  statement {
    sid = "Stmt1558107929198"
    actions = [
      "codecommit:GetRepository",
      "codecommit:GitPull",
      "codecommit:ListRepositories",
    ]
    resources = [
      "*"
    ]
  }
}
resource "aws_iam_policy" "codecommit_policy" {
  count = "${var.repo_type == "AWS" ? 1 : 0}"
  name = "codecommit_policy"
  description = "Allow ec2 instance to get data from and pull git repo"
  policy = "${data.aws_iam_policy_document.codecommit_policy.json}"
}
