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
          kubectl "$@"
        '';

        # Create talosctl wrapper to ensure it uses correct config
        talosWrapper = pkgs.writeShellScriptBin "t" ''
          #!/usr/bin/env bash
          # export TALOSCONFIG="$HOME/Developer/Homelab/infra-sol/taloscconfig"
          talosctl "$@"
        '';


        k9sWrapper = pkgs.writeShellScriptBin "kk" ''
          k9s "$@"
          '';
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            kubectl
            talosctl
            fluxcd
python313Packages.urwid

            # Additional useful tools
            kubernetes-helm
            k9s
            kubectx
            jq
            yq-go

            # Include our credential fetching script
            kctlWrapper
            talosWrapper
            k9sWrapper


            # Include timeout utility for credential fetching
            coreutils
          ];
          shellHook = ''
            # git secret tell -m 2> /dev/null
            # Set up environment variables
            export KUBECONFIG="$HOME/Developer/Homelab/talos/sol/kubeconfig"
            export TALOSCONFIG="$HOME/Developer/Homelab/talos/sol/talosconfig"

          '';
        };
      }
    );
}
