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

# --- CONTENEURS CLIENTS (Boucle for_each) ---
# Exercice 6 : Utilisation de for_each pour des noms personnalisés
resource "docker_image" "curl_image" {
  name = "appropriate/curl"
}

resource "docker_container" "client" {
  # On boucle sur la liste transformée en 'set'
  for_each = toset(var.client_names)

  image = docker_image.curl_image.image_id
  
  # Le nom utilisera chaque valeur de la liste (ex: client-alpha)
  name  = "client-${each.key}"
  
  command = ["sh", "-c", "curl -s http://nginx:80 && echo 'Client ${each.key} connecte avec succes' && sleep 30"]

  networks_advanced {
    name = docker_network.private_network.name
  }

  # On attend que le serveur soit prêt
  depends_on = [docker_container.my_container]
}

# --- TEST DE VÉRIFICATION (Local) ---
resource "null_resource" "check_nginx" {
  depends_on = [docker_container.my_container]

  provisioner "local-exec" {
    command = "curl -s http://localhost:${var.external_port} | grep -q 'Welcome' && echo 'Test Réussi : Nginx répond bien sur localhost !' || echo 'Test Échoué'"
  }
}
