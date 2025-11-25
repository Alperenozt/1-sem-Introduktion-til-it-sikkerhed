import os
import stat
import sys

def er_world_writable(fil_sti):
    """
    Tjekker om en fil er world-writable (alle kan skrive til den).
    
    Args:
        fil_sti (str): Stien til filen
    
    Returns:
        bool: True hvis world-writable, False ellers
    """
    try:
        fil_stat = os.stat(fil_sti)
        mode = fil_stat.st_mode
        
        # Tjek om 'others' har skriverettigheder (world-writable)
        # stat.S_IWOTH er bitmask for 'others write' permission
        return bool(mode & stat.S_IWOTH)
    
    except (PermissionError, FileNotFoundError):
        return False
    except Exception:
        return False

def hent_rettigheder(fil_sti):
    """
    Henter og formaterer filrettigheder.
    
    Args:
        fil_sti (str): Stien til filen
    
    Returns:
        str: Formateret rettighedsstreng (f.eks. 'rwxrwxrwx')
    """
    try:
        fil_stat = os.stat(fil_sti)
        mode = fil_stat.st_mode
        
        # Byg rettighedsstreng
        rettigheder = ""
        
        # Ejer (owner)
        rettigheder += 'r' if mode & stat.S_IRUSR else '-'
        rettigheder += 'w' if mode & stat.S_IWUSR else '-'
        rettigheder += 'x' if mode & stat.S_IXUSR else '-'
        
        # Gruppe (group)
        rettigheder += 'r' if mode & stat.S_IRGRP else '-'
        rettigheder += 'w' if mode & stat.S_IWGRP else '-'
        rettigheder += 'x' if mode & stat.S_IXGRP else '-'
        
        # Andre (others)
        rettigheder += 'r' if mode & stat.S_IROTH else '-'
        rettigheder += 'w' if mode & stat.S_IWOTH else '-'
        rettigheder += 'x' if mode & stat.S_IXOTH else '-'
        
        # Oktal notation (f.eks. 777)
        oktal = oct(mode & 0o777)[2:]
        
        return f"{rettigheder} ({oktal})"
    
    except Exception:
        return "????????? (???)"

def scan_mappe(mappe_sti, vis_alle=False):
    """
    Scanner rekursivt en mappe for filer med usikre rettigheder.
    
    Args:
        mappe_sti (str): Stien til mappen der skal scannes
        vis_alle (bool): Hvis True, vis alle filer, ikke kun usikre
    
    Returns:
        list: Liste af usikre filer
    """
    usikre_filer = []
    total_filer = 0
    total_mapper = 0
    fejl_count = 0
    
    print(f"\n{'='*80}")
    print(f"🔍 Scanner mappe: {os.path.abspath(mappe_sti)}")
    print("="*80 + "\n")
    
    print("Søger efter world-writable filer...\n")
    
    try:
        # Brug os.walk() til rekursiv søgning
        for rod, mapper, filer in os.walk(mappe_sti):
            total_mapper += len(mapper)
            
            # Tjek hver fil
            for fil_navn in filer:
                total_filer += 1
                fil_sti = os.path.join(rod, fil_navn)
                
                try:
                    # Tjek om filen er world-writable
                    if er_world_writable(fil_sti):
                        rettigheder = hent_rettigheder(fil_sti)
                        usikre_filer.append((fil_sti, rettigheder))
                        print(f"⚠️  {fil_sti}")
                        print(f"    Rettigheder: {rettigheder}\n")
                    
                    elif vis_alle:
                        rettigheder = hent_rettigheder(fil_sti)
                        print(f"✓  {fil_sti}")
                        print(f"   Rettigheder: {rettigheder}\n")
                
                except PermissionError:
                    fejl_count += 1
                except Exception as e:
                    fejl_count += 1
    
    except PermissionError:
        print(f"❌ Ingen adgang til mappe: {mappe_sti}")
    except Exception as e:
        print(f"❌ Fejl ved scanning: {e}")
    
    # Print statistik
    print("="*80)
    print("📊 STATISTIK:")
    print("="*80)
    print(f"Total mapper scannet:     {total_mapper}")
    print(f"Total filer scannet:      {total_filer}")
    print(f"⚠️  Usikre filer fundet:   {len(usikre_filer)}")
    if fejl_count > 0:
        print(f"❌ Filer med adgangsfejl: {fejl_count}")
    print("="*80)
    
    return usikre_filer

