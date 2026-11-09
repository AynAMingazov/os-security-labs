#!/usr/bin/env bash
# Lab 4: scan modes of nmap. Only my own server (localhost) was scanned.
T=127.0.0.1
nmap --version | head -1
nmap -sT -v $T          # TCP connect: full handshake
sudo nmap -sS $T        # SYN: half-open, needs root
sudo nmap -sF $T        # FIN   -> open|filtered for open ports
sudo nmap -sX $T        # Xmas  -> open|filtered
sudo nmap -sN $T        # NULL  -> open|filtered
sudo nmap -sO $T        # IP protocols
sudo nmap -sA $T        # ACK: unfiltered = no packet filter on the path
ss -tlnp                # compare with listening sockets
