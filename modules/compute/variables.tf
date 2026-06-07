variable "project_name" {
  type = string
}

variable "env" {
  type = string
}

variable "cp_count" {
  type = number
}

variable "cp_flavor" {
  type = string
}

variable "worker_count" {
  type = number
}

variable "worker_flavor" {
  type = string
}

variable "image_name" {
  type = string
}

variable "keypair_name" {
  type = string
}

variable "internal_net_id" {
  type = string
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
