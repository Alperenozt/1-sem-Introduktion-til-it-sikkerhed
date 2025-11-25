def lommeregner():
    """
    Simpel lommeregner der tager to tal og en operator som input.
    """
    print("\n" + "="*50)
    print("           SIMPEL LOMMEREGNER")
    print("="*50)
    print("\nTilgængelige operatorer: +, -, *, /\n")
    
    try:
        # Få input fra brugeren
        tal1 = float(input("Indtast første tal: "))
        operator = input("Indtast operator (+, -, *, /): ").strip()
        tal2 = float(input("Indtast andet tal: "))
        
        # Udfør beregningen baseret på operator
        if operator == "+":
            resultat = tal1 + tal2
            print(f"\n✓ {tal1} + {tal2} = {resultat}")
        
        elif operator == "-":
            resultat = tal1 - tal2
            print(f"\n✓ {tal1} - {tal2} = {resultat}")
        
        elif operator == "*":
            resultat = tal1 * tal2
            print(f"\n✓ {tal1} × {tal2} = {resultat}")
        
        elif operator == "/":
            if tal2 == 0:
                print("\n❌ Fejl: Kan ikke dividere med 0!")
            else:
                resultat = tal1 / tal2
                print(f"\n✓ {tal1} ÷ {tal2} = {resultat}")
        
        else:
            print(f"\n❌ Fejl: '{operator}' er ikke en gyldig operator!")
            print("Brug venligst: +, -, *, /")
    
    except ValueError:
        print("\n❌ Fejl: Du skal indtaste gyldige tal!")
    except Exception as e:
        print(f"\n❌ Der opstod en fejl: {e}")
    
    print("\n" + "="*50)

# Kør lommeregneren
if __name__ == "__main__":
    lommeregner()
    
    # Spørg om brugeren vil lave flere beregninger
    while True:
        igen = input("\nVil du lave en ny beregning? (j/n): ").strip().lower()
        if igen == "j":
            lommeregner()
        else:
            print("\n👋 Farvel!\n")
            break