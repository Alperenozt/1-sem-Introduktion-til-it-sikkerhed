import psutil
import sys
import time

def find_processer(proces_navn):
    """
    Finder alle processer der matcher et bestemt navn.
    
    Args:
        proces_navn (str): Navnet på processen (f.eks. "chrome", "notepad")
    
    Returns:
        list: Liste af matchende psutil.Process objekter
    """
    matchende_processer = []
    proces_navn_lower = proces_navn.lower()
    
    try:
        # Gennemgå alle kørende processer
        for proc in psutil.process_iter(['pid', 'name', 'username', 'memory_info', 'cpu_percent']):
            try:
                # Tjek om proces navnet matcher (case-insensitive)
                if proces_navn_lower in proc.info['name'].lower():
                    matchende_processer.append(proc)
            except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                pass
    
    except Exception as e:
        print(f"❌ Fejl ved søgning efter processer: {e}")
    
    return matchende_processer

def vis_proces_info(processer):
    """
    Viser information om processer.
    
    Args:
        processer (list): Liste af psutil.Process objekter
    """
    if not processer:
        print("❌ Ingen matchende processer fundet!")
        return
    
    print(f"\n{'='*90}")
    print(f"📊 FUNDNE PROCESSER ({len(processer)} stk)")
    print("="*90)
    print(f"{'PID':<8} {'Navn':<25} {'Bruger':<15} {'Hukommelse':<12} {'CPU %':<8}")
    print("-"*90)
    
    for proc in processer:
        try:
            pid = proc.info['pid']
            navn = proc.info['name'][:24]
            bruger = proc.info['username'][:14] if proc.info['username'] else "N/A"
            
            # Hukommelse i MB
            memory_mb = proc.info['memory_info'].rss / (1024 * 1024)
            
            # CPU procent (kan være None første gang)
            cpu = proc.info['cpu_percent'] if proc.info['cpu_percent'] is not None else 0.0
            
            print(f"{pid:<8} {navn:<25} {bruger:<15} {memory_mb:>8.1f} MB  {cpu:>6.1f}%")
        
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            print(f"{proc.info['pid']:<8} {'<Adgang nægtet>':<25}")
    
    print("="*90)

def stop_processer(processer, force=False):
    """
    Stopper en liste af processer.
    
    Args:
        processer (list): Liste af psutil.Process objekter
        force (bool): Hvis True, brug force kill (SIGKILL), ellers graceful (SIGTERM)
    
    Returns:
        dict: Statistik over stoppede processer
    """
    if not processer:
        return {"success": 0, "failed": 0, "access_denied": 0}
    
    success = 0
    failed = 0
    access_denied = 0
    
    print(f"\n{'='*90}")
    print(f"🛑 STOPPER PROCESSER (Metode: {'FORCE KILL' if force else 'GRACEFUL TERMINATION'})")
    print("="*90 + "\n")
    
    for proc in processer:
        try:
            pid = proc.pid
            navn = proc.name()
            
            print(f"Stopper PID {pid} ({navn})...", end=" ")
            
            if force:
                # Force kill (SIGKILL)
                proc.kill()
            else:
                # Graceful termination (SIGTERM)
                proc.terminate()
            
            # Vent på at processen stopper (max 3 sekunder)
            try:
                proc.wait(timeout=3)
                print("✓ Stoppet")
                success += 1
            except psutil.TimeoutExpired:
                print("⚠️  Timeout - prøver force kill...")
                proc.kill()
                proc.wait(timeout=1)
                print("✓ Force killed")
                success += 1
        
        except psutil.AccessDenied:
            print("❌ Adgang nægtet (kræver administrator rettigheder)")
            access_denied += 1
        except psutil.NoSuchProcess:
            print("⚠️  Processen eksisterer ikke længere")
            failed += 1
        except Exception as e:
            print(f"❌ Fejl: {e}")
            failed += 1
    
    return {"success": success, "failed": failed, "access_denied": access_denied}

def vis_system_info():
    """
    Viser generel system information.
    """
    print("\n" + "="*90)
    print("💻 SYSTEM INFORMATION")
    print("="*90)
    
    try:
        # CPU info
        cpu_count = psutil.cpu_count(logical=False)
        cpu_count_logical = psutil.cpu_count(logical=True)
        cpu_percent = psutil.cpu_percent(interval=1)
        
        print(f"\n🔧 CPU:")
        print(f"   Fysiske kerner: {cpu_count}")
        print(f"   Logiske kerner: {cpu_count_logical}")
        print(f"   Forbrug: {cpu_percent}%")
        
        # Memory info
        memory = psutil.virtual_memory()
        memory_total_gb = memory.total / (1024**3)
        memory_used_gb = memory.used / (1024**3)
        memory_percent = memory.percent
        
        print(f"\n💾 Hukommelse:")
        print(f"   Total: {memory_total_gb:.2f} GB")
        print(f"   Brugt: {memory_used_gb:.2f} GB ({memory_percent}%)")
        print(f"   Ledig: {(memory.available / (1024**3)):.2f} GB")
        
        # Antal processer
        proc_count = len(psutil.pids())
        print(f"\n📊 Processer:")
        print(f"   Total antal kørende: {proc_count}")
    
    except Exception as e:
        print(f"❌ Kunne ikke hente system info: {e}")
    
    print("="*90)

