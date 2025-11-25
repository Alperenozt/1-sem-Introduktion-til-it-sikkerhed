import random
import string

def generer_adgangskode(laengde=12, store_bogstaver=True, smaa_bogstaver=True, tal=True, symboler=True):
    """
    Genererer en sikker adgangskode med specificerede krav.
    
    Args:
        laengde (int): Længden af adgangskoden
        store_bogstaver (bool): Inkluder store bogstaver (A-Z)
        smaa_bogstaver (bool): Inkluder små bogstaver (a-z)
        tal (bool): Inkluder tal (0-9)
        symboler (bool): Inkluder specialtegn (!@#$%...)
    
    Returns:
        str: Genereret adgangskode
    """
    # Byg karakter pool baseret på krav
    karakter_pool = ""
    
    if store_bogstaver:
        karakter_pool += string.ascii_uppercase  # A-Z
    
    if smaa_bogstaver:
        karakter_pool += string.ascii_lowercase  # a-z
    
    if tal:
        karakter_pool += string.digits  # 0-9
    
    if symboler:
        karakter_pool += string.punctuation  # !@#$%^&*()...
    
    # Tjek om der er valgt nogen krav
    if not karakter_pool:
        return "❌ Fejl: Mindst ét krav skal være valgt!"
    
    # Generer tilfældig adgangskode
    adgangskode = ''.join(random.choice(karakter_pool) for _ in range(laengde))
    
    return adgangskode

def valider_styrke(adgangskode):
    """
    Vurderer styrken af en adgangskode.
    
    Args:
        adgangskode (str): Adgangskoden der skal vurderes
    
    Returns:
        str: Styrke niveau
    """
    score = 0
    
    # Tjek længde
    if len(adgangskode) >= 8:
        score += 1
    if len(adgangskode) >= 12:
        score += 1
    if len(adgangskode) >= 16:
        score += 1
    
    # Tjek for forskellige karaktertyper
    if any(c.isupper() for c in adgangskode):
        score += 1
    if any(c.islower() for c in adgangskode):
        score += 1
    if any(c.isdigit() for c in adgangskode):
        score += 1
    if any(c in string.punctuation for c in adgangskode):
        score += 1
    
    # Vurder styrke
    if score >= 6:
        return "🟢 Meget Stærk"
    elif score >= 4:
        return "🟡 Stærk"
    elif score >= 2:
        return "🟠 Medium"
    else:
        return "🔴 Svag"

def vis_karakter_info():
    """
    Viser eksempler på tilgængelige karakterer.
    """
    print("\n📋 Tilgængelige karakterer:")
    print(f"   Store bogstaver: {string.ascii_uppercase}")
    print(f"   Små bogstaver:   {string.ascii_lowercase}")
    print(f"   Tal:             {string.digits}")
    print(f"   Symboler:        {string.punctuation[:20]}...")

# Hovedprogram
if __name__ == "__main__":
    print("\n" + "="*60)
    print("           SIKKER ADGANGSKODE GENERATOR")
    print("="*60)
    
    vis_karakter_info()
    
    print("\n" + "="*60)
    print("Konfigurer din adgangskode:")
    print("="*60 + "\n")
    
    try:
        # Få input fra brugeren
        laengde = input("Længde (tryk Enter for 12): ").strip()
        laengde = int(laengde) if laengde else 12
        
        if laengde < 4:
            print("⚠️  Minimum længde er 4. Bruger 4.")
            laengde = 4
        
        store = input("Inkluder store bogstaver? (j/n, Enter=j): ").strip().lower()
        store = store != 'n'
        
        smaa = input("Inkluder små bogstaver? (j/n, Enter=j): ").strip().lower()
        smaa = smaa != 'n'
        
        tal = input("Inkluder tal? (j/n, Enter=j): ").strip().lower()
        tal = tal != 'n'
        
        symboler = input("Inkluder symboler? (j/n, Enter=j): ").strip().lower()
        symboler = symboler != 'n'
        
        # Generer adgangskode
        print("\n" + "="*60)
        adgangskode = generer_adgangskode(laengde, store, smaa, tal, symboler)
        
        if adgangskode.startswith("❌"):
            print(adgangskode)
        else:
            print("🔐 Din genererede adgangskode:")
            print(f"\n   {adgangskode}\n")
            print(f"📊 Længde: {len(adgangskode)} tegn")
            print(f"💪 Styrke: {valider_styrke(adgangskode)}")
        
        print("="*60)
        
        # Generer flere?
        print("\n" + "="*60)
        flere = input("Vil du generere flere adgangskoder? (j/n): ").strip().lower()
        
        if flere == 'j':
            antal = input("Hvor mange? (1-10): ").strip()
            antal = int(antal) if antal.isdigit() else 5
            antal = min(antal, 10)  # Max 10
            
            print(f"\n🔐 {antal} tilfældige adgangskoder:\n")
            for i in range(antal):
                ny_adgangskode = generer_adgangskode(laengde, store, smaa, tal, symboler)
                print(f"   {i+1}. {ny_adgangskode}")
        
        print("\n✅ Færdig!\n")
        
    except ValueError:
        print("\n❌ Fejl: Indtast et gyldigt tal for længde!")
    except KeyboardInterrupt:
        print("\n\n👋 Afbrudt af bruger. Farvel!\n")
    except Exception as e:
        print(f"\n❌ Fejl: {e}\n")