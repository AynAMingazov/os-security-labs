#!/usr/bin/env bash
# Lab 4: block ICMP with iptables and restore it.
# On a remote server: make sure SSH is allowed BEFORE adding any DROP rules.
set -e
sudo iptables -C INPUT -p tcp --dport 22 -j ACCEPT 2>/dev/null || sudo iptables -I INPUT 1 -p tcp --dport 22 -j ACCEPT

sudo iptables -A INPUT   -p icmp --icmp-type echo-request -j DROP
sudo iptables -A FORWARD -p icmp -j DROP
sudo iptables -L -n -v --line-numbers
# from another host: ping -> 100% packet loss

sudo iptables -D INPUT   -p icmp --icmp-type echo-request -j DROP
sudo iptables -D FORWARD -p icmp -j DROP
# ping works again
