variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
  # Replace 'esraa-k8s-microservice' with your actual GCP project ID
  default     = "esraa-k8s-microservice" 
}

variable "region" {
  description = "The GCP region for the GKE cluster"
  type        = string
  default     = "us-central1" # Recommended region
}

variable "zone" {
  description = "The specific zone for the GKE cluster"
  type        = string
  default     = "us-central1-a" # Matches your gcloud command
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default     = "microservice-gke-cluster"
}

variable "machine_type" {
  description = "The machine type for GKE nodes"
  type        = string
  default     = "e2-medium"
}

variable "node_count" {
  description = "The initial number of nodes in the default node pool"
  type        = number
  default     = 3 # Matches your gcloud command
}