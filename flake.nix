{
  description = "A basic flake with a shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.systems.url = "github:nix-systems/default";
  inputs.flake-utils = {
    url = "github:numtide/flake-utils";
    inputs.systems.follows = "systems";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config = {allowUnfree = true;};
        };


        # Create a script to fetch GitHub credentials with a timeout
        fetchGitHubCredentials = pkgs.writeShellScriptBin "fetch-github-creds" ''
          #!/usr/bin/env bash

          # Cache file for GitHub credentials
          CREDS_CACHE="$HOME/.cache/kube-dev-shell/github-creds"
          mkdir -p "$(dirname "$CREDS_CACHE")"

          # Check if cache exists and is less than 24 hours old
          if [[ -f "$CREDS_CACHE" ]] && [[ $(find "$CREDS_CACHE" -mtime -1 2>/dev/null) ]]; then
            # echo "Using cached GitHub credentials..." >&2
          echo ""
          else
            echo "Fetching GitHub credentials from 1Password..." >&2

            # Use timeout to prevent hanging
            if command -v op &>/dev/null; then
              # Get credentials with a timeout of 5 seconds
              if timeout 5 op account list &>/dev/null; then
                username=$(timeout 5 op item get "GitHub" --fields username 2>/dev/null)
                token=$(timeout 5 op item get "GitHub" --fields token --reveal 2>/dev/null)

                if [[ -n "$username" && -n "$token" ]]; then
                  echo "export GITHUB_USERNAME=\"$username\"" > "$CREDS_CACHE"
                  echo "export GITHUB_TOKEN=\"$token\"" >> "$CREDS_CACHE"
                  chmod 600 "$CREDS_CACHE"
                else
                  echo "⚠️  Failed to retrieve GitHub credentials from 1Password" >&2
                  echo "export GITHUB_USERNAME=\"\"" > "$CREDS_CACHE"
                  echo "export GITHUB_TOKEN=\"\"" >> "$CREDS_CACHE"
                  chmod 600 "$CREDS_CACHE"
                fi
              else
                echo "⚠️  Not signed in to 1Password or timed out. Run 'op signin' first." >&2
                echo "export GITHUB_USERNAME=\"\"" > "$CREDS_CACHE"
                echo "export GITHUB_TOKEN=\"\"" >> "$CREDS_CACHE"
                chmod 600 "$CREDS_CACHE"
              fi
            else
              echo "⚠️  1Password CLI not found in PATH" >&2
              echo "export GITHUB_USERNAME=\"\"" > "$CREDS_CACHE"
              echo "export GITHUB_TOKEN=\"\"" >> "$CREDS_CACHE"
              chmod 600 "$CREDS_CACHE"
            fi
          fi

          # Output the cache file path
          echo "$CREDS_CACHE"
        '';

        kctlWrapper = pkgs.writeShellScriptBin "k" ''
          #!/usr/bin/env bash
          # export KUBECONFIG="$HOME/Developer/Homelab/infra-sol/kubeconfig"
          kubectl "$@"
        '';

        # Create talosctl wrapper to ensure it uses correct config
        talosWrapper = pkgs.writeShellScriptBin "t" ''
          #!/usr/bin/env bash
          # export TALOSCONFIG="$HOME/Developer/Homelab/infra-sol/taloscconfig"
          talosctl "$@"
        '';
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            kubectl
            talosctl
            fluxcd

            # Additional useful tools
            kubernetes-helm
            k9s
            kubectx
            jq
            yq-go

            # Include our credential fetching script
            kctlWrapper
            talosWrapper
            fetchGitHubCredentials

            # Include timeout utility for credential fetching
            coreutils
          ];
          shellHook = ''
            # git secret tell -m 2> /dev/null
            # Set up environment variables
            export KUBECONFIG="$HOME/Developer/Homelab/talos/sol/kubeconfig"
            export TALOSCONFIG="$HOME/Developer/Homelab/talos/sol/talosconfig"

            # Initialize credential variables
            export GITHUB_USERNAME=""
            export GITHUB_TOKEN=""

            # Get credentials without blocking
            # This runs in the background and completes before displaying info
            CREDS_FILE=$(fetch-github-creds)
            if [[ -f "$CREDS_FILE" ]]; then
              source "$CREDS_FILE"
            fi

            # To manually refresh credentials, run:
            # echo "To manually refresh credentials, run: source \$(fetch-github-creds)"
          '';
        };
      }
    );
}
