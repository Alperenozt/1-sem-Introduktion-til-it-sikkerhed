import psutil
import time
import sys
from datetime import datetime

# Port navne til almindelige tjenester
PORT_NAVNE = {
    20: "FTP-Data",
    21: "FTP",
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
    8080: "HTTP-Alt",
    8443: "HTTPS-Alt"
}

def hent_aktive_forbindelser():
    """
    Henter alle aktive netværksforbindelser.
    
    Returns:
        set: Set af forbindelses-tupler (status, laddr, raddr, pid)
    """
    forbindelser = set()
    
    try:
        # Hent alle netværksforbindelser
        connections = psutil.net_connections(kind='inet')
        
        for conn in connections:
            # Opbyg en unik identifikator for forbindelsen
            laddr = f"{conn.laddr.ip}:{conn.laddr.port}" if conn.laddr else "N/A"
            raddr = f"{conn.raddr.ip}:{conn.raddr.port}" if conn.raddr else "N/A"
            
            forbindelse_id = (
                conn.status,
                laddr,
                raddr,
                conn.pid
            )
            
            forbindelser.add(forbindelse_id)
    
    except psutil.AccessDenied:
        print("⚠️  Adgang nægtet - kør som administrator for fuld adgang")
    except Exception as e:
        print(f"❌ Fejl ved hentning af forbindelser: {e}")
    
    return forbindelser

def hent_proces_navn(pid):
    """
    Henter proces navnet for en given PID.
    
    Args:
        pid (int): Process ID
    
    Returns:
        str: Proces navn eller "N/A"
    """
    if pid is None:
        return "N/A"
    
    try:
        proc = psutil.Process(pid)
        return proc.name()
    except (psutil.NoSuchProcess, psutil.AccessDenied):
        return "N/A"

def hent_tjeneste_navn(port):
    """
    Returnerer tjeneste navn for en port.
    
    Args:
        port (int): Port nummer
    
    Returns:
        str: Tjeneste navn eller tom streng
    """
    return PORT_NAVNE.get(port, "")

def parser_adresse(adresse):
    """
    Parser en adresse streng til IP og port.
    
    Args:
        adresse (str): Adresse i format "IP:PORT"
    
    Returns:
        tuple: (ip, port) eller (adresse, None)
    """
    if adresse == "N/A":
        return adresse, None
    
    try:
        ip, port = adresse.rsplit(':', 1)
        return ip, int(port)
    except:
        return adresse, None

def vis_ny_forbindelse(status, laddr, raddr, pid, nummer):
    """
    Viser information om en ny forbindelse.
    
    Args:
        status (str): Forbindelses status
        laddr (str): Lokal adresse
        raddr (str): Remote adresse
        pid (int): Process ID
        nummer (int): Forbindelses nummer
    """
    tidspunkt = datetime.now().strftime("%H:%M:%S")
    proces_navn = hent_proces_navn(pid)
    
    # Parser adresser
    local_ip, local_port = parser_adresse(laddr)
    remote_ip, remote_port = parser_adresse(raddr)
    
    # Hent tjeneste navne
    local_service = hent_tjeneste_navn(local_port) if local_port else ""
    remote_service = hent_tjeneste_navn(remote_port) if remote_port else ""
    
    print(f"\n{'='*90}")
    print(f"🆕 NY FORBINDELSE #{nummer} - {tidspunkt}")
    print("="*90)
    print(f"Status:      {status}")
    print(f"Lokal:       {laddr} {('(' + local_service + ')') if local_service else ''}")
    print(f"Remote:      {raddr} {('(' + remote_service + ')') if remote_service else ''}")
    print(f"Proces:      {proces_navn} (PID: {pid if pid else 'N/A'})")
    print("="*90)

def overvaag_forbindelser(interval=1, vis_eksisterende=False):
    """
    Overvåger netværksforbindelser i realtid og viser nye forbindelser.
    
    Args:
        interval (float): Sekunder mellem hver tjek
        vis_eksisterende (bool): Vis eksisterende forbindelser ved start
    """
    print("\n" + "="*90)
    print("           NETVÆRKS FORBINDELSER MONITOR (Realtid)")
    print("="*90)
    print(f"\n🔄 Overvåger nye netværksforbindelser hvert {interval} sekund")
    print("⚠️  Tryk Ctrl+C for at stoppe\n")
    
    # Hent initiale forbindelser
    print("📊 Henter eksisterende forbindelser...")
    tidligere_forbindelser = hent_aktive_forbindelser()
    
    if vis_eksisterende:
        print(f"✓ Fandt {len(tidligere_forbindelser)} eksisterende forbindelser")
        print("\n💡 Viser eksisterende forbindelser:")
        vis_alle_forbindelser(tidligere_forbindelser)
    else:
        print(f"✓ Baseline sat med {len(tidligere_forbindelser)} eksisterende forbindelser")
    
    print("\n🔍 Monitor kører - venter på nye forbindelser...\n")
    print("-"*90)
    
    nye_forbindelser_count = 0
    
    try:
        while True:
            # Vent intervallet
            time.sleep(interval)
            
            # Hent nuværende forbindelser
            nuvaerende_forbindelser = hent_aktive_forbindelser()
            
            # Find nye forbindelser (dem der ikke var der før)
            nye_forbindelser = nuvaerende_forbindelser - tidligere_forbindelser
            
            # Vis hver ny forbindelse
            for forbindelse in nye_forbindelser:
                nye_forbindelser_count += 1
                status, laddr, raddr, pid = forbindelse
                vis_ny_forbindelse(status, laddr, raddr, pid, nye_forbindelser_count)
            
            # Opdater tidligere forbindelser
            tidligere_forbindelser = nuvaerende_forbindelser
    
    except KeyboardInterrupt:
        print("\n\n" + "="*90)
        print("🛑 Overvågning stoppet af bruger")
        print("="*90)
        print(f"📊 Total nye forbindelser detekteret: {nye_forbindelser_count}")
        print("="*90)

