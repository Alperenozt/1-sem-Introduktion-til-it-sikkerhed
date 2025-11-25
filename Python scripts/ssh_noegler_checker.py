import os
import sys

def tjek_ssh_noegler():
    """
    Tjekker om brugere har SSH authorized_keys filer.
    Bruger pwd modulet på Linux/Mac eller alternative metoder på Windows.
    """
    print("\n" + "="*90)
    print("                    SSH NØGLE CHECKER FOR BRUGERE")
    print("="*90)
    
    # Tjek operativsystem
    if sys.platform == "win32":
        print("\n💡 Windows system detekteret")
        print("   Windows bruger ikke pwd modulet (kun Linux/Mac)")
        print("   Bruger alternative metoder til at finde brugere...\n")
        tjek_windows_brugere()
    else:
        print("\n💡 Unix/Linux/Mac system detekteret")
        print("   Bruger pwd modulet til at finde brugere...\n")
        tjek_unix_brugere()

def tjek_unix_brugere():
    """
    Tjekker SSH nøgler på Unix/Linux/Mac systemer ved hjælp af pwd modulet.
    """
    try:
        import pwd
    except ImportError:
        print("❌ FEJL: pwd modulet er ikke tilgængeligt på dette system!")
        print("   pwd modulet findes kun på Unix/Linux/Mac systemer")
        return
    
    print("🔍 Scanner alle system brugere...\n")
    
    brugere_med_ssh = []
    brugere_uden_ssh = []
    fejl_count = 0
    total_brugere = 0
    
    # Gennemgå alle system brugere
    for bruger_info in pwd.getpwall():
        total_brugere += 1
        
        brugernavn = bruger_info.pw_name
        hjemmemappe = bruger_info.pw_dir
        uid = bruger_info.pw_uid
        
        # Spring system brugere over (UID < 1000 på de fleste Linux systemer)
        # Men behold root (UID 0) i analysen
        if uid < 1000 and uid != 0:
            continue
        
        # Tjek om hjemmemappen eksisterer
        if not os.path.exists(hjemmemappe):
            continue
        
        # Byg sti til authorized_keys
        ssh_mappe = os.path.join(hjemmemappe, ".ssh")
        authorized_keys = os.path.join(ssh_mappe, "authorized_keys")
        
        try:
            # Tjek om authorized_keys filen eksisterer
            if os.path.exists(authorized_keys):
                # Hent fil information
                fil_stat = os.stat(authorized_keys)
                fil_stoerrelse = fil_stat.st_size
                
                # Tæl antal nøgler i filen
                try:
                    with open(authorized_keys, 'r') as f:
                        linjer = f.readlines()
                        # Tæl ikke-tomme linjer der ikke starter med #
                        antal_noegler = len([l for l in linjer if l.strip() and not l.strip().startswith('#')])
                except PermissionError:
                    antal_noegler = "Adgang nægtet"
                
                brugere_med_ssh.append({
                    'bruger': brugernavn,
                    'hjemmemappe': hjemmemappe,
                    'authorized_keys': authorized_keys,
                    'stoerrelse': fil_stoerrelse,
                    'antal_noegler': antal_noegler
                })
            else:
                brugere_uden_ssh.append({
                    'bruger': brugernavn,
                    'hjemmemappe': hjemmemappe
                })
        
        except PermissionError:
            fejl_count += 1
        except Exception as e:
            fejl_count += 1
    
    # Vis resultater
    vis_resultater_unix(brugere_med_ssh, brugere_uden_ssh, total_brugere, fejl_count)

