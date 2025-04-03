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
                kctlWrapper = pkgs.writeShellScriptBin "k" ''
          #!/usr/bin/env bash
          # export KUBECONFIG="$HOME/Developer/Homelab/infra-sol/kubeconfig"
          kubecolor "$@"
          '';

          # Create talosctl wrapper to ensure it uses correct config
          talosWrapper = pkgs.writeShellScriptBin "t" ''
          #!/usr/bin/env bash
          # export TALOSCONFIG="$HOME/Developer/Homelab/infra-sol/taloscconfig"
          talosctl "$@"
          '';


         fluxstat = pkgs.writeShellScriptBin "fls" ''
             watch flux get all -A
          '';


         klogs = pkgs.writeShellScriptBin "klogs" ''

          pods=$(kubectl get pods -A --no-headers)
          selected_pod=$(echo "$pods" | awk '{print $2}' | fzf \
              --prompt="Loading Pods..." \
              --border-label="Select Pod" \
              --bind "load:change-prompt: " \
              --color=label:bold:blue \
              --border \
              --preview "echo '$pods' | grep '{1}' | awk '{print \"Namespace: \" \$1 \"\nName: \" \$2 \"\nStatus: \" \$4 \"\nAge: \" \$6 }'" )

          selected_namespace=$(echo "$pods" | grep "$selected_pod" | awk '{print $1}')
          kubectl logs -n "$selected_namespace" "$selected_pod" -f
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
                        fzf
                        git-secret
                       _1password-cli
                        watch
                        kubecolor
                        fluxcd

                        # Include our credential fetching script
                        kctlWrapper
                        talosWrapper
                        fluxstat
                        klogs

                        # Include timeout utility for credential fetching
                        coreutils
                    ];
                    shellHook = ''
            export KUBECONFIG="$HOME/Developer/Homelab/talos/sol/kubeconfig"
            export TALOSCONFIG="$HOME/Developer/Homelab/talos/sol/talosconfig"
            . <(flux completion zsh)
                    '';
                };
            }
        );
}
