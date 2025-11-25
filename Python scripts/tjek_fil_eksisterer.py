from pathlib import Path

# Angiv filnavnet, du vil tjekke
filnavn = "testfil.txt"

# Brug Path.exists() til at tjekke om filen findes
fil = Path(filnavn)

if fil.exists():
    print(f"Filen '{filnavn}' findes.")
else:
    print(f"Filen '{filnavn}' findes ikke.")
