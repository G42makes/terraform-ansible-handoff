## Injecting the values file creation into the userdata via a template
#Setup some vars we need.
locals {
  #This one get's a little ugly, so here is some info:
  # - simple_tags: this is used later in the instance, we could set the hostname here, if we only want one box.
  #   - We prepend "simple" to avoid name collisions.
  # - merge: used to merge the two maps, the one with the tags from the vars, and the one we are about to create.
  # - var.instance tags: just the existing map of vars, allowing us to add/remove as needed.
  # - map: create a new map from scratch, merged into the above for output.
  #   - "Repo": just the name of the entry in this map, will be used as a tag name in the instance.
  #   - coalesce: returns the first non empty item from the list
  #   - join: returns blank if we didn't create the repo at all, using the "*" handles count = 0 instances.
  #   - we only put in the repo_address if it is not type AWS, otherwise we use the above.
  simple_tags = "${merge(
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
resource "aws_instance" "simple" {
  count = "${var.instance_type == "simple" ? 1 : 0}"
  ami = "${data.aws_ami.ubuntu_18_04.id}"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.simple_profile.name}"
  tags = "${merge(
    map(
      "Name", "simple"
    ),
    local.simple_tags)}"
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
    vars = "${jsonencode(local.simple_tags)}"
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
