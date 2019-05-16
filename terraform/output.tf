#outputs for usability
# since we only run one OR another instnace, we want the values
#   for whichever is valid to be output here.
# Ref: https://github.com/hashicorp/terraform/issues/12475#issuecomment-375471148
#  the "a ? b : c" format conditional does not work here as both b and c will
#   be interpreted, and errors are thrown since at least one does not exist.
# This bypasses that problem, with some tricks.
output "ip" {
  value = "${coalesce(
    join("", aws_instance.handler.*.public_ip),
    join("", aws_instance.tags.*.public_ip),
    join("", aws_instance.simple.*.public_ip),
    )}"
}
output "dns" {
  value = "${coalesce(
    join("", aws_instance.handler.*.public_dns),
    join("", aws_instance.tags.*.public_dns),
    join("", aws_instance.simple.*.public_dns),
    )}"
}
