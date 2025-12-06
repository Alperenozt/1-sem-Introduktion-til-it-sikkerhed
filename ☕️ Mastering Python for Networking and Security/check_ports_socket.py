#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
Port Scanner - FORBEDRET VERSION
Baseret på Kapitel 3: Socket Programming
Fra: Mastering Python for Networking and Security (2nd Edition)

Dette script demonstrerer port scanning med socket programmering.
Til brug i Kali Linux til penetrationstest og sikkerhedsanalyse.
"""

import socket
import threading
from datetime import datetime

# ────────────── FARVER ──────────────
GREEN  = "\033[92m"
RED    = "\033[91m"
YELLOW = "\033[93m"
CYAN   = "\033[96m"
MAGENTA= "\033[95m"
BOLD   = "\033[1m"
RESET  = "\033[0m"

# Liste over typiske porte (god til localhost-test)
PORTS = [
    21, 22, 23, 25, 53, 80, 81, 110, 135, 139, 143,
    443, 445, 993, 995, 1723, 3306, 3389, 5432, 5900,
    8000, 8080, 8081, 8443, 8888, 9000, 10000, 2222, 4444
]

def get_service(port):
    try:
        return socket.getservbyport(port)
    except:
        return "ukendt"

def grab_banner(port):
    try:
        s = socket.socket()
        s.settimeout(1.2)
        s.connect(("127.0.0.1", port))
        s.send(b"\r\n")
        banner = s.recv(200).decode("utf-8", errors="ignore").strip().replace("\n", " ")
        s.close()
        return f" → {YELLOW}{banner}{RESET}" if banner else ""
    except:
        return ""

def scan(port):
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(0.9)
        result = sock.connect_ex(("127.0.0.1", port))
        if result == 0:
            service = get_service(port)
            banner = grab_banner(port)
            print(f"{GREEN}  ✔ Port {port:5} → ÅBEN    {CYAN}{service:<15}{RESET}{banner}")
        sock.close()
    except:
        pass

# ────────────── START ──────────────
print(f"{MAGENTA}{BOLD}")
print("   ╔══════════════════════════════════════════╗")
print("   ║      LOCALHOST PORT SCANNER v2.0         ║")
print("   ║        Kun til 127.0.0.1 – Kali Linux    ║")
print("   ╚══════════════════════════════════════════╝")
print(f"{RESET}{YELLOW}   Baseret på Kapitel 3 – Socket Programming")
print(f"   Fra: Mastering Python for Networking and Security (2nd Edition){RESET}\n")

print(f"{CYAN}[*] Starttid: {datetime.now():%Y-%m-%d %H:%M:%S}{RESET}")
print(f"{CYAN}[+] Scanner {len(PORTS)} almindelige porte på localhost...{RESET}\n")

# Multithreading – lynhurtig!
threads = []
for port in PORTS:
    t = threading.Thread(target=scan, args=(port,))
    t.daemon = True
    t.start()
    threads.append(t)

for t in threads:
    t.join()

print(f"\n{GREEN}{BOLD}   ╔══════════════════════════════════════════╗")
print(f"   ║           SCANNING FÆRDIG!               ║")
print(f"   ╚══════════════════════════════════════════╝{RESET}")
