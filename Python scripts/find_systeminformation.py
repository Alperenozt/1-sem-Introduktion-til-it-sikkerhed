import socket

# Hent hostname
hostname = socket.gethostname()

# Hent lokal IP-adresse
local_ip = socket.gethostbyname(hostname)

print("Hostname:", hostname)
print("Lokal IP-adresse:", local_ip)
