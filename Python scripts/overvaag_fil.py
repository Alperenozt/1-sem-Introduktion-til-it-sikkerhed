import hashlib
import os
import json
from datetime import datetime

def beregn_fil_hash(fil_sti):
    """
    Beregner SHA256 hash af en fil.
    
    Args:
        fil_sti (str): Stien til filen
    
    Returns:
        str: Hash værdi eller None ved fejl
    """
    try:
        sha256_hash = hashlib.sha256()
        
        # Læs filen i chunks for at håndtere store filer
        with open(fil_sti, "rb") as f:
            for byte_block in iter(lambda: f.read(4096), b""):
                sha256_hash.update(byte_block)
        
        return sha256_hash.hexdigest()
    
    except FileNotFoundError:
        print(f"❌ Fejl: Filen '{fil_sti}' findes ikke!")
        return None
    except PermissionError:
        print(f"❌ Fejl: Ingen adgang til '{fil_sti}'")
        return None
    except Exception as e:
        print(f"❌ Fejl ved læsning af fil: {e}")
        return None

def gem_hash(fil_sti, hash_værdi):
    """
    Gemmer hash værdien til en JSON fil.
    
    Args:
        fil_sti (str): Original fil der overvåges
        hash_værdi (str): Hash værdi der skal gemmes
    """
    hash_data = {
        "fil": fil_sti,
        "hash": hash_værdi,
        "tidspunkt": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    }
    
    hash_fil = "fil_hash.json"
    
    try:
        with open(hash_fil, "w") as f:
            json.dump(hash_data, f, indent=4)
        print(f"✓ Hash gemt i '{hash_fil}'")
        return True
    except Exception as e:
        print(f"❌ Kunne ikke gemme hash: {e}")
        return False

def hent_gemt_hash():
    """
    Henter tidligere gemt hash fra JSON fil.
    
    Returns:
        dict: Hash data eller None hvis ikke fundet
    """
    hash_fil = "fil_hash.json"
    
    if not os.path.exists(hash_fil):
        return None
    
    try:
        with open(hash_fil, "r") as f:
            return json.load(f)
    except Exception as e:
        print(f"❌ Kunne ikke læse gemt hash: {e}")
        return None

def sammenlign_hash(fil_sti):
    """
    Sammenligner nuværende hash med gemt hash.
    
    Args:
        fil_sti (str): Stien til filen der skal tjekkes
    """
    print(f"\n{'='*60}")
    print(f"Overvåger fil: {fil_sti}")
    print("="*60 + "\n")
    
    # Beregn nuværende hash
    nuværende_hash = beregn_fil_hash(fil_sti)
    if nuværende_hash is None:
        return
    
    print(f"📊 Nuværende hash: {nuværende_hash[:32]}...")
    
    # Hent gemt hash
    gemt_data = hent_gemt_hash()
    
    if gemt_data is None:
        print("\n📝 Ingen tidligere hash fundet.")
        print("Gemmer nuværende hash som reference...")
        gem_hash(fil_sti, nuværende_hash)
    else:
        print(f"📦 Gemt hash:      {gemt_data['hash'][:32]}...")
        print(f"🕐 Gemt tidspunkt:  {gemt_data['tidspunkt']}")
        
        # Sammenlign
        if nuværende_hash == gemt_data['hash']:
            print("\n✅ INGEN ÆNDRINGER - Filen er uændret!")
        else:
            print("\n⚠️  ÆNDRING DETEKTERET - Filen er blevet ændret!")
            print("\n🔄 Opdaterer hash...")
            gem_hash(fil_sti, nuværende_hash)
    
    print("\n" + "="*60)

def opret_test_fil():
    """
    Opretter en test fil til demonstration.
    """
    test_fil = "test_fil.txt"
    
    with open(test_fil, "w") as f:
        f.write("Dette er en test fil.\n")
        f.write("Linje 2: Data til overvågning.\n")
        f.write("Linje 3: Mere indhold.\n")
    
    print(f"✓ Test fil '{test_fil}' oprettet!")
    return test_fil

# Hovedprogram
if __name__ == "__main__":
    print("\n" + "="*60)
    print("        FIL ÆNDRINGS OVERVÅGNING MED HASH")
    print("="*60)
    
    print("\nVælg fil at overvåge:")
    print("1. Test fil (test_fil.txt) - oprettes automatisk")
    print("2. Linux passwd fil (/etc/passwd)")
    print("3. Indtast egen fil sti")
    
    valg = input("\nDit valg (1-3): ").strip()
    
    if valg == "1":
        fil_sti = opret_test_fil()
    elif valg == "2":
        fil_sti = "/etc/passwd"
    elif valg == "3":
        fil_sti = input("Indtast fuld sti til fil: ").strip()
    else:
        print("❌ Ugyldigt valg. Bruger test fil.")
        fil_sti = opret_test_fil()
    
    # Overvåg filen
    sammenlign_hash(fil_sti)
    
    print("\n💡 TIP: Kør scriptet igen for at tjekke om filen er ændret!")
    print("💡 På test filen: Rediger 'test_fil.txt' og kør scriptet igen.\n")