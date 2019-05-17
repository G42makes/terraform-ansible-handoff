## Injecting the values file creation into the userdata via a template
#create the actual instance and userdata
resource "aws_instance" "simple" {
  count = "${var.instance_type == "simple" ? 1 : 0}"
  ami = "${data.aws_ami.ubuntu_18_04.id}"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.simple_profile.name}"
  tags = "${merge(
    map(
      "Name", "simple"
    ),
    var.instance_tags)}"
  key_name = "${aws_key_pair.tf-ansible.key_name}"
  #Here we prepend our template to the re-usable userdata.sh
  user_data = "${join("\n", list("${data.template_file.vars.rendered}", file("userdata.sh")))}"
}

#template the vars into a file that we will prepend to the userdata above
data "template_file" "vars" {
  #This template is prepended to the userdata script.
  #   It has a shebang for bash to ensure it's handled as a script, the second one that comes
  #   from the original script is just seen as a comment.
  # Once this file is created, the behaviour is the same as the other types of instances.
  # In a production system, I would probably not merge these, but just template the entire
  #   userdata.sh script.
  # The nice thing about this layout is that it can handle any number of vars, we don't have
  #   to specify them in the vars list, it's just handled.
  template = "#!/bin/sh\necho '$${vars}' > /run/cloud-init/user-vars.json"
  vars = {
    vars = "${jsonencode(var.instance_tags)}"
  }
}

#Create our policies/roles and connections.
data "aws_iam_policy_document" "simple_role" {
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
resource "aws_iam_role" "simple_role" {
  count = "${var.instance_type == "simple" ? 1 : 0}"
  name = "simple_role"
  assume_role_policy = "${data.aws_iam_policy_document.simple_role.json}"
}
resource "aws_iam_instance_profile" "simple_profile" {
  count = "${var.instance_type == "simple" ? 1 : 0}"
  name = "simple_profile"
  role = "${aws_iam_role.simple_role.name}"
}
resource "aws_iam_policy_attachment" "simple_policy" {
  count = "${var.instance_type == "simple" ? 1 : 0}"
  name = "simple_policy"
  roles = ["${aws_iam_role.simple_role.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

#Codecommit policy attachment
resource "aws_iam_policy_attachment" "simple_codecommit_policy" {
  count = "${var.instance_type == "simple" ? 1 : 0}"
  name = "codecommit_policy"
  roles = ["${aws_iam_role.simple_role.name}"]
  policy_arn = "${aws_iam_policy.codecommit_policy.arn}"
}
