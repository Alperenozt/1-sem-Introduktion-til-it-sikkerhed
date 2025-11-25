import socket
import sys
from datetime import datetime

# Almindelige porte og deres tjenester
ALMINDELIGE_PORTE = {
    20: "FTP Data",
    21: "FTP Control",
    22: "SSH",
    23: "Telnet",
    25: "SMTP",
    53: "DNS",
    80: "HTTP",
    110: "POP3",
    143: "IMAP",
    443: "HTTPS",
    445: "SMB",
    3306: "MySQL",
    3389: "RDP",
    5432: "PostgreSQL",
    8080: "HTTP Proxy",
    8443: "HTTPS Alt"
}

def scan_port(ip, port, timeout=1):
    """
    Scanner en enkelt port på en IP-adresse.
    
    Args:
        ip (str): IP-adressen der skal scannes
        port (int): Portnummeret der skal tjekkes
        timeout (int): Timeout i sekunder
    
    Returns:
        bool: True hvis porten er åben, False hvis lukket
    """
    try:
        # Opret socket med IPv4 og TCP
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(timeout)
        
        # Forsøg at forbinde
        result = sock.connect_ex((ip, port))
        sock.close()
        
        # 0 = forbindelse lykkedes = port er åben
        return result == 0
    
    except socket.gaierror:
        print(f"❌ Kunne ikke resolve hostname: {ip}")
        return False
    except socket.error:
        return False
    except KeyboardInterrupt:
        print("\n\n⚠️  Scanning afbrudt af bruger!")
        sys.exit()

