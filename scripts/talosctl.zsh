#!/usr/bin/env zsh

# Function to display and launch Talos dashboard with all nodes
talos_dashboard() {
    # Get all cluster members
    echo "🔍 Fetching cluster members..."
    members_output=$(talosctl get members -o yaml)

  # Parse member hostnames
  control_hostnames=()
  worker_hostnames=()
  nodes_args=()

  while IFS= read -r hostname; do
      if [ -n "$hostname" ]; then
          # Check if it's a control plane node
          if [[ "$hostname" == *"control"* ]]; then
              control_hostnames+=("$hostname")
          else
              worker_hostnames+=("$hostname")
          fi
          # Add to nodes_args array
          nodes_args+=("-n" "$hostname")
      fi
  done < <(echo "$members_output" | grep "hostname:" | awk '{print $2}')

  # If no members were found, run dashboard without -n flags
  if [ ${#nodes_args[@]} -eq 0 ]; then
      echo "⚠️ No cluster members found. Running dashboard without node specification."
      talosctl dashboard
  else
      echo "🚀 Starting dashboard with nodes:"

    # Display control plane nodes first with special marker
    for hostname in "${control_hostnames[@]}"; do
        echo "* 🎮 $hostname"
    done

    # Display worker nodes
    for hostname in "${worker_hostnames[@]}"; do
        echo "* 🖥️ $hostname"
    done

    # Run the dashboard with proper array expansion
    talosctl dashboard "${nodes_args[@]}"

    # Return with a clean exit code
    return 0
  fi
}
