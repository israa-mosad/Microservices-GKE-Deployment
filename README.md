# Flask Microservice Deployment on GKE: Full DevOps Pipeline

This repository contains the complete Infrastructure-as-Code (IaC) and Continuous Integration/Continuous Deployment (CI/CD) solution for deploying a Python Flask microservice onto a Google Kubernetes Engine (GKE) cluster.

The project demonstrates expertise in:
* **Terraform** (IaC)
* **Docker**
* **GitHub Actions** (CI/CD)
* **Kubernetes**
* **Prometheus/Grafana** (Monitoring)

## Task Steps in Execution Order
This section outlines the chronological process followed, including the necessary fixes implemented during development, to achieve the final deployed and monitored state.

| Step | Task Focus | Key Tool / Action |
| :--- | :--- | :--- |
| **I** | Setup | Clone repository and initialize Git. |
| **II** | Dockerize | Create Dockerfile and build local image (`microservice:local`). |
| **III** | Registry | Create Artifact Registry, tag, and push image. |
| **IV** | Provision GKE | Use Terraform (`apply`) to create VPC, Subnet, and GKE cluster. *(Required fix: VPC-native networking and SSD quota limit)* |
| **V** | CI/CD Setup | Configure GitHub Secrets, create the `main.yml` workflow, and resolve authentication errors. |
| **VI** | Deploy | Commit `main.yml` to trigger the CI/CD pipeline, which builds, pushes, and deploys the microservice to GKE. *(Required fix: Deployment command order)* |
| **VII** | Validate External Access | Use `kubectl get svc` to retrieve the LoadBalancer IP and validate API endpoints (`/users`, `/products`). |
| **VIII** | Monitoring | Install Helm, deploy the Prometheus/Grafana stack, and validate access. |

## Repository Structure
The project structure organizes the application code, infrastructure definitions, and all validation assets based on the final file arrangement.

```bash
MICROSERVICES/
├── .github/workflows/   <-- Task 6: CI/CD Pipeline Configuration
│   └── main.yml
├── app/                 <-- Flask application source code (routes, services)
├── documentation/       <-- Validation Screenshots (Final Deliverable)
│   ├── Api_Test_Images/   <-- Task 5: API LoadBalancer Access Screenshots
│   ├── Cluster_Status/    <-- Task 4: kubectl get pods, deploy status
│   └── Grafana_Dashboard/ <-- Task 7: Monitoring Validation Screenshots
├── kubernetes/          <-- Task 4: Deployment & Service YAMLs
├── terraform/           <-- Task 3: GKE Infrastructure Files
│   ├── main.tf
│   ├── variables.tf
│   ├── versions.tf
│   └── terraform.tfstate
├── Dockerfile           <-- Task 2: Container definition
├── run.py               <-- Flask entry point
├── requirements.txt
├── .dockerignore
├── .gitignore
└── README.md            
````

## Project Status Summary

| Task | Status | Tool Used | Deliverable Proof |
| :--- | :--- | :--- | :--- |
| **1. Clone Repository** | Complete | Git | Repository structure confirmed. |
| **2. Dockerize Application** | Complete | Docker | Optimized image size (e.g., 66.7MB) verified. |
| **3. Provision GKE Cluster** | Complete | Terraform | Cluster, VPC, and Node Pool successfully created. |
| **4. Deploy Microservice** | Complete | Kubernetes YAML | Deployment and Service objects created. |
| **5. Expose Service** | Complete | LoadBalancer | External IP assigned and publicly accessible. |
| **6. CI/CD Pipeline** | Complete | GitHub Actions | Automated build, push, and deploy on commit. |
| **7. Monitoring** | Complete | Helm, Prometheus, Grafana | Monitoring stack installed and validated. |

-----

## Task 2: Dockerization & Entrypoint

The application is containerized using the following Dockerfile. The `CMD` instruction ensures the Flask application is run correctly within the container environment, binding to host `0.0.0.0` on port `5000`.

```dockerfile
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose Flask port
EXPOSE 5000

# Start the application
CMD ["sh", "-c", "export FLASK_APP=run.py && flask run --host=0.0.0.0 --port=5000"]
```

-----

## Task 3: Provision GKE Cluster (Terraform)

The GKE cluster was provisioned using Terraform, including necessary networking and resource constraint fixes implemented in `main.tf`.

**Final Provisioning Commands:**

```sh
cd terraform/
terraform init
terraform apply
```

-----

## Task 6: CI/CD Pipeline (GitHub Actions)

The deployment is automated via a GitHub Actions workflow that successfully executes the build, push to Artifact Registry, and deployment process.

<img width="704" height="331" alt="image" src="https://github.com/user-attachments/assets/2c235df9-0e8f-4bc1-a585-6fee560a48e6" />

<img width="706" height="317" alt="image" src="https://github.com/user-attachments/assets/f98294d7-60e9-45b7-aa40-f1e355dce0aa" />



### Verification Proof (Pod Status)

The deployment resulted in two running Pods for the microservice and all monitoring components.

```sh
# Command to verify Pod and Deployment status
kubectl get pods,deployments
```

-----

## Task 5: External Validation

The service is exposed using a Kubernetes `LoadBalancer` service.

### 1\. Access Instructions

Find the `EXTERNAL-IP` using `kubectl get service microservice-loadbalancer`.

Access the API via the browser: `http://<EXTERNAL-IP>/users`

### 2\. Validation

<img width="514" height="209" alt="api_test_users png" src="https://github.com/user-attachments/assets/4e96ca5a-831d-4386-9f3b-dc66fbd353f9" />

-----

## Task 7: Monitoring (Prometheus & Grafana)

The monitoring stack was deployed using Helm (`kube-prometheus-stack`).

<img width="958" height="467" alt="Prometheud_Dashboard" src="https://github.com/user-attachments/assets/874974dd-cc3f-48cb-82e8-954472cbffd6" />

### 1\. Access Commands

Retrieve Admin Password (PowerShell Native Command):

```powershell
kubectl get secrets prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | Out-String | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
```

Port Forward (Keep terminal open):

```sh
kubectl port-forward svc/prometheus-stack-grafana 3000:80
```

**Access URL:** `http://localhost:3000` (Login with 'admin' and the retrieved password).

### 2\. Monitoring 

<img width="958" height="470" alt="grafana_app_pod_metrics png" src="https://github.com/user-attachments/assets/71d1840a-d042-49ad-a128-2be491683237" />

The Grafana dashboard shows Pod-level metrics, validating the monitoring setup is functional and scraping the application metrics.