def opret_test_struktur():
    """
    Opretter en test mappe struktur med forskellige rettigheder.
    """
    test_mappe = "test_sikkerhed"
    
    # Opret hovedmappe
    if not os.path.exists(test_mappe):
        os.makedirs(test_mappe)
    
    # Opret undermapper
    os.makedirs(os.path.join(test_mappe, "undermappe1"), exist_ok=True)
    os.makedirs(os.path.join(test_mappe, "undermappe2"), exist_ok=True)
    
    # Opret test filer
    filer = [
        (os.path.join(test_mappe, "sikker_fil.txt"), "Dette er en sikker fil", 0o644),
        (os.path.join(test_mappe, "usikker_fil.txt"), "Dette er en usikker fil", 0o666),
        (os.path.join(test_mappe, "undermappe1", "normal.txt"), "Normal fil", 0o644),
        (os.path.join(test_mappe, "undermappe1", "world_writable.txt"), "Alle kan skrive", 0o777),
        (os.path.join(test_mappe, "undermappe2", "data.txt"), "Data fil", 0o600),
    ]
    
    for fil_sti, indhold, rettigheder in filer:
        with open(fil_sti, "w") as f:
            f.write(indhold + "\n")
        
        # Sæt rettigheder (virker kun på Linux/Mac)
        if sys.platform != "win32":
            os.chmod(fil_sti, rettigheder)
    
    print(f"✓ Test mappe struktur oprettet: {test_mappe}")
    
    if sys.platform == "win32":
        print("\n⚠️  NOTE: Windows håndterer filrettigheder anderledes end Linux/Mac")
        print("    Rettigheder er blevet sat, men fungerer bedst på Linux/Mac")
    
    return test_mappe

def forklaring():
    """
    Forklarer hvad world-writable betyder.
    """
    print("\n" + "="*80)
    print("📚 FORKLARING: FILRETTIGHEDER")
    print("="*80)
    print("""
Filrettigheder i Unix/Linux har 3 grupper:
- Ejer (Owner):  Brugeren der ejer filen
- Gruppe (Group): Gruppen filen tilhører
- Andre (Others): Alle andre brugere

Hver gruppe kan have:
- r (read):    Læserettigheder
- w (write):   Skriverettigheder  
- x (execute): Eksekveringsrettigheder

Eksempel: rwxrw-r-- (744)
- Ejer:   rwx (læse, skrive, eksekvere)
- Gruppe: rw- (læse, skrive)
- Andre:  r-- (kun læse)

⚠️  WORLD-WRITABLE (rw-rw-rw- eller 666):
    Betyder at ALLE brugere kan ændre filen!
    Dette er en sikkerhedsrisiko!

⚠️  SÆRLIGT FARLIGT (rwxrwxrwx eller 777):
    Alle kan læse, skrive OG eksekvere filen!
    """)
    print("="*80)

# Hovedprogram
if __name__ == "__main__":
    print("\n" + "="*80)
    print("           FIND USIKRE FILRETTIGHEDER (WORLD-WRITABLE)")
    print("="*80)
    
    # Tjek platform
    if sys.platform == "win32":
        print("\n💡 NOTE: Dette script er designet til Linux/Mac filrettigheder.")
        print("    Windows bruger et andet rettighedssystem (ACL).")
        print("    Scriptet virker stadig, men resultater kan være anderledes.\n")
    
    print("\nVælg en funktion:")
    print("1. Scan en eksisterende mappe")
    print("2. Opret test mappe og scan den")
    print("3. Vis forklaring om filrettigheder")
    
    valg = input("\nDit valg (1-3): ").strip()
    
    if valg == "1":
        mappe = input("\nIndtast sti til mappe: ").strip()
        if not mappe:
            mappe = "."  # Nuværende mappe
        
        if os.path.exists(mappe):
            vis_alle = input("Vis alle filer? (j/n, Enter=n): ").strip().lower() == 'j'
            usikre = scan_mappe(mappe, vis_alle)
            
            if usikre:
                print(f"\n⚠️  ADVARSEL: Fandt {len(usikre)} usikre filer!")
                print("💡 Overvej at ændre rettigheder med chmod kommandoen")
            else:
                print("\n✅ Ingen world-writable filer fundet!")
        else:
            print(f"\n❌ Mappen '{mappe}' findes ikke!")
    
    elif valg == "2":
        test_mappe = opret_test_struktur()
        print()
        input("Tryk Enter for at scanne test mappen...")
        scan_mappe(test_mappe, vis_alle=True)
        
        print("\n💡 Du kan nu:")
        print(f"   - Se filerne i '{test_mappe}' mappen")
        print("   - Ændre rettigheder og scanne igen")
        print("   - Slette test mappen når du er færdig")
    
    elif valg == "3":
        forklaring()
    
    else:
        print("\n❌ Ugyldigt valg!")
    
    print("\n✅ Færdig!\n")