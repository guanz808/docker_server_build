#!/bin/bash

# Check if the "docker" group exists
if getent group docker >/dev/null; then
  echo "Group 'docker' exists."

  # Check if current user is a member
  if id -nG | grep -q docker; then
    echo "Current user is already a member of the 'docker' group."
    exit 0
  else
    echo "Adding current user to the 'docker' group..."
    sudo usermod -aG docker $USER
    echo "Done."
  fi
else
  echo "Group 'docker' does not exist. Creating it..."
  sudo groupadd docker
  echo "Group 'docker' created."
  echo "Adding current user to the 'docker' group..."
  sudo usermod -aG docker $USER
  echo "Done."
fi

# restarts the shell to apply the group membership
newgrp docker