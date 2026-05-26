#!/bin/bash

# generate ssh_host_rsa_key
if [ -f /etc/ssh/ssh_host_rsa_key ]; then
  echo "rsa file already exist, overwriting..."
  ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N "" -y
else
  echo "creating rsa file..."
  ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N ""
fi

# generate ssh_host_ecdsa_key
if [ -f /etc/ssh/ssh_host_ecdsa_key ]; then
  echo "ecdsa file already exist, overwriting..."
  ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N "" -y
else
  echo "creating ecdsa file..."
  ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ""
fi

# generate ssh_host_dsa_key
if [ -f /etc/ssh/ssh_host_dsa_key ]; then
  echo "dsa file already exist, overwriting..."
  ssh-keygen -q -t dsa -f /etc/ssh/ssh_host_dsa_key -N "" -y
else
  echo "creating dsa file..."
  ssh-keygen -q -t dsa -f /etc/ssh/ssh_host_dsa_key -N ""
fi

# generate ssh_host_ed25519_key
if [ -f /etc/ssh/ssh_host_ed25519_key ]; then
  echo "ed25519 file already exist, overwriting..."
  ssh-keygen -q -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N "" -y
else
  echo "creating ed25519 file..."
  ssh-keygen -q -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
fi
