#!/usr/bin/env fish

mkdir -p /tmp/kube-configs
opsops read $HOME/Developer/Homelab/talos/sol/kubeconfig >/tmp/kube-configs/kubeconfig
opsops read $HOME/Developer/Homelab/talos/sol/talosconfig >/tmp/kube-configs/talosconfig
export KUBECONFIG="/tmp/kube-configs/kubeconfig"
export TALOSCONFIG="/tmp/kube-configs/talosconfig"
