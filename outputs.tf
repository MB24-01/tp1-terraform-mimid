output "nginx_container_id" {
  description = "L'identifiant du conteneur Docker"
  value       = docker_container.my_container.id
}