def list_top_processer(antal=10):
    """
    Viser top processer efter hukommelsesforbrug.
    
    Args:
        antal (int): Antal processer der skal vises
    """
    print(f"\n{'='*90}")
    print(f"🏆 TOP {antal} PROCESSER (efter hukommelsesforbrug)")
    print("="*90)
    
    processer = []
    
    for proc in psutil.process_iter(['pid', 'name', 'memory_info']):
        try:
            processer.append(proc)
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            pass
    
    # Sorter efter hukommelse
    processer.sort(key=lambda p: p.info['memory_info'].rss, reverse=True)
    
    print(f"{'Rank':<6} {'PID':<8} {'Navn':<30} {'Hukommelse':<12}")
    print("-"*90)
    
    for rank, proc in enumerate(processer[:antal], 1):
        try:
            memory_mb = proc.info['memory_info'].rss / (1024 * 1024)
            print(f"{rank:<6} {proc.info['pid']:<8} {proc.info['name'][:29]:<30} {memory_mb:>8.1f} MB")
        except:
            pass
    
    print("="*90)

# Hovedprogram
if __name__ == "__main__":
    print("\n" + "="*90)
    print("                         PROCES MANAGER MED PSUTIL")
    print("="*90)
    
    # Tjek om psutil er installeret
    try:
        import psutil
    except ImportError:
        print("\n❌ FEJL: psutil er ikke installeret!")
        print("\n📦 Installer psutil med:")
        print("   pip install psutil")
        print("\neller:")
        print("   python -m pip install psutil")
        sys.exit(1)
    
    print("\n⚠️  ADVARSEL: At stoppe processer kan føre til datatab!")
    print("    Gem altid dit arbejde før du stopper processer.\n")
    
    # Menu
    print("Vælg en funktion:")
    print("1. Find og stop processer efter navn")
    print("2. Vis system information")
    print("3. Vis top processer (efter hukommelse)")
    print("4. List alle kørende processer")
    
    valg = input("\nDit valg (1-4): ").strip()
    
    if valg == "1":
        # Find og stop processer
        proces_navn = input("\nIndtast proces navn (f.eks. 'notepad', 'chrome'): ").strip()
        
        if not proces_navn:
            print("❌ Intet proces navn angivet!")
            sys.exit()
        
        print(f"\n🔍 Søger efter processer med navn '{proces_navn}'...")
        processer = find_processer(proces_navn)
        
        if not processer:
            print(f"\n❌ Ingen processer fundet med navnet '{proces_navn}'")
            sys.exit()
        
        # Vis fundne processer
        vis_proces_info(processer)
        
        # Bekræft stop
        print(f"\n⚠️  Du er ved at stoppe {len(processer)} proces(ser)!")
        bekraeft = input("Er du sikker? (skriv 'ja' for at fortsætte): ").strip().lower()
        
        if bekraeft != 'ja':
            print("\n👋 Annulleret - ingen processer blev stoppet")
            sys.exit()
        
        # Vælg metode
        force = input("\nBrug force kill? (j/n, Enter=n): ").strip().lower() == 'j'
        
        # Stop processerne
        statistik = stop_processer(processer, force)
        
        # Vis resultat
        print(f"\n{'='*90}")
        print("📊 RESULTAT:")
        print("="*90)
        print(f"✓ Stoppet med succes:     {statistik['success']}")
        print(f"❌ Fejl:                   {statistik['failed']}")
        print(f"🔒 Adgang nægtet:          {statistik['access_denied']}")
        print("="*90)
        
        if statistik['access_denied'] > 0:
            print("\n💡 TIP: Kør scriptet som administrator for at stoppe alle processer")
            print("    Windows: Højreklik på cmd/PowerShell → 'Kør som administrator'")
            print("    Linux/Mac: Kør med 'sudo python process_manager.py'")
    
    elif valg == "2":
        vis_system_info()
    
    elif valg == "3":
        antal = input("\nHvor mange processer vil du se? (Enter=10): ").strip()
        antal = int(antal) if antal.isdigit() else 10
        list_top_processer(antal)
    
    elif valg == "4":
        print("\n🔍 Henter alle kørende processer...")
        alle_processer = list(psutil.process_iter(['pid', 'name']))
        print(f"\nFandt {len(alle_processer)} processer\n")
        
        vis_alle = input("Vis alle? (Dette kan være meget langt) (j/n): ").strip().lower()
        
        if vis_alle == 'j':
            for proc in sorted(alle_processer, key=lambda p: p.info['name'].lower()):
                try:
                    print(f"PID {proc.info['pid']:<8} - {proc.info['name']}")
                except:
                    pass
    
    else:
        print("\n❌ Ugyldigt valg!")
    
    print("\n✅ Færdig!\n")