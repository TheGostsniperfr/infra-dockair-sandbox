variable "project_name" {
  type = string

  validation {
    condition     = length(var.project_name) > 0
    error_message = "The project_name variable must not be empty."
  }
}

variable "env" {
  type = string

  validation {
    condition     = contains(["staging", "prod"], var.env)
    error_message = "The env variable must be either 'staging' or 'prod'."
  }
}

variable "cp_count" {
  type = number

  validation {
    condition     = var.cp_count >= 1
    error_message = "The cp_count variable must be a positive integer."
  }
}

variable "cp_flavor" {
  type = string

  validation {
    condition     = length(var.cp_flavor) > 0
    error_message = "The cp_flavor variable must not be empty."
  }
}

variable "worker_count" {
  type = number

  validation {
    condition     = var.worker_count >= 1
    error_message = "The worker_count variable must be a positive integer."
  }
}

variable "worker_flavor" {
  type = string

  validation {
    condition     = length(var.worker_flavor) > 0
    error_message = "The worker_flavor variable must not be empty."
  }
}

variable "image_name" {
  type = string

  validation {
    condition     = length(var.image_name) > 0
    error_message = "The image_name variable must not be empty."
  }
}

variable "keypair_name" {
  type = string

  validation {
    condition     = length(var.keypair_name) > 0
    error_message = "The keypair_name variable must not be empty."
  }
}

variable "internal_net_id" {
  type = string

  validation {
    condition     = length(var.internal_net_id) > 0
    error_message = "The internal_net_id variable must not be empty."
  }
}

variable "secgroup_ids" {
  type = list(string)
}

variable "cp_user_data" {
  type = string
}

variable "worker_user_data" {
  type = string
}
