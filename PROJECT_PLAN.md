# Project Plan: Academic IaC Environment

## 1. Introduction

This document outlines the project plan for creating an academic Infrastructure as Code (IaC) environment. The project focuses on demonstrating IaC principles, secure by design methodologies, and the integration of core technologies including Red Hat OpenShift, Linux, Windows, and Palo Alto Networks firewalls. This plan is for academic and illustrative purposes only.

## 2. Project Goals

*   **Primary Goal:** To design and document a model IT infrastructure using IaC principles.
*   **Educational Objectives:**
    *   Provide a practical learning platform for IaC, network architecture, and cybersecurity concepts.
    *   Understand the configuration and interaction of Red Hat OpenShift, Palo Alto Networks firewalls, and various server operating systems (Linux, Windows).
    *   Illustrate secure by design principles in a tangible infrastructure setup.
*   **Demonstrate IaC Benefits:** Showcase reproducibility, version control, and automation in infrastructure management.

## 3. Scope

### 3.1. In Scope

*   **Document Creation:**
    *   Philosophy Document (PHILOSOPHY.md)
    *   Project Plan (this document, PROJECT_PLAN.md)
    *   README.md (including network and server/client outlines)
*   **Conceptual Design:**
    *   Detailed network architecture design, including IP addressing for all zones.
    *   Server and client roles and operating system specifications.
    *   Conceptual placement of Palo Alto Networks firewalls (main-01, gateway-01) and broker VMs (broker-01, broker-02).
    *   Conceptual integration of Red Hat OpenShift within the infrastructure.
*   **IaC Strategy and Design:**
    *   High-level strategy and detailed design for how IaC tools (Terraform, Ansible) will be used to provision and manage the defined infrastructure. This underpins the IaC Code Development.
*   **IaC Code Development:**
    *   Development of functional Terraform plans for provisioning defined infrastructure (networks, VMs, basic firewall rules).
    *   Development of Ansible playbooks for server configuration (e.g., hardening, base software installation, user management).
    *   Utilizing Red Hat OpenShift as a base technology, implying IaC will manage nodes or interact with OpenShift where appropriate.
*   **Security Outline:**
    *   Description of how "Secure by Design" principles will be applied, including network segmentation policies, logging, and basic hardening concepts for servers.

### 3.2. Out of Scope

*   **Physical Hardware Implementation:** No procurement or setup of physical hardware.
*   **Software Licensing and Installation:** No actual installation or licensing of software (OpenShift, Windows, Palo Alto Networks OS) beyond what's needed for IaC development in a simulated/dev environment.
*   **Application Deployment:** No deployment of actual applications onto OpenShift or servers.
*   **Performance Testing or Benchmarking:** No performance evaluation of the designed infrastructure.
*   **Production Readiness:** The resulting design and code are not intended for production deployment and will remain for academic/demonstration purposes.

## 4. Deliverables

1.  **PHILOSOPHY.md:** A document detailing the project's guiding principles. (Completed)
2.  **PROJECT_PLAN.md:** This project plan document.
3.  **README.md:** A comprehensive overview document containing:
    *   Project purpose and academic focus.
    *   List of core technologies.
    *   Detailed network architecture (zones, IP ranges, incrementing scheme).
    *   List of all specified servers and clients with their OS and a note on documentation needs.
4.  **Terraform Code:** A collection of Terraform plans and modules for provisioning the defined infrastructure (networks, VMs, basic firewall configurations, OpenShift prerequisites as applicable).
5.  **Ansible Playbooks:** A collection of Ansible roles and playbooks for configuring servers (hardening, software installation, user management, role-specific setups).

## 5. Project Timeline (Illustrative)

This is a conceptual timeline for an academic project of this nature.

*   **Phase 1: Foundation & Planning (Complete)**
    *   Task 1.1: Define Project Scope and Objectives.
    *   Task 1.2: Develop Philosophy Document.
    *   Task 1.3: Develop Project Plan Document.
*   **Phase 2: Design & Documentation**
    *   Task 2.1: Create README.md with initial structure.
    *   Task 2.2: Detail Network Architecture (zones, IP schema) in README.md.
    *   Task 2.3: Document Server and Client Specifications in README.md.
    *   Task 2.4: Outline basic security policies and IaC strategy conceptually in supporting documents.
*   **Phase 3: IaC Development - Terraform**
    *   Task 3.1: Set up Terraform development environment (local or CI/CD base).
    *   Task 3.2: Develop Terraform modules for network infrastructure (VPCs, subnets, routing).
    *   Task 3.3: Develop Terraform configurations for provisioning virtual machines (clients, servers).
    *   Task 3.4: Develop Terraform configurations for basic firewall rules (Palo Alto Networks, conceptual or VM-Series).
    *   Task 3.5: Develop Terraform configurations for OpenShift cluster prerequisites or node provisioning (as applicable).
    *   Task 3.6: Test and validate Terraform plans.
*   **Phase 4: IaC Development - Ansible**
    *   Task 4.1: Set up Ansible development environment (control node).
    *   Task 4.2: Develop Ansible roles for base server hardening (Linux & Windows).
    *   Task 4.3: Develop Ansible playbooks for common software installation (e.g., web servers, utilities).
    *   Task 4.4: Develop Ansible playbooks for user management and security configurations.
    *   Task 4.5: Develop Ansible playbooks for configuring specific server roles (e.g., logger-01, dc-01).
    *   Task 4.6: Integrate Ansible with Terraform provisioning where appropriate (e.g., dynamic inventory).
    *   Task 4.7: Test and validate Ansible playbooks.
*   **Phase 5: Review & Finalization**
    *   Task 5.1: Review all documents and IaC code for consistency, clarity, and completeness.
    *   Task 5.2: Document usage of Terraform and Ansible code.
    *   Task 5.3: Finalize all deliverables for submission.

## 6. Resources (Conceptual)

*   **Personnel:** Project lead/student.
*   **Tools & Technologies (for design):** Markdown editor, conceptual diagramming tools (optional).
*   **References:** Official documentation for Red Hat OpenShift, Palo Alto Networks, Windows, Debian, Ubuntu. RFC 1918 for private IP addressing.

## 7. Assumptions

*   Access to relevant documentation for the specified technologies is available.
*   The focus is on the design and documentation, not implementation.

## 8. Risk Management (Academic Context)

*   **Risk:** Scope creep (adding more detail than originally planned).
    *   **Mitigation:** Adhere strictly to the defined scope and deliverables.
*   **Risk:** Misinterpretation of technical concepts.
    *   **Mitigation:** Refer to official documentation and seek clarification where necessary.
*   **Risk:** Incomplete documentation.
    *   **Mitigation:** Follow the deliverable list and review thoroughly.

This project plan provides a roadmap for the design and documentation of the academic IaC environment.
```
