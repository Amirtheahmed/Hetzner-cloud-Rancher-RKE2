# Infrastructure Repository
Author: Amir Ahmed | amirsalihdev@gmail.com, amirtheahmed@gmail.com
## Overview
This repository stores and maintains all Infrastructure as Code (IaC) scripts used to set up the necessary infrastructures. It includes scripts for setting up scalable Kubernetes (K8s) clusters using Rancher on Hetzner Cloud, deployment of various applications, and monitoring configurations.

## Repository Structure

### Rancher Folder
This folder contains IaC codes for setting up a scalable K8s Rancher-based cluster on Hetzner Cloud.

#### Technologies Used:
- Hashicorp's Terraform
- Ansible
- Rancher
- RKE2 (K8s)
- Traefik

#### Folder Structure:
- **Terraform**: Contains main Terraform codes, states, and variables for Hetzner Cloud server setup.
- **Ansible**: Playbooks for Rancher (RKE2) setup, including master and worker node configurations, Rancher helm charts, Traefik setup, and Ansible inventory files.
- **Rancher**: Rancher-specific configuration files, including ingress routes and `values.yml`.
- **Traefik**: Manifest files and configurations for setting up Traefik as the default ingress provider.

## Getting Started
- Clone the repository: `git clone https://github.com/Amirtheahmed/Hetzner-cloud-Rancher-RKE2.git`
- Follow the specific README.md within each folder for detailed setup instructions.