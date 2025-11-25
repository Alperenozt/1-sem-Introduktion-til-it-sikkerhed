from pathlib import Path

# Skift stien til en eksisterende mappe, fx "C:/Users/alper/Documents" hvis du er på Windows
folder = Path("/etc")

for file in folder.glob("*.conf"):
    print(file.name)
