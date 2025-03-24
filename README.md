# 🏠 Homelab Infrastructure

A modern infrastructure setup for home lab environments using Kubernetes, Talos, and Flux CD, managed with Nix development shells.

## 🌟 Overview

This repository contains the configuration and tools needed to manage a complete homelab Kubernetes infrastructure. It uses Talos Linux for the underlying OS, Flux CD for GitOps, and Nix with direnv for seamless development environments.

## 🚀 Getting Started

### 📋 Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled
- [direnv](https://direnv.net/) for automatic environment activation
- Git

### ⚡ Quick Start

1. Clone this repository with submodules:
   ```bash
   git clone --recursive https://github.com/yourusername/homelab.git
   cd homelab
   ```

2. Allow direnv to activate the environment:
   ```bash
   direnv allow
   ```

3. Decrypt sensitive files:
   ```bash
   git secret reveal
   ```

4. Access your infrastructure:
   ```bash
   # Use kubectl wrapper
   k get nodes
   
   # Use talosctl wrapper
   t get nodes
   ```

## 🛠️ Development Environment

This project uses Nix flakes and direnv to provide a consistent, reproducible environment with all required tools pre-configured.

### ✨ Features

- **🔄 Automatic Environment Activation**: direnv automatically loads the development environment when you enter the directory
- **📦 Automated Tool Installation**: All required tools (kubectl, talosctl, flux, helm, etc.) are automatically installed
- **⚙️ Configuration Management**: KUBECONFIG and TALOSCONFIG paths are automatically set
- **🔑 Credential Management**: GitHub credentials are automatically fetched from 1Password
- **🔒 Secure Secret Management**: Talos configuration files are encrypted/decrypted using git-secrets

### 🧰 Available Commands

- `k`: Shorthand for kubectl with proper configuration
- `t`: Shorthand for talosctl with proper configuration
- `git secret hide`: Encrypt sensitive files
- `git secret reveal`: Decrypt sensitive files

## 🖥️ Talos Configuration

The repository includes configuration for a Talos-based Kubernetes cluster:

- `talos/sol/controlplane.yaml`: Configuration for control plane nodes
- `talos/sol/worker.yaml`: Configuration for worker nodes
- `talos/sol/talosconfig`: Client configuration for talosctl

These files are managed using git-secrets, with encrypted versions stored as `.secret` files:
- `talos/sol/controlplane.yaml.secret`
- `talos/sol/worker.yaml.secret`
- `talos/sol/talosconfig.secret`

To work with these files:
```bash
# Decrypt all secret files
git secret reveal

# After making changes, encrypt them again
git secret hide
```

## 🏗️ Architecture

The homelab infrastructure is organized as follows:

```
├── apps                       # 📱 Applications running on the cluster (submodule)
│   └── app-hello-world        # Example application
├── homelab                    # 🏠 Homelab-specific configuration
│   ├── clusters               # Cluster configurations
│   │   └── hl-sol-c1          # Main homelab cluster
│   │       ├── flux-system    # 🔄 Flux CD setup (submodule)
│   │       ├── hello-world    # Example application configuration
│   │       └── infrastructure # Core infrastructure components
├── talos                      # ⚙️ Talos OS configuration
│   └── sol                    # Configuration for 'sol' cluster
│       ├── controlplane.yaml         # Decrypted configuration
│       ├── controlplane.yaml.secret  # Encrypted configuration
│       ├── talosconfig               # Decrypted configuration
│       ├── talosconfig.secret        # Encrypted configuration
│       ├── worker.yaml               # Decrypted configuration
│       └── worker.yaml.secret        # Encrypted configuration
└── flake.nix                  # 🧪 Nix development environment
```

## 🧩 Infrastructure Components

The cluster includes the following key infrastructure components:

- **🔄 Flux CD**: GitOps controller for managing the cluster (configured as a submodule)
- **💾 Longhorn**: Distributed block storage for persistent volumes
- **🚪 Traefik**: Ingress controller for external access
- **⚡ Capacitor**: Custom component for resource management

## 📦 Submodules

This project uses Git submodules to manage related components:

- **📱 apps/**: Contains application definitions deployed to the cluster
- **🔄 flux-system/**: Contains the Flux CD configuration
- **🔌 Additional components**: Each maintained in their own repository for better modularity

To update all submodules:

```bash
git submodule update --remote
```

## 🤝 Contributing

1. Make sure direnv is enabled with `direnv allow`
2. Decrypt sensitive files with `git secret reveal`
3. Make your changes
4. Test with the provided tools
5. Encrypt changed sensitive files with `git secret hide`
6. Commit your changes
7. Update submodules if needed

## 🔧 Setting up git-secrets for a New User

To add yourself as a user who can decrypt secrets:

1. Make sure you have your GPG key pair set up
2. Ask an existing repo member to add your public key:
   ```bash
   git secret tell your@email.com
   ```
3. Re-encrypt the files to include your key:
   ```bash
   git secret hide
   ```
4. After these changes are pushed, you'll be able to decrypt the files with `git secret reveal`

## 🔍 Troubleshooting

- **🔑 1Password Integration**: If you encounter issues with 1Password, run `op signin` manually
- **🔒 git-secrets Issues**: 
  - If `git secret reveal` fails, make sure your GPG key is properly imported and trusted
  - Check if you're listed as a user with `git secret whoknows`
- **⚙️ direnv Issues**: If direnv isn't activating properly, check your `.envrc` file and try running `direnv reload`
- **📦 Submodule Problems**: If submodules aren't loading, try `git submodule update --init --recursive`
- **🧪 Nix Environment**: If the Nix environment isn't working as expected, try `rm -rf .direnv` and then `direnv allow` again
