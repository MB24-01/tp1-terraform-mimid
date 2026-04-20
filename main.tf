terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

# Utilisation de la variable pour l'image
resource "docker_image" "my_image" {
  name         = var.docker_image_name
  keep_locally = false
}

# Utilisation des variables pour le conteneur et les ports
resource "docker_container" "my_container" {
  image = docker_image.my_image.image_id
  name  = var.container_name

  ports {
    internal = var.internal_port
    external = var.external_port
  }
}
