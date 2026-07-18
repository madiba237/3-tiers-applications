# Multi-Tier Infrastructure Provisioning & Configuration

This repository contains Infrastructure as Code (IaC) and configuration management scripts to deploy a secure, multi-tier environment. It provisions a public-facing **Bastion host**, a private **Redis instance**, and a private **PostgreSQL database** using **Terraform**, and configures them automatically using **Ansible**.

## Architecture Overview

The infrastructure isolates the database and cache layers within a private network, enforcing all administrative access through a secured Bastion host (Jump Server).

*   **Bastion Host:** Act as the single entry point to the infrastructure. Only port `22` (SSH) is exposed to authorized IP addresses.
*   **Redis Cache:** Deployed in the private subnet, accessible only by the application tier / Bastion.
*   **PostgreSQL Database:** Deployed in the private subnet with restricted access control.

---

## Prerequisites

Before deploying, ensure you have the following tools installed locally:

*   [Terraform](https://www.terraform.io/downloads.html) (`>= 1.0`)
*   [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) (`>= 2.15`)
*   An active Cloud Provider Account (e.g., AWS, OpenStack, OVHcloud)
*   SSH Key pair generated (`~/.ssh/id_rsa` or similar)

---

## Repository Structure

```text
├── terraform/
│   ├── main.tf                 # Main infrastructure resources
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Outputs (IPs, cluster endpoints)
│   └── terraform.tfvars.sample # Sample variable values
└── ansible/
    ├── inventory/
    │   └── hosts.ini           # Generated dynamic or static inventory
    ├── roles/
    │   ├── bastion/            # Bastion hardening tasks
    │   ├── redis/              # Redis installation & tuning
    │   └── postgresql/         # PostgreSQL setup & user management
    └── site.yml                # Main playbook orchestrating all roles