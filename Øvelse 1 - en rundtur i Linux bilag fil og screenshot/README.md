## 🐧 Linux Commands Øvelser 

Dette repository indeholder mine øvelser, der udgør en **rundtur i Linux**. Gennem disse øvelser arbejder jeg selvstændigt med centrale applikationer i **Kali Linux** på egen hardware.

Nedenfor gennemføres en række øvelser inden for følgende emner:
---

### 📂 1) Filsystem

| Opgave/Udført | Kommando |
| :--- | :--- |
| **Start:** Fandt nuværende sti (`pwd`) og navigerede til hjemmemappe (`cd ~`). | `pwd && cd ~` |
| **Oprettelse:** Oprettet mappen `~/kali-ovelser/fs` med `data` og `tmp` som undermapper. | `mkdir -p ~/kali-ovelser/fs/{data,tmp}` |
| **Filoprettelse:** Lavede filen `notes.txt` i `data` med teksten "hej kali". | `echo "hej kali" > ~/kali-ovelser/fs/data/notes.txt` |
| **Flyt & Omdøb:** Flyttede `notes.txt` til `tmp` og omdøbte den til `.hidden_notes`. | `mv ~/kali-ovelser/fs/data/notes.txt ~/kali-ovelser/fs/tmp/.hidden_notes` |

---

### 👤 2) Brugere og grupper

| Opgave/Udført | Kommando |
| :--- | :--- |
| **ID:** Viste mit brugernavn og hvilke grupper jeg er i. | `id` |
| **Slå op:** Slået min bruger op i `/etc/passwd`. | `grep "^$USER:" /etc/passwd` |
| **Opret & Tilføj:** Oprettet gruppen `lab` og tilføjet min bruger til den. | `sudo groupadd lab 2>/dev/null || true && sudo usermod -aG lab $USER` |

---

### ⚙️ 3) Processer

| Opgave/Udført | Kommando |
| :--- | :--- |
| **Vis processer:** Viste processer for min bruger. | `ps -u $USER` |
| **PID:** Fandt PID for min nuværende shell. | `echo $$` |
| **Baggrundsjob:** Startet `sleep 60` i baggrunden og vist at den kører. | `sleep 60 & jobs` |

---

### 💻 4) Resurser (CPU, RAM, disk)

| Opgave/Udført | Kommando |
| :--- | :--- |
| **CPU/RAM:** Vist et snapshot af CPU og RAM. | `top -b -n1 | head -n 10` |
| **Diskbrug:** Vist brug af monterede filsystemer. | `df -h` |
| **Tidtagning:** Målt hvor lang tid `ls /` tager. | `time ls / >/dev/null` |

---

### 🌐 5) Netværk

| Opgave/Udført | Kommando |
| :--- | :--- |
| **Interfaces:** Vist mine netværksinterfaces og IP-adresser. | `ip a` |
| **Ping:** Pinget `kali.org` med 3 pakker. | `ping -c 3 kali.org` |
| **Lyttere:** Set hvilke processer der lytter på lokale porte. | `ss -tulpn` (brug `sudo` hvis krævet) |

---

### 🛠️ 6) Systeminfo & environment

| Opgave/Udført | Kommando |
| :--- | :--- |
| **Kernel/Arkitektur:** Vist kernel-version og maskine-arkitektur. | `uname -r && uname -m` |
| **PATH:** Vist miljøvariablen `PATH`. | `echo "$PATH"` |

---

### 📦 7) Installering & opdatering (APT)

| Opgave/Udført | Kommando |
| :--- | :--- |
| **Opdatering:** Opdateret pakkelister. | `sudo apt update` |
| **Søgning:** Søgt efter pakken `jq`. | `apt search jq | head -n 10` |
| **Install/Fjern:** Installeret `jq`, vist versionen, og fjernet den igen. | `sudo apt install -y jq && jq --version && sudo apt remove -y jq` |

---

### 📜 8) Logging (basic)

| Opgave/Udført | Kommando |
| :--- | :--- |
| **Systemjournal:** Set de sidste 20 linjer i systemjournalen. | `journalctl -n 20 --no-pager` |
| **SSH-service:** Set de sidste 20 linjer for ssh-servicen. | `journalctl -u ssh.service -n 20 --no-pager` (eller `sshd.service`) |
| **APT-historik:** Set de seneste APT-hændelser (pakkehistorik). | `grep -E '^(Start-Date|Commandline):' /var/log/apt/history.log | tail -n 20` |
| **Følg Log (Alternativ):** Fulgt logfil i realtid (~10 sekunder). | `sudo journalctl -f` (stop med **Ctrl+C**) |
| **Største Filer:** Listet de 5 største filer i `/var/log` (sorteret efter størrelse). | `sudo ls -lhS /var/log | head -n 5` |

**Bemærkning til logning i realtid:** De oprindelige kommandoer (`sudo tail -f /var/log/auth.log` og `/var/log/secure`) virkede ikke på systemet. I stedet blev **`sudo journalctl -f`** brugt til at følge systemlogge i realtid.

---

### 🔧 9) Processer & services

| Opgave/Udført | Kommando |
| :--- | :--- |
| **Ping & Stop:** Kørt `ping -c 10 8.8.8.8` og stoppet den med Ctrl+C. | `ping -c 10 8.8.8.8` (stop med **Ctrl+C**) |
| **Start & Dræb:** Startet `sleep 120` i baggrunden og stoppet den igen. | `sleep 120 & kill %1` (eller `kill <PID>`) |
| **Service Status:** Tjekket status for ssh-service. | `systemctl status ssh` |

---

### 🔐 10) Kryptografi (basic): hash, kryptering, signatur

| Opgave/Udført | Kommando |
| :--- | :--- |
| **Hash:** Lavet en SHA-256 hash af `.hidden_notes` og gemt den. | `(cd ~/kali-ovelser/fs/tmp && sha256sum .hidden_notes > notes.sha256)` |
| **Kryptering (GPG):** Krypteret `.hidden_notes` symmetrisk til en ny fil (`notes.gpg`). | `(cd ~/kali-ovelser/fs/tmp && gpg --symmetric --output notes.gpg .hidden_notes)` |
| **Dekryptering (GPG):** Dekrypteret `notes.gpg` og verificeret forskellen mod originalen. | `(cd ~/kali-ovelser/fs/tmp && gpg --decrypt --output notes.dec notes.gpg && diff -u .hidden_notes notes.dec || true)` |
| **Signering (Nøgle):** Genereret GPG nøglepar (engangsopsætning). | `gpg --quick-generate-key "Lab User" default default never` |
| **Signering (Fil):** Signéret `.hidden_notes` og gemt signaturen (`notes.sig`). | `(cd ~/kali-ovelser/fs/tmp && gpg --output notes.sig --detach-sign .hidden_notes)` |
| **Verifikation:** Verificeret signaturen (`notes.sig`) mod filen. | `(cd ~/kali-ovelser/fs/tmp && gpg --verify notes.sig .hidden_notes)` |

---

### 🔐 11) AI i shell

| Opgave/Udført | Kommando |
| :--- | :--- |
| **Undersøgelse:** Undersøgt applikationen `shell-gpt`. | [shell-gpt: https://pypi.org/project/shell-gpt/](https://pypi.org/project/shell-gpt/) |
