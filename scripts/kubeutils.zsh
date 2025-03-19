#!/usr/bin/env zsh

klogs() {
    local pods
    pods=$(kubectl get pods -A --no-headers)

    local selected_pod
    local selected_namespace

    selected_pod=$(echo "$pods" | awk '{print $2}' | fzf \
        --prompt="Loading Pods..." \
        --border-label="Select Pod" \
        --bind "load:change-prompt: " \
        --color=label:bold:blue \
        --border \
        --preview "echo '$pods' | grep '{1}' | awk '{print \"Namespace: \" \$1 \"\nName: \" \$2 \"\nStatus: \" \$4 \"\nAge: \" \$6 }'" )

    selected_namespace=$(echo "$pods" | grep "$selected_pod" | awk '{print $1}')


    kubectl logs -n "$selected_namespace" "$selected_pod" -f
}


kls() {
    kubectl get pods -A --watch
}
