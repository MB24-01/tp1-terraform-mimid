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
resource "null_resource" "check_nginx" {
  # On force le test à attendre que le conteneur soit démarré
  depends_on = [docker_container.my_container]

  provisioner "local-exec" {
    # Cette commande curl va vérifier si la page contient "Welcome"
    # On utilise la variable external_port pour que le test s'adapte
    command = "curl -s http://localhost:${var.external_port} | grep -q 'Welcome' && echo 'Test Réussi : Nginx répond bien !' || echo 'Test Échoué'"
  }
}
