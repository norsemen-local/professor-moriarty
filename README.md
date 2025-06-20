# Academic Infrastructure as Code (IaC) Project

## 1. Overview

Welcome to the Academic Infrastructure as Code (IaC) Project. This project serves as an educational exercise to design and document a model IT infrastructure based on IaC principles and Secure by Design methodologies. It is intended for academic learning and conceptual understanding, not for production deployment.

**Key Documents:**
*   [PHILOSOPHY.md](./PHILOSOPHY.md): Outlines the core principles guiding this project.
*   [PROJECT_PLAN.md](./PROJECT_PLAN.md): Details the project's goals, scope, and plan.

## 2. Purpose and Academic Focus

*   **Primary Purpose:** To provide a comprehensive, documented example of an IT infrastructure designed with an Infrastructure as Code approach.
*   **Academic Goals:**
    *   To learn and apply IaC concepts in a structured manner.
    *   To understand network architecture design, including IP segmentation and zoning.
    *   To explore the integration of various enterprise technologies.
    *   To emphasize "Secure by Design" principles throughout the infrastructure lifecycle.
*   **Disclaimer:** This is a theoretical exercise. No actual infrastructure will be built or deployed.

## 3. Core Technologies

This project's design incorporates the following core technologies:

*   **Orchestration:** Red Hat OpenShift
*   **Operating Systems:**
    *   Linux (Debian 12, Ubuntu Desktop)
    *   Microsoft Windows (Windows Server, Windows 11)
*   **Network Security:** Palo Alto Networks (Firewalls, Broker VMs)

## 4. Network Architecture

The network is designed with multiple zones to ensure segmentation and security, adhering to RFC 1918 private addressing.

### 4.1. Base Network Zones (Site A)

*   **Public Zone (DMZ):** `172.21.55.0/24`
    *   Purpose: Hosts services accessible from the internet, protected by firewalls.
*   **Dirty Zone (Untrusted):** `192.168.0.0/16`
    *   Purpose: Represents an untrusted network, potentially for incoming raw traffic or specific isolated testing. This zone does not follow the incremental scheme.
*   **Users Zone:** `172.21.45.0/24`
    *   Purpose: Network for end-user client machines.
*   **Infrastructure Zone:** `172.21.25.0/24`
    *   Purpose: Hosts core infrastructure services (e.g., domain controllers, logging servers, OpenShift management nodes).
*   **Servers Zone:** `172.21.35.0/24`
    *   Purpose: Hosts application servers and other backend services.
*   **Remote Office Zone:** `172.21.15.0/24`
    *   Purpose: Simulates a remote office network connecting to the main infrastructure.

### 4.2. Network Expansion (Site B, C, etc.)

To accommodate growth or logical separation, additional sites (Site B, Site C, etc.) can be created by incrementing the second octet of the base `172.21.xx.0/24` ranges. The incrementing stops when the second octet reaches `31` (e.g., `172.31.xx.0/24`), ensuring addresses remain within the `172.16.0.0/12` private range. The Dirty Zone (`192.168.0.0/16`) is global and does not follow this specific incremental scheme.

*   **Example: Site B Networks**
    *   Site B Public Zone: `172.22.55.0/24`
    *   Site B Users Zone: `172.22.45.0/24`
    *   Site B Infrastructure Zone: `172.22.25.0/24`
    *   Site B Servers Zone: `172.22.35.0/24`
    *   Site B Remote Office Zone: `172.22.15.0/24`

## 5. Servers and Clients Outline

The following servers and clients are defined within this academic infrastructure. Documentation for each would ideally cover its role, configuration, hardening steps, and IaC management approach.

### 5.1. Clients

*   **client-01 - client-04:**
    *   **Operating System:** Windows 11
    *   **Zone:** Users Zone
    *   **Documentation Notes:** Standard user configurations, security policies, software deployment.
*   **client-05:**
    *   **Operating System:** Ubuntu Desktop
    *   **Zone:** Users Zone
    *   **Documentation Notes:** Standard user configurations, security policies, software deployment.

### 5.2. Windows Servers

*   **dc-01, dc-02 (Domain Controllers):**
    *   **Operating System:** Windows Server (latest version, e.g., 2022)
    *   **Zone:** Infrastructure Zone
    *   **Documentation Notes:** Active Directory Domain Services setup, DNS, DHCP, Group Policy Objects (GPOs) for security, replication.
*   **server-01 - server-03 (General Purpose Windows Servers):**
    *   **Operating System:** Windows Server (latest version)
    *   **Zone:** Servers Zone
    *   **Documentation Notes:** Role-specific configurations (e.g., file server, web server - IIS), security hardening, monitoring.

### 5.3. Linux Servers

*   **server-04 - server-06 (General Purpose Linux Servers):**
    *   **Operating System:** Debian 12
    *   **Zone:** Servers Zone
    *   **Documentation Notes:** Role-specific configurations (e.g., web server - Apache/Nginx, database server), security hardening (SELinux/AppArmor), SSH key management, monitoring.
