packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "minecraft" {
  ami_name      = "minecraft-server-ami-{{timestamp}}"
  instance_type = "t4g.small"
  region        = "us-east-2"
  source_ami_filter {
    filters = {
      name                = "al2023-ami-*-kernel-*-arm64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["137112412989"]
  }
  ssh_username = "ec2-user"
  tags = {
    type = "minecraft-server"
    OS_Version = "Amazon Linux"
  }
}

build {
  name    = "minecraft-server-ami"
  sources = [
    "source.amazon-ebs.minecraft"
  ]

  provisioner "shell" {
    inline = [
      "sudo yum install -y java-22-amazon-corretto-headless",
      "sudo adduser minecraft",
      "sudo mkdir /opt/minecraft/",
      "sudo mkdir /opt/minecraft/server/",
      "cd /opt/minecraft/server",
      "sudo curl ${var.minecraft_url} -O",
      "sudo chown -R minecraft:minecraft /opt/minecraft/",
      "sudo java -Xmx1300M -Xms1300M -jar server.jar nogui",
      "sleep 40",
      "sudo sed -i 's/false/true/p' eula.txt"
    ]
  }

  provisioner "file" {
    sources = [
      "files/start",
      "files/stop",
      "files/minecraft.service"
    ]
    destination = "/tmp/"
  }

  provisioner "shell" {
    inline = [
      "sudo mv /tmp/{start,stop} /opt/minecraft/server/",
      "sudo mv /tmp/minecraft.service /etc/systemd/system/",
      "sudo chmod +x /opt/minecraft/server/{start,stop}",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable minecraft.service",
      "sudo systemctl start minecraft.service"
    ]
  }
}
