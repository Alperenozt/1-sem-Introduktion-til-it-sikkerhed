import shutil
import os

def check_disk_space(path="/"):
    """
    Tjekker diskplads på en given sti og advarer hvis der er under 20% ledig plads.
    
    Args:
        path (str): Stien til disken der skal tjekkes (standard: root)
    
    Returns:
        dict: Information om diskplads
    """
    try:
        # Hent diskplads information
        usage = shutil.disk_usage(path)
        
        # Beregn procenter
        total_gb = usage.total / (1024**3)  # Konverter til GB
        used_gb = usage.used / (1024**3)
        free_gb = usage.free / (1024**3)
        
        percent_used = (usage.used / usage.total) * 100
        percent_free = (usage.free / usage.total) * 100
        
        # Print information
        print(f"=== Diskplads for '{path}' ===")
        print(f"Total plads:  {total_gb:.2f} GB")
        print(f"Brugt plads:  {used_gb:.2f} GB ({percent_used:.1f}%)")
        print(f"Ledig plads:  {free_gb:.2f} GB ({percent_free:.1f}%)")
        print("-" * 40)
        
        # Tjek om der er under 20% ledig plads
        if percent_free < 20:
            print("⚠️  ADVARSEL: Der er under 20% ledig diskplads!")
            print(f"⚠️  Du har kun {percent_free:.1f}% ({free_gb:.2f} GB) tilbage!")
        else:
            print(f"✓ Diskplads OK - {percent_free:.1f}% ledig")
        
        return {
            "total": total_gb,
            "used": used_gb,
            "free": free_gb,
            "percent_free": percent_free
        }
        
    except Exception as e:
        print(f"Fejl ved tjek af diskplads: {e}")
        return None

def check_all_drives():
    """
    Tjekker alle tilgængelige drev (Windows) eller monteringspunkter.
    """
    if os.name == 'nt':  # Windows
        print("Tjekker alle Windows drev:\n")
        import string
        for letter in string.ascii_uppercase:
            drive = f"{letter}:\\"
            if os.path.exists(drive):
                check_disk_space(drive)
                print()
    else:  # Linux/Mac
        print("Tjekker root filsystem:\n")
        check_disk_space("/")

# Kør programmet
if __name__ == "__main__":
    # Tjek standard drev/partition
    if os.name == 'nt':  # Windows
        check_disk_space("C:\\")
    else:  # Linux/Mac
        check_disk_space("/")
    
    print("\n" + "="*40)
    print("Vil du tjekke alle drev? (j/n): ", end="")
    choice = input().lower()
    
    if choice == 'j':
        print()
        check_all_drives()