def tjek_windows_brugere():
    """
    Tjekker SSH nøgler på Windows systemer.
    """
    print("🔍 Scanner Windows brugere...\n")
    
    brugere_med_ssh = []
    brugere_uden_ssh = []
    
    # På Windows er bruger profiler typisk i C:\Users\
    users_base = "C:\\Users"
    
    if not os.path.exists(users_base):
        print(f"❌ Kunne ikke finde brugermappen: {users_base}")
        return
    
    try:
        # List alle mapper i Users
        for bruger_mappe in os.listdir(users_base):
            hjemmemappe = os.path.join(users_base, bruger_mappe)
            
            # Spring over hvis det ikke er en mappe
            if not os.path.isdir(hjemmemappe):
                continue
            
            # Spring system mapper over
            if bruger_mappe.lower() in ['public', 'default', 'default user', 'all users']:
                continue
            
            # Tjek både .ssh (Unix stil) og ssh (Windows OpenSSH stil)
            for ssh_mappe_navn in ['.ssh', 'ssh', '.ssh']:
                ssh_mappe = os.path.join(hjemmemappe, ssh_mappe_navn)
                authorized_keys = os.path.join(ssh_mappe, "authorized_keys")
                
                try:
                    if os.path.exists(authorized_keys):
                        fil_stat = os.stat(authorized_keys)
                        fil_stoerrelse = fil_stat.st_size
                        
                        # Tæl nøgler
                        try:
                            with open(authorized_keys, 'r') as f:
                                linjer = f.readlines()
                                antal_noegler = len([l for l in linjer if l.strip() and not l.strip().startswith('#')])
                        except:
                            antal_noegler = "Kunne ikke læse"
                        
                        brugere_med_ssh.append({
                            'bruger': bruger_mappe,
                            'hjemmemappe': hjemmemappe,
                            'authorized_keys': authorized_keys,
                            'stoerrelse': fil_stoerrelse,
                            'antal_noegler': antal_noegler
                        })
                        break  # Stop når vi finder første authorized_keys
                except PermissionError:
                    pass
                except Exception:
                    pass
            else:
                # Ingen authorized_keys fundet for denne bruger
                brugere_uden_ssh.append({
                    'bruger': bruger_mappe,
                    'hjemmemappe': hjemmemappe
                })
    
    except PermissionError:
        print("❌ Adgang nægtet - kør som administrator for fuld adgang")
        return
    
    # Vis resultater
    vis_resultater_windows(brugere_med_ssh, brugere_uden_ssh)

def vis_resultater_unix(brugere_med_ssh, brugere_uden_ssh, total_brugere, fejl_count):
    """
    Viser resultater for Unix/Linux/Mac systemer.
    """
    print("="*90)
    print("📊 RESULTATER (Unix/Linux/Mac)")
    print("="*90)
    
    print(f"\n📈 Statistik:")
    print(f"   Total system brugere:           {total_brugere}")
    print(f"   Brugere med authorized_keys:    {len(brugere_med_ssh)}")
    print(f"   Brugere uden authorized_keys:   {len(brugere_uden_ssh)}")
    if fejl_count > 0:
        print(f"   Adgangsfejl:                     {fejl_count}")
    
    if brugere_med_ssh:
        print(f"\n{'='*90}")
        print(f"✅ BRUGERE MED SSH AUTHORIZED_KEYS ({len(brugere_med_ssh)} stk)")
        print("="*90)
        print(f"{'Bruger':<15} {'Hjemmemappe':<30} {'Nøgler':<10} {'Størrelse':<12}")
        print("-"*90)
        
        for bruger in brugere_med_ssh:
            noegler = str(bruger['antal_noegler']) if isinstance(bruger['antal_noegler'], int) else bruger['antal_noegler']
            print(f"{bruger['bruger']:<15} {bruger['hjemmemappe']:<30} {noegler:<10} {bruger['stoerrelse']} bytes")
        
        print("\n💡 Vis detaljer for en bruger?")
        valg = input("   Indtast brugernavn (Enter for at springe over): ").strip()
        
        if valg:
            vis_noegle_detaljer(valg, brugere_med_ssh)
    
    if brugere_uden_ssh:
        print(f"\n{'='*90}")
        print(f"❌ BRUGERE UDEN SSH AUTHORIZED_KEYS ({len(brugere_uden_ssh)} stk)")
        print("="*90)
        
        vis_alle = input("Vis alle? (j/n): ").strip().lower()
        if vis_alle == 'j':
            for bruger in brugere_uden_ssh:
                print(f"   {bruger['bruger']:<15} - {bruger['hjemmemappe']}")
    
    print("\n" + "="*90)

def vis_resultater_windows(brugere_med_ssh, brugere_uden_ssh):
    """
    Viser resultater for Windows systemer.
    """
    print("="*90)
    print("📊 RESULTATER (Windows)")
    print("="*90)
    
    print(f"\n📈 Statistik:")
    print(f"   Brugere med authorized_keys:    {len(brugere_med_ssh)}")
    print(f"   Brugere uden authorized_keys:   {len(brugere_uden_ssh)}")
    
    if brugere_med_ssh:
        print(f"\n{'='*90}")
        print(f"✅ BRUGERE MED SSH AUTHORIZED_KEYS ({len(brugere_med_ssh)} stk)")
        print("="*90)
        print(f"{'Bruger':<20} {'Nøgler':<10} {'Størrelse':<12}")
        print("-"*90)
        
        for bruger in brugere_med_ssh:
            noegler = str(bruger['antal_noegler']) if isinstance(bruger['antal_noegler'], int) else bruger['antal_noegler']
            print(f"{bruger['bruger']:<20} {noegler:<10} {bruger['stoerrelse']} bytes")
            print(f"   Sti: {bruger['authorized_keys']}")
    else:
        print("\n❌ Ingen brugere med authorized_keys fundet")
    
    if brugere_uden_ssh:
        print(f"\n{'='*90}")
        print(f"❌ BRUGERE UDEN SSH AUTHORIZED_KEYS ({len(brugere_uden_ssh)} stk)")
        print("="*90)
        
        for bruger in brugere_uden_ssh:
            print(f"   {bruger['bruger']}")
    
    print("\n" + "="*90)

