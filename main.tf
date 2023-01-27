resource "google_compute_firewall" "fw_rules" {
  project     = var.project_id
  name        = "${var.name}-rules"
  network     = "default"
  description = "Firewall rules for exposing ELK stack ports"

  allow {
    protocol  = "tcp"
    ports     = ["9200", "9300", "5601"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "local_file" "elasticsearch_yaml" {
  content  = templatefile("templates/elasticsearch.yml.tpl", { es_cluster_name    = var.es_cluster_name, 
                                                               es_node_name       = var.es_node_name, 
                                                               es_network_host    = var.es_network_host, 
                                                               es_discovery_type  = var.es_discovery_type })
  filename = "elasticsearch.yaml"
}

resource "local_file" "kibana_yaml" {
  content  = templatefile("templates/kibana.yml.tpl", { kibana_host         = var.kibana_host, 
                                                        kibana_server_name  = var.kibana_server_name, 
                                                        kibana_es_hosts     = var.kibana_es_hosts })
  filename = "kibana.yaml"
}

resource "google_compute_instance" "elasticsearch_instance" {
  name         = "${var.name}-instance"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"
  }

  provisioner "file" {
      source      = local_file.elasticsearch_yaml.filename
      destination = "/tmp/elasticsearch.yml"
  }

  provisioner "file" {
      source      = local_file.kibana_yaml.filename
      destination = "/tmp/kibana.yml"
  }

  provisioner "remote-exec" {

    inline = [
      "sudo apt-get update && sudo apt-get install openjdk-8 -y",
      "wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -",
      "sudo apt-get install apt-transport-https -y",
      "echo 'deb https://artifacts.elastic.co/packages/7.x/apt stable main' | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list",
      "sudo apt-get update",
      "sudo apt-get install elasticsearch -y && sudo apt-get install kibana -y && sudo apt-get install logstash",
      "sudo mv /tmp/elasticsearch-config.yml /etc/elasticsearch/elasticsearch.yml",
      "sudo mv /tmp/kibana-config.yml /etc/kibana/kibana.yml",
      "sudo systemctl start elasticsearch && sudo systemctl start kibana",
      "sudo systemctl enable elasticsearch && sudo systemctl enable kibana"
    ]
  }
}

resource "google_compute_instance_firewall_attach" "fw_instance_attach" {
  instance = google_compute_instance.elasticsearch_instance.name
  firewall = google_compute_firewall.fw_rules.name
}