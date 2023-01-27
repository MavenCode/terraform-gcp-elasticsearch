variable "name" {
    default = "reelbuds"
}

variable "machine_type" {
    default = "n1-standard-1"
}

variable "zone" {
    default = "us-central1-a"
}

variable "project_id" {
}

variable "region" {
}

variable "es_cluster_name" {
    type = string
    default = "reelbuds-es-cluster"
}

variable "es_node_name" {
    type = string
    default = "reelbuds-es-node"
}

variable "es_network_host" {
    type = string
    default = "0.0.0.0"
}

variable "es_discovery_type" {
    type = string
    default = "single-node"
}

variable "kibana_host" {
    type = string
    default = "0.0.0.0"
}

variable "kibana_server_name" {
    type = string
    default = "elasticsearch-server"
}

variable "kibana_es_hosts" {
    type = string
    default = "['http://localhost:9200']"
}