def vis_noegle_detaljer(brugernavn, brugere_med_ssh):
    """
    Viser detaljerede information om en brugers SSH nøgler.
    """
    bruger_data = next((b for b in brugere_med_ssh if b['bruger'] == brugernavn), None)
    
    if not bruger_data:
        print(f"\n❌ Bruger '{brugernavn}' ikke fundet")
        return
    
    print(f"\n{'='*90}")
    print(f"🔑 SSH NØGLE DETALJER FOR: {brugernavn}")
    print("="*90)
    
    print(f"\nFil: {bruger_data['authorized_keys']}")
    print(f"Størrelse: {bruger_data['stoerrelse']} bytes")
    print(f"Antal nøgler: {bruger_data['antal_noegler']}")
    
    try:
        with open(bruger_data['authorized_keys'], 'r') as f:
            print(f"\n📄 Indhold:")
            print("-"*90)
            linjer = f.readlines()
            for i, linje in enumerate(linjer, 1):
                if linje.strip() and not linje.strip().startswith('#'):
                    # Vis kun de første 80 tegn af nøglen
                    noegle_preview = linje.strip()[:80] + "..." if len(linje.strip()) > 80 else linje.strip()
                    print(f"Nøgle {i}: {noegle_preview}")
    except PermissionError:
        print("\n❌ Adgang nægtet til at læse filen")
    except Exception as e:
        print(f"\n❌ Fejl ved læsning: {e}")
    
    print("="*90)

def opret_test_struktur():
    """
    Opretter en test struktur med SSH nøgler (kun til demonstration).
    """
    print("\n🧪 OPRETTER TEST STRUKTUR...")
    
    test_mappe = "test_ssh_brugere"
    
    # Opret test brugere
    test_brugere = ["bruger1", "bruger2", "bruger3"]
    
    for bruger in test_brugere:
        bruger_mappe = os.path.join(test_mappe, bruger)
        ssh_mappe = os.path.join(bruger_mappe, ".ssh")
        
        os.makedirs(ssh_mappe, exist_ok=True)
        
        # Opret authorized_keys for nogle brugere
        if bruger != "bruger3":  # bruger3 har ingen SSH nøgler
            authorized_keys = os.path.join(ssh_mappe, "authorized_keys")
            with open(authorized_keys, 'w') as f:
                f.write(f"# SSH nøgler for {bruger}\n")
                f.write(f"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDTest{bruger}Key... {bruger}@example.com\n")
                if bruger == "bruger1":
                    f.write(f"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDTest{bruger}Key2... {bruger}@example.com\n")
    
    print(f"✓ Test struktur oprettet i: {test_mappe}")
    print(f"✓ Oprettet {len(test_brugere)} test brugere")
    print("\n💡 Du kan nu analysere test strukturen ved at ændre søgestien\n")

# Hovedprogram
if __name__ == "__main__":
    print("\n" + "="*90)
    print("⚠️  BEMÆRK: Dette script er designet til Linux/Mac systemer med pwd modulet")
    print("   På Windows bruges alternative metoder til at finde brugere")
    print("="*90)
    
    print("\nVælg en funktion:")
    print("1. Scan system brugere for SSH nøgler")
    print("2. Opret test struktur (til demonstration)")
    
    valg = input("\nDit valg (1-2): ").strip()
    
    if valg == "1":
        tjek_ssh_noegler()
        
        if sys.platform != "win32":
            print("\n💡 TIP: På Linux/Mac skal du muligvis køre med sudo for at se alle brugere:")
            print("   sudo python3 ssh_noegler_checker.py")
    
    elif valg == "2":
        opret_test_struktur()
    
    else:
        print("\n❌ Ugyldigt valg!")
    
    print("\n✅ Færdig!\n")