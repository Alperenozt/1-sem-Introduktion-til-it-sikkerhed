import os

def laes_logfil(fil_sti, soege_ord="Failed"):
    """
    Læser en logfil og finder linjer med et specifikt ord.
    """
    try:
        # Tjek om filen eksisterer
        if not os.path.exists(fil_sti):
            print(f"❌ Fejl: Filen '{fil_sti}' findes ikke!")
            return False
        
        print(f"\n{'='*60}")
        print(f"Læser: {fil_sti}")
        print(f"Søger efter: '{soege_ord}'")
        print("="*60 + "\n")
        
        antal_fundet = 0
        total_linjer = 0
        
        # Åbn og læs filen linje for linje
        with open(fil_sti, "r", encoding="utf-8", errors="ignore") as fil:
            for linje_nummer, linje in enumerate(fil, 1):
                total_linjer += 1
                
                # Tjek om linjen indeholder søgeordet
                if soege_ord in linje:
                    antal_fundet += 1
                    print(f"Linje {linje_nummer}: {linje.strip()}")
        
        # Print statistik
        print(f"\n{'='*60}")
        print(f"📊 Total linjer læst: {total_linjer}")
        print(f"✓ Linjer med '{soege_ord}': {antal_fundet}")
        print("="*60)
        
        return True
        
    except PermissionError:
        print(f"❌ Ingen adgang til '{fil_sti}'")
        print("💡 Prøv at køre som administrator (Windows) eller med sudo (Linux/Mac)")
        return False
    except Exception as e:
        print(f"❌ Fejl: {e}")
        return False

def opret_test_logfil():
    """
    Opretter en test logfil med eksempel data.
    """
    fil_navn = "test_log.txt"
    
    with open(fil_navn, "w") as f:
        f.write("2024-10-07 10:15:23 INFO: User 'john' login successful\n")
        f.write("2024-10-07 10:16:45 ERROR: Failed login attempt for user admin\n")
        f.write("2024-10-07 10:17:12 INFO: Connection established from 192.168.1.50\n")
        f.write("2024-10-07 10:18:33 WARNING: Failed authentication from 192.168.1.100\n")
        f.write("2024-10-07 10:19:01 INFO: System started successfully\n")
        f.write("2024-10-07 10:20:15 ERROR: Failed password for root from 10.0.0.5\n")
        f.write("2024-10-07 10:21:30 INFO: Service nginx started\n")
        f.write("2024-10-07 10:22:45 ERROR: Failed to connect to database\n")
        f.write("2024-10-07 10:23:10 INFO: Backup completed successfully\n")
    
    print(f"✓ Test logfil '{fil_navn}' oprettet!")
    return fil_navn

# Hovedprogram
if __name__ == "__main__":
    print("\n" + "="*60)
    print("           LOGFIL LÆSER - Søg efter specifikke ord")
    print("="*60)
    
    # Mulige logfil stier
    linux_log = "/var/log/auth.log"
    windows_log = "C:\\Windows\\System32\\winevt\\Logs\\Security.evtx"
    
    print("\nVælg en mulighed:")
    print("1. Brug test logfil (oprettes automatisk)")
    print("2. Linux system log (/var/log/auth.log)")
    print("3. Indtast egen fil sti")
    
    valg = input("\nDit valg (1-3): ").strip()
    
    if valg == "1":
        fil_sti = opret_test_logfil()
    elif valg == "2":
        fil_sti = linux_log
    elif valg == "3":
        fil_sti = input("Indtast fuld sti til logfil: ").strip()
    else:
        print("❌ Ugyldigt valg. Bruger test logfil.")
        fil_sti = opret_test_logfil()
    
    # Spørg om søgeord
    soege_ord = input("\nHvad vil du søge efter? (tryk Enter for 'Failed'): ").strip()
    if not soege_ord:
        soege_ord = "Failed"
    
    # Læs logfilen
    laes_logfil(fil_sti, soege_ord)
    
    print("\n✓ Færdig!\n") 