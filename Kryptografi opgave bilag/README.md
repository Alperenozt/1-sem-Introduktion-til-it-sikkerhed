## 🔒 Kryptografiopgaver 

Dette repository dækker en række praktiske øvelser inden for kryptografi, emnerne: Historisk kryptografi, Moderne kryptografi og Anvendt kryptografi Mange af opgaverne involverer samarbejde, hvor man bytter ciffertekst og nøgler med en makker for at sikre forståelse af både kryptering og dekryptering.

--- For at se min øvelser se PDF fil. 

### 1. Historisk kryptografi

| Emne | Opgave/Handling | Centralt Værktøj/Metode |
| :--- | :--- | :--- |
| **Caesar (ROT)** | Krypter og dekrypter en besked med makker. Prøv især **ROT-13**. | Cyberchef / ROT-13 |
| **Vigenére** | Krypter og dekrypter en besked med makker ved brug af et nøgleord. | Cyberchef |
| **Steganografi (Afkod)** | Find den skjulte besked i det givne kattebillede. | Link: [Gist](https://gist.github.com/andracs/c2b6a7ae6efb179043b6728e312222ac) |
| **Steganografi (Skjul)** | Skjul en besked i en billedfil og byt med makker. | Billedbehandlingsværktøj |

---

### 2. Moderne Kryptografi

#### 2.1 Symmetrisk & Asymmetrisk Kryptering

| Emne | Opgave/Handling | Centralt Værktøj/Metode |
| :--- | :--- | :--- |
| **Symmetrisk** | Afprøv DES, Triple DES og AES. Send krypteret besked til makker og afkod. | Cyberchef |
| **RSA Nøgler** | Skab et sæt RSA nøgler (public & private). | OpenSSL / CyberChef |
| **RSA Encrypt** | Krypter din besked med **makkers public key**, Base64-encode, og send. | RSA Encrypt / Base64 Encode |
| **RSA Decrypt** | Makker skal Base64-decode og **RSA Decrypt med sin private key**. | RSA Decrypt / Base64 Decode |
| **RSA Signering** | Signer din besked med **din private key**, og send. | RSA Sign |
| **RSA Verifikation**| Makker skal **RSA Verify med din public key**. | RSA Verify |
| **ECC (ECDSA)** | Generer et ECDSA key-pair. Signer en besked, og verificer samme besked. | CyberChef / [Online ECDSA Tool](https://emn178.github.io/online-tools/ecdsa/verify/) |

#### 2.2 Encoding & Hashing

| Emne | Opgave/Handling | Centralt Værktøj/Metode |
| :--- | :--- | :--- |
| **Encoding** | Afprøv UTF-8, konverter til ASCII (observer datatab), URL Encode, Base64 og Base32 på dansk tekst (ÆØÅ, emojis ☺️👍). | CyberChef / UTF-8, ASCII |
| **PGP** | Krypter og signer en besked i Cyberchef. Dekrypter og verificer bagefter (brug PGP Generate Keypair). | PGP Generate Keypair / PGP Encrypt/Decrypt |
| **Hashing (Generering)** | Lav en kort besked og beregn forskellige hashværdier (MD4, MD5, SHA1, SHA2, SHA3). Send til makker. | CyberChef / Hash (forskellige algoritmer) |
| **Hashing (Verifikation)** | Makker skal verificere beskedens ægthed vha. de modtagne hashværdier. Gentag evt. med en fil. | Hash Verifikation |
| **Cracking (Crackstation)** | Lav en svag hash af et simpelt, engelsk password. Makker skal cracke hashen med [Crackstation](https://crackstation.net/). Diskutér "salt". | Hash (svag) / Crackstation |
| **Cracking (Hashcat)** | Prøv at cracke en MD4 hashet password med Hashcat i Kali (følg [instrukser](https://gist.github.com/andracs/e15967fc55d4b7f74011ee525d0f8b69)). | Hashcat (Kali) |
| **Cracking (Zip-fil)** | Lav en passwordbeskyttet zip-fil i Kali, og crack den bagefter. | Zip / Cracking værktøj (Kali) |

---

### 3. Anvendt Kryptografi

| Emne | Opgave/Handling | Centralt Værktøj/Metode |
| :--- | :--- | :--- |
| **TLS Certifikater** | Besøg en tilfældig hjemmeside, og undersøg hvilket certifikat den bruger for HTTPS (TLS). | Browser (Chrome/Firefox certifikatvisning) |
| **Keybase.io** | Afprøv Keybase.io: Send/modtag sikre beskeder, signer og verificer. (Læs evt. Keybase Book). | Keybase.io |
| **Onionshare** | Send en fil til din makker sikkert med OnionShare. Diskutér forskellen fra Keybase. | OnionShare / Tor |
| **Pcrypt** | Undersøg Pcrypt - en lokal virksomhed, der tilbyder kryptografi (med øje for praktikplads). | Web-research |
| **Open Source Key Mngmt** | Find og afprøv et open source password-værktøj til sikker opbevaring/deling af "secrets". | KeePass, Bitwarden e.l. |
| **Web Crypto API (1)** | Spørg Copilot: "Hvad er Web Crypto API, og hvad kan den bruges til? Forklar til en bachelorstuderende i it-sikkerhed." | [Copilot](https://copilot.cloud.microsoft/) |
| **Web Crypto API (2)** | Spørg Copilot: "Kan du give et eksempel på brug?" Memorér svaret. | [Copilot](https://copilot.cloud.microsoft/) |
| **Sikker E-mail (1)** | Spørg Copilot: "Hvordan kan jeg sende sikker mail fra gmail (eller hotmail eller andet)?" | [Copilot](https://copilot.cloud.microsoft/) |
| **Sikker E-mail (2)** | Spørg Copilot: "Hvordan kan jeg sende sikker mail fra office 365 (din edumail på skolen)?" | [Copilot](https://copilot.cloud.microsoft/) |
| **Kvantesikker Kryptografi**| Læs artiklen fra [samsik.dk](https://samsik.dk/cybersikkerhed/temaer/overgangen-til-kvantesikker-kryptografi/) og beskriv det i 6 bullet points (uden AI). | Artikellæsning |