def scan_porte(ip, porte, timeout=1):
    """
    Scanner flere porte på en IP-adresse.
    
    Args:
        ip (str): IP-adressen der skal scannes
        porte (list): Liste af portnumre der skal scannes
        timeout (int): Timeout i sekunder per port
    
    Returns:
        dict: Dictionary med åbne og lukkede porte
    """
    aabne_porte = []
    lukkede_porte = []
    
    print(f"\n{'='*70}")
    print(f"🔍 Scanner {ip}")
    print(f"📊 Antal porte at scanne: {len(porte)}")
    print(f"🕐 Starttidspunkt: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("="*70 + "\n")
    
    try:
        # Forsøg at få hostname
        try:
            hostname = socket.gethostbyaddr(ip)[0]
            print(f"📡 Hostname: {hostname}\n")
        except:
            print(f"📡 Hostname: Ikke fundet\n")
        
        print("Scanning...")
        print("-" * 70)
        
        for i, port in enumerate(porte, 1):
            # Vis fremskridt
            if i % 10 == 0 or i == len(porte):
                print(f"Fremskridt: {i}/{len(porte)} porte scannet...", end='\r')
            
            if scan_port(ip, port, timeout):
                tjeneste = ALMINDELIGE_PORTE.get(port, "Ukendt tjeneste")
                aabne_porte.append((port, tjeneste))
        
        print(" " * 70, end='\r')  # Ryd fremskridtslinje
        
    except KeyboardInterrupt:
        print("\n\n⚠️  Scanning afbrudt!")
        return {"aabne": aabne_porte, "lukkede": lukkede_porte}
    
    # Alle ikke-åbne porte er lukkede
    lukkede_porte = [p for p in porte if p not in [port for port, _ in aabne_porte]]
    
    return {"aabne": aabne_porte, "lukkede": lukkede_porte}

def vis_resultater(resultater, ip):
    """
    Viser scanning resultaterne.
    
    Args:
        resultater (dict): Resultater fra scanning
        ip (str): IP-adressen der blev scannet
    """
    print("\n" + "="*70)
    print("📊 SCANNING RESULTATER")
    print("="*70)
    
    aabne = resultater["aabne"]
    lukkede = resultater["lukkede"]
    
    print(f"\n🎯 Target: {ip}")
    print(f"✅ Åbne porte: {len(aabne)}")
    print(f"❌ Lukkede porte: {len(lukkede)}")
    
    if aabne:
        print("\n" + "-"*70)
        print("ÅBNE PORTE:")
        print("-"*70)
        print(f"{'Port':<10} {'Tjeneste':<20} {'Status':<10}")
        print("-"*70)
        
        for port, tjeneste in sorted(aabne):
            print(f"{port:<10} {tjeneste:<20} {'ÅBEN':<10}")
    else:
        print("\n❌ Ingen åbne porte fundet")
    
    print("\n" + "="*70)
    print(f"🕐 Sluttidspunkt: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("="*70)

def parse_port_range(port_string):
    """
    Parser port streng til liste af porte.
    Understøtter: "80", "80,443,8080", "80-85", "20-25,80,443"
    
    Args:
        port_string (str): Streng med porte
    
    Returns:
        list: Liste af portnumre
    """
    porte = []
    
    # Split på komma
    dele = port_string.split(',')
    
    for del in dele:
        del = del.strip()
        
        if '-' in del:
            # Range (f.eks. "80-85")
            try:
                start, slut = del.split('-')
                porte.extend(range(int(start), int(slut) + 1))
            except:
                print(f"⚠️  Ugyldigt range: {del}")
        else:
            # Enkelt port
            try:
                porte.append(int(del))
            except:
                print(f"⚠️  Ugyldig port: {del}")
    
    return sorted(list(set(porte)))  # Fjern duplikater og sorter

def quick_scan_presets():
    """
    Foruddefinerede scanning profiler.
    """
    return {
        "1": {
            "navn": "Hurtig scan (10 almindelige porte)",
            "porte": [21, 22, 23, 25, 80, 110, 143, 443, 3389, 8080]
        },
        "2": {
            "navn": "Web server scan",
            "porte": [80, 443, 8000, 8080, 8443, 8888]
        },
        "3": {
            "navn": "Database scan",
            "porte": [1433, 3306, 5432, 27017, 6379]
        },
        "4": {
            "navn": "Alle almindelige porte (16 porte)",
            "porte": list(ALMINDELIGE_PORTE.keys())
        }
    }

# Hovedprogram
if __name__ == "__main__":
    print("\n" + "="*70)
    print("              NETVÆRKS PORT SCANNER")
    print("="*70)
    print("\n⚠️  ADVARSEL: Brug kun på netværk du har tilladelse til at scanne!")
    print("    Uautoriseret port scanning kan være ulovligt.\n")
    
    # Få IP-adresse
    ip = input("Indtast IP-adresse eller hostname (f.eks. google.com, 192.168.1.1): ").strip()
    
    if not ip:
        print("❌ Ingen IP-adresse angivet!")
        sys.exit()
    
    # Vælg scanning metode
    print("\n" + "="*70)
    print("Vælg scanning metode:")
    print("="*70)
    
    presets = quick_scan_presets()
    for key, value in presets.items():
        print(f"{key}. {value['navn']}")
    print("5. Brugerdefinerede porte")
    
    valg = input("\nDit valg (1-5): ").strip()
    
    if valg in presets:
        porte = presets[valg]["porte"]
        print(f"\n✓ Valgt: {presets[valg]['navn']}")
    elif valg == "5":
        print("\nEksempler:")
        print("  Enkelt port:     80")
        print("  Flere porte:     80,443,8080")
        print("  Port range:      80-85")
        print("  Kombineret:      20-25,80,443,8080")
        
        port_input = input("\nIndtast porte: ").strip()
        porte = parse_port_range(port_input)
        
        if not porte:
            print("❌ Ingen gyldige porte angivet!")
            sys.exit()
        
        print(f"\n✓ Scanner {len(porte)} porte: {porte[:10]}{'...' if len(porte) > 10 else ''}")
    else:
        print("❌ Ugyldigt valg!")
        sys.exit()
    
    # Timeout indstilling
    timeout_input = input("\nTimeout per port i sekunder (Enter=1): ").strip()
    timeout = float(timeout_input) if timeout_input else 1.0
    
    # Bekræft scanning
    print(f"\n{'='*70}")
    print(f"📋 Klar til at scanne:")
    print(f"   Target: {ip}")
    print(f"   Porte: {len(porte)}")
    print(f"   Timeout: {timeout}s")
    print(f"   Estimeret tid: ~{len(porte) * timeout:.0f} sekunder")
    print("="*70)
    
    fortsæt = input("\nStart scanning? (j/n): ").strip().lower()
    
    if fortsæt != 'j':
        print("\n👋 Scanning annulleret!")
        sys.exit()
    
    # Start scanning
    resultater = scan_porte(ip, porte, timeout)
    
    # Vis resultater
    vis_resultater(resultater, ip)
    
    print("\n✅ Færdig!\n")