# 1. Le nom de l'image Docker
variable "docker_image_name" {
  description = "Nom de l'image à utiliser (ex: nginx:latest)"
  type        = string
  default     = "nginx:latest"
}

# 2. Le nom du conteneur
variable "container_name" {
  description = "Nom du conteneur Docker"
  type        = string
  default     = "mimid-container-tp1"
}

# 3. Le port externe (celui que tu tapes dans le navigateur)
variable "external_port" {
  description = "Port exposé sur l'hôte"
  type        = number
  default     = 8080
}

# 4. Le port interne (celui sur lequel l'app écoute dans Docker)
variable "internal_port" {
  description = "Port interne du conteneur"
  type        = number
  default     = 80
}
