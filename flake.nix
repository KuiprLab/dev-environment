{
  description = "Kubernetes development environment with kubectl, talosctl, and fluxcd";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };
      in
      {
        devShells.default = pkgs.mkShell {
                              inheritShellHook = true;
          buildInputs = with pkgs; [
            kubectl
            talosctl
            fluxcd
            
            # Additional useful tools
            kubernetes-helm
            k9s
            kubectx
            jq
            yq-go
          ];

          shellHook = ''
            # Preserve the current shell and its settings
            export SHELL="$SHELL"
            # Set up environment variables
            export KUBECONFIG="$HOME/Developer/Homelab/infra-sol/kubeconfig"
            export TALOSCONFIG="$HOME/Developer/Homelab/infra-sol/taloscconfig"
            
            # GitHub credentials from 1Password
            if command -v op &>/dev/null; then
              echo "Fetching GitHub credentials from 1Password..."
              if op account get &>/dev/null; then
                # Already signed in
                export GITHUB_USERNAME=$(op item get "GitHub" --fields username)
                export GITHUB_TOKEN=$(op item get "GitHub" --fields token --reveal)
              else
                echo "⚠️  Please sign in to 1Password CLI first:"
                echo "    op signin"
                echo "Then re-enter the shell"
              fi
            else
              echo "⚠️  1Password CLI not found in PATH or not properly configured"
              echo "    GitHub credentials will not be available"
            fi
            
            echo "Kubernetes Development Environment"
            echo "=================================="
            echo "kubectl version: $(kubectl version --client --short 2>/dev/null || echo 'not installed')"
            echo "talosctl version: $(talosctl version --short 2>/dev/null || echo 'not installed')"
            echo "flux version: $(flux --version 2>/dev/null || echo 'not installed')"
            echo ""
            echo "Environment variables set:"
            echo "- KUBECONFIG: $KUBECONFIG"
            echo "- TALOSCONFIG: $TALOSCONFIG"
            if [[ -n "$GITHUB_USERNAME" && -n "$GITHUB_TOKEN" ]]; then
              echo "- GITHUB_USERNAME: $GITHUB_USERNAME (from 1Password)"
              echo "- GITHUB_TOKEN: $GITHUB_USERNAME (from 1Password)"
            else
              echo "- GITHUB_USERNAME: not set"
              echo "- GITHUB_TOKEN: not set"
              echo ""
              echo "NOTE: To set GitHub credentials, make sure you have a 'GitHub' item"
              echo "      in your 1Password vault with 'username' and 'token' fields."
            fi
          '';
        };
      }
    );
}
