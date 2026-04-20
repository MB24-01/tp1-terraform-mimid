variable "machines" {
  description = "Liste des configurations de machines virtuelles"
  type = list(object({
    name      = string
    vcpu      = number
    disk_size = number
    region    = string
  }))

  # Validation pour les vCPU (entre 2 et 64)
  validation {
    condition     = alltrue([for m in var.machines : m.vcpu >= 2 && m.vcpu <= 64])
    error_message = "Le nombre de vCPU doit être compris entre 2 et 64."
  }

  # Validation pour la taille du disque (min 20 Go)
  validation {
    condition     = alltrue([for m in var.machines : m.disk_size >= 20])
    error_message = "La taille du disque doit être d'au moins 20 Go."
  }

  # Validation pour la région (liste imposée)
  validation {
    condition     = alltrue([for m in var.machines : contains(["eu-west-1", "us-east-1", "ap-southeast-1"], m.region)])
    error_message = "La région doit être 'eu-west-1', 'us-east-1' ou 'ap-southeast-1'."
  }
}
