terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.130.0"
    }
  }
}

provider "yandex" {
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_zone
}

data "yandex_compute_image" "container_optimized_image" {
  family = "container-optimized-image"
}

resource "yandex_compute_instance" "app_instance" {
  name        = var.instance_name
  zone        = var.yc_zone
  platform_id = "standard-v1"

  resources {
    cores         = var.instance_cores
    memory        = var.instance_memory
    core_fraction = var.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.container_optimized_image.id
      size     = var.disk_size
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key)}"
  }

  # Copy файла в домашнюю директорию
  provisioner "file" {
    source      = var.config_file_path
    destination = "/home/ubuntu/config.yml"

    connection {
      type        = "ssh"
      host        = self.network_interface[0].nat_ip_address
      user        = "ubuntu"
      private_key = file(var.ssh_private_key)
    }
  }

  # Перемещение файла в целевую директорию
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/yandex/unified_agent",
      "sudo mv /home/ubuntu/config.yml /etc/yandex/unified_agent/config.yml"
    ]

    connection {
      type        = "ssh"
      host        = self.network_interface[0].nat_ip_address
      user        = "ubuntu"
      private_key = file(var.ssh_private_key)
    }
  }

  # Установка агента, Docker и запуск контейнера
  provisioner "remote-exec" {
    inline = [
      # Установка агента
      "ua_version=$(curl --silent https://storage.yandexcloud.net/yc-unified-agent/latest-version)",
      "curl --silent --remote-name https://storage.yandexcloud.net/yc-unified-agent/releases/$ua_version/unified_agent",
      "chmod +x ./unified_agent",

      # Создание и редактирование systemd юнита
      "echo '[Unit]\nDescription=Yandex Unified Agent\nAfter=network.target\n\n[Service]\nExecStart=/home/ubuntu/unified_agent\nRestart=always\nUser=root\n\n[Install]\nWantedBy=multi-user.target' | sudo tee /etc/systemd/system/unified-agent.service > /dev/null",

      # Перезагрузка systemd и запуск агента
      "sudo systemctl daemon-reload",
      "sudo systemctl enable unified-agent",
      "sudo systemctl start unified-agent",
      "sudo apt-get update",
      "sudo apt-get install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "echo \"${var.docker_password}\" | sudo docker login ${var.docker_registry_url} -u \"${var.docker_username}\" --password-stdin",
      "if [ $? -ne 0 ]; then echo 'Docker login failed'; exit 1; fi",
      "sudo docker pull ${var.docker_image_name}",
      "if sudo docker ps -a --format '{{.Names}}' | grep -Eq '^mydockerbot$'; then",
      "  sudo docker stop mydockerbot || exit 0",
      "  sudo docker rm mydockerbot || exit 0",
      "fi",
      "sudo docker run -d --name mydockerbot -p 80:80 ${var.docker_image_name}",
      "if [ $(sudo docker inspect -f '{{.State.Running}}' mydockerbot) != 'true' ]; then echo 'Container failed to start'; sudo docker logs mydockerbot; exit 1; fi",
      "echo \"Docker контейнер с ботом запущен на ВМ.\""
    ]

    connection {
      type        = "ssh"
      host        = self.network_interface[0].nat_ip_address
      user        = "ubuntu"
      private_key = file(var.ssh_private_key)
    }
  }
}
