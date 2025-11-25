import os

# Angiv stien til mappen, hvor filerne skal omdøbes
mappe = "."  # nuværende mappe

for filnavn in os.listdir(mappe):
    if filnavn.endswith(".txt"):
        nyt_navn = filnavn[:-4] + ".md"
        os.rename(os.path.join(mappe, filnavn), os.path.join(mappe, nyt_navn))
        print(f"Omdøbt: {filnavn} -> {nyt_navn}")
