terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

# --- RÉSEAU ---
resource "docker_network" "private_network" {
  name = "mimid_tp_network"
}

# --- CONTENEUR NGINX (Serveur) ---
resource "docker_image" "my_image" {
  name         = var.docker_image_name
  keep_locally = false
}

resource "docker_container" "my_container" {
  image = docker_image.my_image.image_id
  name  = var.container_name

  networks_advanced {
    name    = docker_network.private_network.name
    aliases = ["nginx"]
  }

  ports {
    internal = var.internal_port
    external = var.external_port
  }
}

# --- CONTENEURS CLIENTS (Multi-déploiement avec count) ---
# Image pour le client curl
resource "docker_image" "curl_image" {
  name = "appropriate/curl"
}

# Exercice 5 : Création de plusieurs clients
resource "docker_container" "client" {
  # On utilise la variable définie dans variables.tf
  count = var.client_count

  image = docker_image.curl_image.image_id
  
  # Nom unique pour chaque client (client-0, client-1, client-2)
  name  = "client-${count.index}"
  
  # Commande pour appeler nginx et dormir 30s
  command = ["sh", "-c", "curl -s http://nginx:80 && echo 'Client ${count.index} connecte avec succes' && sleep 30"]

  networks_advanced {
    name = docker_network.private_network.name
  }

  # On attend que le serveur soit prêt
  depends_on = [docker_container.my_container]
}

# --- TEST DE VÉRIFICATION (Local-exec) ---
resource "null_resource" "check_nginx" {
  depends_on = [docker_container.my_container]

  provisioner "local-exec" {
    command = "curl -s http://localhost:${var.external_port} | grep -q 'Welcome' && echo 'Test Réussi : Nginx répond bien sur localhost !' || echo 'Test Échoué'"
  }
}
