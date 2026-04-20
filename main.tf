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
# Exercice 4 : Création du réseau privé pour faire communiquer les conteneurs
resource "docker_network" "private_network" {
  name = "mimid_tp_network"
}

# --- CONTENEUR NGINX (Serveur) ---
# Image pour Nginx
resource "docker_image" "my_image" {
  name         = var.docker_image_name
  keep_locally = false
}

# Ressource unique pour le conteneur Nginx
resource "docker_container" "my_container" {
  image = docker_image.my_image.image_id
  name  = var.container_name

  # Connexion au réseau avec un alias DNS "nginx"
  networks_advanced {
    name    = docker_network.private_network.name
    aliases = ["nginx"]
  }

  ports {
    internal = var.internal_port
    external = var.external_port
  }
}

# --- CONTENEUR CLIENT (Curl) ---
# Exercice 4 : Image pour le client curl
resource "docker_image" "curl_image" {
  name = "appropriate/curl"
}

# Deuxième conteneur qui appelle le premier
resource "docker_container" "client" {
  image = docker_image.curl_image.image_id
  name  = "client-container"
  
  # Commande pour tester la connexion interne et rester actif
  command = ["sh", "-c", "curl -s http://nginx:80 && echo 'Connexion reseau OK' && sleep 300"]

  networks_advanced {
    name = docker_network.private_network.name
  }

  # Sécurité : On attend que le serveur soit prêt
  depends_on = [docker_container.my_container]
}

# --- TEST DE VÉRIFICATION (Local) ---
# Exercice 3 : Test automatique depuis ton Mac
resource "null_resource" "check_nginx" {
  depends_on = [docker_container.my_container]

  provisioner "local-exec" {
    command = "curl -s http://localhost:${var.external_port} | grep -q 'Welcome' && echo 'Test Réussi : Nginx répond bien sur localhost !' || echo 'Test Échoué'"
  }
}
