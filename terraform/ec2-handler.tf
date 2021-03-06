## Using cloud-init handlers and providing a json file.
#Setup some vars we need.
locals {
  #see ec2-simple.tf for an explanation of this construct.
  handler_tags = "${merge(
    var.instance_tags,
    map(
      "Repo", "${coalesce(
        join("", aws_codecommit_repository.terraform_ansible_handoff.*.clone_url_http),
        var.repo_type == "AWS" ? "" : var.repo_address,
      )}"
    )
  )}"
}

#create the actual instance and userdata
resource "aws_instance" "handler" {
  count = "${var.instance_type == "handler" ? 1 : 0}"
  ami = "${data.aws_ami.ubuntu_18_04.id}"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.handler_profile.name}"
  tags = "${merge(
    map(
      "Name", "handler"
    ),
    local.handler_tags)}"
  key_name = "${aws_key_pair.tf-ansible.key_name}"
  user_data_base64 = "${data.template_cloudinit_config.config.rendered}"
}

#Generate our files for a multi-part cloud-init data block.
data "template_cloudinit_config" "config" {
  gzip = true
  base64_encode = true

  #The same userdata file for both variations
  part {
    content_type = "text/x-shellscript"
    filename = "userdata.sh"
    content = "${file("userdata.sh")}"
  }
  #We need to tell cloud init what to do with our "application/json"
  #   data. This handler accepts it, and with the filename writes it
  #   out to /run/cloud-init/<filename>
  part {
    content_type = "text/part-handler"
    filename = "handler-json.py"
    content = "${file("handler-json.py")}"
  }
  #And this is the collection of vars that we want to pass to our
  #   ansible process to be used as needed from there.
  # You may want to add the hostname here, but it's not automatic.
  part {
    content_type = "application/json"
    filename = "user-vars.json"
    content = "${jsonencode(local.handler_tags)}"
  }
}

#Create our policies/roles and connections.
data "aws_iam_policy_document" "handler_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals = {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"],
    }
  }
}
resource "aws_iam_role" "handler_role" {
  count = "${var.instance_type == "handler" ? 1 : 0}"
  name = "handler_role"
  assume_role_policy = "${data.aws_iam_policy_document.handler_role.json}"
}
resource "aws_iam_instance_profile" "handler_profile" {
  count = "${var.instance_type == "handler" ? 1 : 0}"
  name = "handler_profile"
  role = "${aws_iam_role.handler_role.name}"
}
resource "aws_iam_policy_attachment" "handler_policy" {
  count = "${var.instance_type == "handler" ? 1 : 0}"
  name = "handler_policy"
  roles = ["${aws_iam_role.handler_role.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

#Codecommit policy attachment
resource "aws_iam_policy_attachment" "hander_codecommit_policy" {
  count = "${var.instance_type == "handler" ? 1 : 0}"
  name = "codecommit_policy"
  roles = ["${aws_iam_role.handler_role.name}"]
  policy_arn = "${aws_iam_policy.codecommit_policy.arn}"
}
