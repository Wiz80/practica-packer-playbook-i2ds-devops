variable "ansible_playbook_file" {
  type    = string
  default = "playbook.yaml"
}

source "amazon-ebs" "example" {
  region = "us-east-1"
  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
    }
    owners      = ["099720109477"]
    most_recent = true
  }
  instance_type = "t2.micro"
  ssh_username  = "ubuntu"
  ami_name      = "packer-ansible-mongodb-{{timestamp}}"
}

build {
  sources = ["source.amazon-ebs.example"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y software-properties-common",
      "sudo apt-add-repository --yes --update ppa:ansible/ansible",
      "sudo apt-get install -y ansible"
    ]
  }

  provisioner "file" {
    source      = "${var.ansible_playbook_file}"
    destination = "/home/ubuntu/playbook.yaml"
  }

  provisioner "shell" {
    inline = [
      "ansible-playbook /home/ubuntu/playbook.yaml"
    ]
  }
}