def vis_alle_forbindelser(forbindelser):
    """
    Viser alle forbindelser i et pænt format.
    
    Args:
        forbindelser (set): Set af forbindelser
    """
    if not forbindelser:
        print("❌ Ingen forbindelser at vise")
        return
    
    print(f"\n{'Status':<12} {'Lokal Adresse':<25} {'Remote Adresse':<25} {'PID':<8} {'Proces':<15}")
    print("-"*90)
    
    for status, laddr, raddr, pid in sorted(forbindelser):
        proces = hent_proces_navn(pid)
        pid_str = str(pid) if pid else "N/A"
        print(f"{status:<12} {laddr:<25} {raddr:<25} {pid_str:<8} {proces:<15}")

def vis_forbindelser_statistik():
    """
    Viser statistik over nuværende netværksforbindelser.
    """
    print("\n" + "="*90)
    print("📊 NETVÆRKS FORBINDELSER STATISTIK")
    print("="*90)
    
    try:
        connections = psutil.net_connections(kind='inet')
        
        # Tæl efter status
        status_count = {}
        proces_count = {}
        port_count = {}
        
        for conn in connections:
            # Tæl status
            status_count[conn.status] = status_count.get(conn.status, 0) + 1
            
            # Tæl processer
            if conn.pid:
                proces_navn = hent_proces_navn(conn.pid)
                proces_count[proces_navn] = proces_count.get(proces_navn, 0) + 1
            
            # Tæl lokale porte
            if conn.laddr:
                port = conn.laddr.port
                port_count[port] = port_count.get(port, 0) + 1
        
        # Vis status fordeling
        print(f"\n📈 Forbindelser efter status:")
        print("-"*90)
        for status, count in sorted(status_count.items(), key=lambda x: x[1], reverse=True):
            print(f"   {status:<15} {count:>5}")
        
        # Vis top processer
        print(f"\n🏆 Top 10 processer med flest forbindelser:")
        print("-"*90)
        for proces, count in sorted(proces_count.items(), key=lambda x: x[1], reverse=True)[:10]:
            print(f"   {proces:<30} {count:>5}")
        
        # Vis top porte
        print(f"\n🔌 Top 10 mest brugte lokale porte:")
        print("-"*90)
        for port, count in sorted(port_count.items(), key=lambda x: x[1], reverse=True)[:10]:
            tjeneste = hent_tjeneste_navn(port)
            tjeneste_str = f" ({tjeneste})" if tjeneste else ""
            print(f"   Port {port:<10}{tjeneste_str:<20} {count:>5}")
        
        print("\n" + "="*90)
        print(f"Total aktive forbindelser: {len(connections)}")
        print("="*90)
    
    except psutil.AccessDenied:
        print("\n⚠️  Adgang nægtet - kør som administrator for fuld adgang")
    except Exception as e:
        print(f"\n❌ Fejl: {e}")

# Hovedprogram
if __name__ == "__main__":
    print("\n" + "="*90)
    print("              NETVÆRKS FORBINDELSER OVERVÅGNING MED PSUTIL")
    print("="*90)
    
    # Tjek om psutil er installeret
    try:
        import psutil
    except ImportError:
        print("\n❌ FEJL: psutil er ikke installeret!")
        print("\n📦 Installer psutil med:")
        print("   pip install psutil")
        sys.exit(1)
    
    print("\n💡 Dette script bruger psutil.net_connections() til at overvåge netværk")
    print("⚠️  Administrator/root rettigheder anbefales for fuld adgang\n")
    
    # Menu
    print("Vælg en funktion:")
    print("1. Overvåg nye forbindelser i realtid (anbefalet)")
    print("2. Vis statistik over nuværende forbindelser")
    print("3. Vis alle nuværende forbindelser")
    
    valg = input("\nDit valg (1-3): ").strip()
    
    if valg == "1":
        # Overvåg i realtid
        vis_eksist = input("\nVis eksisterende forbindelser først? (j/n, Enter=n): ").strip().lower() == 'j'
        
        interval_input = input("Tjek interval i sekunder (Enter=1): ").strip()
        interval = float(interval_input) if interval_input else 1.0
        
        print("\n💡 TIP: Åbn en browser eller start en applikation for at se nye forbindelser!")
        input("Tryk Enter for at starte overvågning...")
        
        overvaag_forbindelser(interval, vis_eksist)
    
    elif valg == "2":
        vis_forbindelser_statistik()
    
    elif valg == "3":
        print("\n📊 Henter alle forbindelser...")
        forbindelser = hent_aktive_forbindelser()
        vis_alle_forbindelser(forbindelser)
        print(f"\nTotal: {len(forbindelser)} forbindelser")
    
    else:
        print("\n❌ Ugyldigt valg!")
    
    print("\n✅ Færdig!\n")