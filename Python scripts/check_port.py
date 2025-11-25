import socket

def check_port(host, port, timeout=3):
    """
    Tjekker om en specifik port er åben på en host.
    
    Args:
        host (str): Hostname eller IP-adresse
        port (int): Portnummer der skal tjekkes
        timeout (int): Timeout i sekunder (standard: 3)
    
    Returns:
        bool: True hvis porten er åben, False hvis lukket
    """
    try:
        # Opret en socket med IPv4 og TCP
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        
        # Sæt timeout for at undgå at vente for længe
        sock.settimeout(timeout)
        
        # Forsøg at oprette forbindelse
        result = sock.connect_ex((host, port))
        
        # Luk socket efter brug
        sock.close()
        
        # connect_ex returnerer 0 hvis forbindelsen lykkedes
        return result == 0
        
    except socket.gaierror:
        print(f"Fejl: Kunne ikke finde host '{host}'")
        return False
    except socket.error as e:
        print(f"Socket fejl: {e}")
        return False

# Test funktionen
if __name__ == "__main__":
    # Test Google på port 443 (HTTPS)
    host = "google.com"
    port = 443
    
    print(f"Tjekker {host} på port {port}...")
    
    if check_port(host, port):
        print(f"✓ Port {port} er ÅBEN på {host}")
    else:
        print(f"✗ Port {port} er LUKKET på {host}")
    
    # Test flere eksempler
    print("\n--- Flere tests ---")
    tests = [
        ("google.com", 80),    # HTTP
        ("google.com", 443),   # HTTPS
        ("google.com", 22),    # SSH (sandsynligvis lukket)
        ("localhost", 80),     # Din lokale maskine
    ]
    
    for test_host, test_port in tests:
        status = "ÅBEN" if check_port(test_host, test_port) else "LUKKET"
        print(f"{test_host}:{test_port} - {status}")