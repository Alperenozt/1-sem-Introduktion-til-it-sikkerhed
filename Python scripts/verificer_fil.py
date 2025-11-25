import hashlib
import os

def beregn_sha256(fil_sti):
    """
    Beregner SHA256 hash af en fil.
    
    Args:
        fil_sti (str): Stien til filen
    
    Returns:
        str: SHA256 hash værdi eller None ved fejl
    """
    try:
        sha256_hash = hashlib.sha256()
        
        # Læs filen i chunks for at håndtere store filer effektivt
        with open(fil_sti, "rb") as f:
            # Læs 8KB ad gangen
            for byte_block in iter(lambda: f.read(8192), b""):
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

def verificer_fil(fil_sti, kendt_hash):
    """
    Verificerer en fils integritet ved at sammenligne med kendt hash.
    
    Args:
        fil_sti (str): Stien til filen der skal verificeres
        kendt_hash (str): Den kendte/forventede hash værdi
    
    Returns:
        bool: True hvis hash matcher, False ellers
    """
    print(f"\n{'='*70}")
    print(f"Verificerer fil: {fil_sti}")
    print("="*70 + "\n")
    
    # Beregn filens aktuelle hash
    print("🔄 Beregner SHA256 hash...")
    aktuel_hash = beregn_sha256(fil_sti)
    
    if aktuel_hash is None:
        return False
    
    # Vis information
    print(f"\n📊 Beregnet hash:  {aktuel_hash}")
    print(f"🔑 Forventet hash: {kendt_hash.lower()}")
    
    # Sammenlign hash værdier (case-insensitive)
    if aktuel_hash.lower() == kendt_hash.lower():
        print("\n✅ VERIFICERET - Filen er autentisk og uændret!")
        print("✓ Hash værdierne matcher perfekt")
        return True
    else:
        print("\n⚠️  ADVARSEL - VERIFICERING FEJLEDE!")
        print("✗ Hash værdierne matcher IKKE")
        print("⚠️  Filen kan være blevet ændret eller kompromitteret!")
        return False

def vis_fil_info(fil_sti):
    """
    Viser information om filen.
    """
    if os.path.exists(fil_sti):
        fil_stoerrelse = os.path.getsize(fil_sti)
        print(f"📄 Filnavn:    {os.path.basename(fil_sti)}")
        print(f"📁 Sti:        {os.path.abspath(fil_sti)}")
        print(f"📦 Størrelse:  {fil_stoerrelse:,} bytes ({fil_stoerrelse/1024:.2f} KB)")

def opret_test_fil():
    """
    Opretter en test fil til demonstration.
    """
    test_fil = "test_dokument.txt"
    
    indhold = """Dette er et test dokument til integritet verificering.
    
Vigtig information:
- Dokument ID: 12345
- Version: 1.0
- Dato: 2024-10-07

Dette dokument må ikke ændres uden godkendelse.
"""
    
    with open(test_fil, "w", encoding="utf-8") as f:
        f.write(indhold)
    
    # Beregn og vis hash for test filen
    hash_værdi = beregn_sha256(test_fil)
    
    print(f"✓ Test fil '{test_fil}' oprettet!")
    print(f"📊 Filens SHA256 hash: {hash_værdi}\n")
    print("💡 Kopier denne hash og brug den til verificering!")
    
    return test_fil, hash_værdi

def menu_mode():
    """
    Interaktiv menu til fil verificering.
    """
    print("\n" + "="*70)
    print("              FIL INTEGRITET VERIFICERING MED SHA256")
    print("="*70)
    
    print("\nVælg en funktion:")
    print("1. Beregn hash for en fil")
    print("2. Verificer fil mod kendt hash")
    print("3. Opret test fil og beregn hash")
    
    valg = input("\nDit valg (1-3): ").strip()
    
    if valg == "1":
        # Beregn hash for fil
        fil_sti = input("\nIndtast sti til fil: ").strip()
        
        if os.path.exists(fil_sti):
            print()
            vis_fil_info(fil_sti)
            print("\n🔄 Beregner SHA256 hash...")
            hash_værdi = beregn_sha256(fil_sti)
            
            if hash_værdi:
                print(f"\n✅ SHA256 Hash:\n{hash_værdi}")
                print("\n💡 Gem denne hash værdi for senere verificering!")
        else:
            print(f"\n❌ Filen '{fil_sti}' findes ikke!")
    
    elif valg == "2":
        # Verificer fil
        fil_sti = input("\nIndtast sti til fil: ").strip()
        
        if not os.path.exists(fil_sti):
            print(f"\n❌ Filen '{fil_sti}' findes ikke!")
            return
        
        vis_fil_info(fil_sti)
        
        kendt_hash = input("\nIndtast den kendte SHA256 hash: ").strip()
        
        if len(kendt_hash) != 64:
            print("\n⚠️  Advarsel: SHA256 hash skal være 64 tegn lang!")
            fortsæt = input("Fortsæt alligevel? (j/n): ").strip().lower()
            if fortsæt != 'j':
                return
        
        verificer_fil(fil_sti, kendt_hash)
    
    elif valg == "3":
        # Opret test fil
        print()
        test_fil, hash_værdi = opret_test_fil()
        
        print("\n" + "="*70)
        print("Test scenario:")
        print("="*70)
        print("\n1. Prøv at verificere filen nu (vælg option 2)")
        print("2. Rediger test_dokument.txt og verificer igen")
        print("3. Se hvordan hash ændrer sig når filen ændres!")
        
        print(f"\n💾 Brug denne hash til verificering:")
        print(f"   {hash_værdi}")
    
    else:
        print("\n❌ Ugyldigt valg!")

# Kør programmet
if __name__ == "__main__":
    try:
        menu_mode()
        print("\n" + "="*70)
        print("✅ Færdig!\n")
    
    except KeyboardInterrupt:
        print("\n\n👋 Afbrudt af bruger. Farvel!\n")
    except Exception as e:
        print(f"\n❌ Uventet fejl: {e}\n")