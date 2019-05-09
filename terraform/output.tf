#outputs for usability
output "ip" {
  value = "${aws_instance.handoff.public_ip}"
}
output "dns" {
  value = "${aws_instance.handoff.public_dns}"
}