*   **logger-01 (Centralized Log Server):**
    *   **Operating System:** Debian 12
    *   **Zone:** Infrastructure Zone
    *   **Documentation Notes:** Syslog-ng/Rsyslog configuration, log rotation, secure storage, integration with SIEM (conceptual).
*   **engine-01 (Application Engine Server):**
    *   **Operating System:** Debian 12
    *   **Zone:** Servers Zone
    *   **Documentation Notes:** Hosts specific application engine or backend processing services, security hardening, monitoring.
*   **kubernetes-01 (Kubernetes Node):**
    *   **Operating System:** Debian 12
    *   **Zone:** Servers Zone
    *   **Documentation Notes:** Can serve as a Kubernetes control plane or worker node for container orchestration (potentially standalone or supplemental to OpenShift), security configurations specific to K8s.

### 5.4. Palo Alto Networks Appliances

*   **main-01 (Main Firewall):**
    *   **Type:** Palo Alto Networks Firewall (VM-Series or physical, conceptually)
    *   **Zone:** Edge of Infrastructure, segmenting multiple zones.
    *   **Documentation Notes:** Interface configuration, security policies between zones, NAT policies, VPN configuration, Threat Prevention profiles.
*   **gateway-01 (Gateway Firewall):**
    *   **Type:** Palo Alto Networks Firewall (VM-Series or physical, conceptually)
    *   **Zone:** Typically between Public/DMZ and internal zones, or protecting internet egress.
    *   **Documentation Notes:** Similar to main-01, potentially with more specific edge security functions.
*   **broker-01, broker-02 (Service Broker VMs):**
    *   **Type:** Palo Alto Networks Broker VM appliance
    *   **Zone:** Infrastructure Zone (or as per PANW best practices)
    *   **Documentation Notes:** Configuration for specific PANW services like GlobalProtect, Cortex Data Lake integration, etc.

### 5.5. Red Hat OpenShift

*   **Cluster Nodes (Masters, Workers):**
    *   **Operating System:** Red Hat Enterprise Linux CoreOS (RHCOS) or RHEL.
    *   **Zone:** Likely a dedicated subnet within the Servers Zone or a new OpenShift Zone.
    *   **Documentation Notes:** Installation process (conceptual), network configuration within OpenShift (SDN), integration with infrastructure services (storage, logging, monitoring), security contexts, RBAC.

## 6. Getting Started with IaC Development

As outlined in the [PROJECT_PLAN.md](./PROJECT_PLAN.md), a significant part of this project involves the development of Infrastructure as Code (IaC) scripts. The following provides a general approach:

1.  **IaC Tools:**
    *   **Terraform:** Will be used for provisioning the core infrastructure components such as networks (VPCs/subnets), virtual machines, and foundational firewall rules. It will also handle prerequisites for the Red Hat OpenShift environment where applicable.
    *   **Ansible:** Will be used for configuration management of the provisioned servers. This includes OS hardening, software installation, user account management, and applying specific configurations for server roles.

2.  **Version Control:**
    *   A Git repository will be essential for storing all Terraform code, Ansible playbooks, and supporting documentation. This allows for versioning, collaboration (if applicable in an academic team setting), and tracking changes to the infrastructure definitions.

3.  **Development Workflow (High-Level):**
    *   **Terraform Development:**
        *   Initialize Terraform in the project directory (`terraform init`).
        *   Develop modules for repeatable components (e.g., a server module, a network module).
        *   Write root configuration files to define the overall infrastructure, utilizing the modules.
        *   Use `terraform plan` to review changes before applying.
        *   Apply changes with `terraform apply`.
    *   **Ansible Development:**
        *   Structure playbooks and roles logically (e.g., a common role for base setup, specific roles for applications like web servers or domain controllers).
        *   Utilize an inventory file (potentially dynamically generated by Terraform) to target hosts.
        *   Develop tasks within roles to achieve desired state configurations.
        *   Test playbooks thoroughly, using `--check` mode (dry run) before applying.
    *   **Integration:** Explore methods for integrating Terraform and Ansible, such as Terraform outputting an inventory for Ansible or Ansible being triggered as a provisioner by Terraform.

4.  **Environment Setup:**
    *   Ensure Terraform and Ansible are installed on a suitable development machine or control node.
    *   If using cloud platforms for simulation, configure necessary CLI tools and authentication. For on-premise virtualization, ensure hypervisor access and necessary tooling.

Refer to the `PROJECT_PLAN.md` for more detailed tasks related to IaC development. The actual Terraform and Ansible code will be developed as part of the subsequent project phases.

## 7. Contribution

This is an academic project and primarily for illustrative purposes. Contributions in the form of suggestions or corrections to the documentation are welcome via issues or pull requests (if a repository is set up).

---

This README provides a foundational overview. Each component and concept mentioned would require significantly more detailed documentation in a real-world scenario.
```
