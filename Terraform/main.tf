# --- VPC Network Definition ---
resource "google_compute_network" "vpc_network" {
  name                    = "${var.cluster_name}-network"
  auto_create_subnetworks = false 
}

# --- Subnetwork Definition with Secondary IP Ranges ---
resource "google_compute_subnetwork" "gke_subnet" {
  name          = "${var.cluster_name}-subnet"
  network       = google_compute_network.vpc_network.self_link
  region        = var.region
  # Primary IP range for the GKE nodes
  ip_cidr_range = "10.0.0.0/20" 

  # Secondary IP range for GKE Pods
  secondary_ip_range {
    range_name    = "gke-pods-range"
    ip_cidr_range = "10.1.0.0/16"
  }

  # Secondary IP range for GKE Services (ClusterIPs)
  secondary_ip_range {
    range_name    = "gke-services-range"
    ip_cidr_range = "10.2.0.0/20"
  }
}

# --- GKE Cluster Definition (Restored) ---
resource "google_container_cluster" "primary" {
  name                     = var.cluster_name
  location                 = var.zone
  project                  = var.project_id
  initial_node_count       = 1 
  remove_default_node_pool = true 
  
  # Reference the new network and subnet
  network    = google_compute_network.vpc_network.self_link
  subnetwork = google_compute_subnetwork.gke_subnet.self_link
  
  networking_mode = "VPC_NATIVE" 

  # Reference the new secondary range names
  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-pods-range"
    services_secondary_range_name = "gke-services-range"
  }

  release_channel {
    channel = "REGULAR"
  }

  # Dependency ensures VPC is ready before cluster is created
  depends_on = [google_compute_subnetwork.gke_subnet]
}

# --- GKE Node Pool Definition (Using OLD syntax to fix persistent error) ---
resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.cluster_name}-nodepool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count
  project    = var.project_id
  
  node_config {
    machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

# --- Local Configuration (Sets up kubectl context) ---
resource "null_resource" "kubectl_config" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --zone ${var.zone} --project ${var.project_id}"
  }
  depends_on = [google_container_cluster.primary]
}

# --- Terraform Output ---
output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "endpoint" {
  value = google_container_cluster.primary.endpoint
}