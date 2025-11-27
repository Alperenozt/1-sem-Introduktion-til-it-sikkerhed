🐧 Linux Commands Øvelser. 

Dette repository indeholder mine øvelser, der udgør en rundtur i Linux. Gennem disse øvelser arbejder jeg selvstændigt med centrale applikationer i Kali Linux på egen hardware.

Nedenfor gennemføres en række øvelser inden for følgende emner:

---

 📂 1) Filsystem

| Opgave | Kommando |
| :--- | :--- |
| Find din nuværende sti og gå til din hjemmemappe. | `pwd && cd ~` |
| Opret `~/kali-ovelser/fs` med `data` og `tmp` som undermapper. | `mkdir -p ~/kali-ovelser/fs/{data,tmp}` |
| Lav filen `notes.txt` i `data` med teksten "hej kali". | `echo "hej kali" > ~/kali-ovelser/fs/data/notes.txt` |
| Flyt `notes.txt` til `tmp` og omdøb den til `.hidden_notes`. | `mv ~/kali-ovelser/fs/data/notes.txt ~/kali-ovelser/fs/tmp/.hidden_notes` |

---

👤 2) Brugere og grupper

| Opgave | Kommando |
| :--- | :--- |
| Vis dit brugernavn og hvilke grupper du er i. | `id` |
| Slå din bruger op i `/etc/passwd`. | `grep "^$USER:" /etc/passwd` |
| Opret gruppen `lab` og tilføj din bruger til den (hvis muligt). | `sudo groupadd lab 2>/dev/null || true && sudo usermod -aG lab $USER` |

---

⚙️ 3) Processer

| Opgave | Kommando |
| :--- | :--- |
| Vis processer for din bruger. | `ps -u $USER` |
| Find PID for din nuværende shell. | `echo $$` |
| Start `sleep 60` i baggrunden og vis at den kører. | `sleep 60 & jobs` |

---

💻 4) Resurser (CPU, RAM, disk)

| Opgave | Kommando |
| :--- | :--- |
| Vis et snapshot af CPU og RAM. | `top -b -n1 | head -n 10` |
| Vis brug af monterede filerystemer. | `df -h` |
| Mål hvor lang tid `ls /` tager. | `time ls / >/dev/null` |

---

🌐 5) Netværk

| Opgave | Kommando |
| :--- | :--- |
| Vis dine netværksinterfaces og IP-adresser. | `ip a` |
| Ping `kali.org` med 3 pakker. | `ping -c 3 kali.org` |
| Se hvilke processer der lytter på lokale porte. | `ss -tulpn` (brug `sudo` hvis krævet) |

---

🛠️ 6) Systeminfo & environment

| Opgave | Kommando |
| :--- | :--- |
| Vis kernel-version og maskine-arkitektur. | `uname -r && uname -m` |
| Vis miljøvariablen PATH. | `echo "$PATH"` |

---

📦 7) Installering & opdatering (APT)

| Opgave | Kommando |
| :--- | :--- |
| Opdater pakkelister. | `sudo apt update` |
| Søg efter pakken `jq`. | `apt search jq | head -n 10` |
| Installer `jq`, vis versionen, og fjern den igen. | `sudo apt install -y jq && jq --version && sudo apt remove -y jq` |

---

 📜 8) Logging (basic)

| Opgave | Kommando |
| :--- | :--- |
| Se de sidste 20 linjer i systemjournalen. | `journalctl -n 20 --no-pager` |
| Se de sidste 20 linjer for ssh-servicen. | `journalctl -u ssh.service -n 20 --no-pager` (eller `sshd.service`) |
| Se de seneste APT-hændelser (pakkehistorik). | `grep -E '^(Start-Date|Commandline):' /var/log/apt/history.log | tail -n 20` |
| Følg i realtid en logfil i ~10 sekunder og stop med Ctrl+C. | `sudo tail -f /var/log/auth.log` (stop med **Ctrl+C**) |
| List de 5 største filer i `/var/log` (overblik). | `sudo ls -lhS /var/log | head -n 5` |

---

🔧 9) Processer & services

| Opgave | Kommando |
| :--- | :--- |
| Kør `ping -c 10 8.8.8.8` og stop den med Ctrl+C. | `ping -c 10 8.8.8.8` (stop med **Ctrl+C**) |
| Start `sleep 120` i baggrunden og stop den igen. | `sleep 120 & kill %1` (eller `kill <PID>`) |
| Tjek status for ssh-service. | `systemctl status ssh` |

---

🔐 10) Kryptografi (basic): hash, kryptering, signatur

| Opgave | Kommando |
| :--- | :--- |
| **Hash:** Lav SHA-256 hash af `.hidden_notes` og gem. | `(cd ~/kali-ovelser/fs/tmp && sha256sum .hidden_notes > notes.sha256)` |
| **Hash:** Verificér hashen. | `(cd ~/kali-ovelser/fs/tmp && sha256sum -c notes.sha256)` |
| **Kryptering:** Krypter `.hidden_notes` symmetrisk. | `(cd ~/kali-ovelser/fs/tmp && gpg --symmetric --output notes.gpg .hidden_notes)` |
| **Dekryptering:** Dekrypter filen og verificér. | `(cd ~/kali-ovelser/fs/tmp && gpg --decrypt --output notes.dec notes.gpg && diff -u .hidden_notes notes.dec || true)` |
| **Signering:** Opret GPG nøglepar (engang). | `gpg --quick-generate-key "Lab User" default default never` |
| **Signering:** Signér `.hidden_notes` (detach). | `(cd ~/kali-ovelser/fs/tmp && gpg --output notes.sig --detach-sign .hidden_notes)` |
| **Verifikation:** Verificér signaturen. | `(cd ~/kali-ovelser/fs/tmp && gpg --verify notes.sig .hidden_notes)` |

---

### 🔐 11) AI i shell

| Opgave | Link |
| :--- | :--- |
| Undersøg applikationen `shell-gpt`. | [shell-gpt: https://pypi.org/project/shell-gpt/](https://pypi.org/project/shell-gpt/) |
