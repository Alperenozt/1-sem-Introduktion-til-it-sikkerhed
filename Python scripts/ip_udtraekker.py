import re
from collections import Counter
import os

def find_ipv4_adresser(tekst):
    """
    Finder alle IPv4-adresser i en tekst ved hjælp af regular expressions.
    
    Args:
        tekst (str): Teksten der skal søges i
    
    Returns:
        list: Liste af fundne IPv4-adresser
    """
    # Regular expression pattern for IPv4 (0-255.0-255.0-255.0-255)
    # Dette matcher gyldige IPv4 adresser
    ipv4_pattern = r'\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b'
    
    # Find alle matches
    ip_adresser = re.findall(ipv4_pattern, tekst)
    
    return ip_adresser

def analyser_logfil(fil_sti):
    """
    Analyserer en logfil og udtrækker IP-adresser.
    
    Args:
        fil_sti (str): Stien til logfilen
    
    Returns:
        Counter: Counter objekt med IP-adresser og antal forekomster
    """
    alle_ip_adresser = []
    
    try:
        print(f"\n{'='*70}")
        print(f"📄 Læser logfil: {fil_sti}")
        print("="*70 + "\n")
        
        with open(fil_sti, 'r', encoding='utf-8', errors='ignore') as f:
            linje_nummer = 0
            
            for linje in f:
                linje_nummer += 1
                
                # Find IP-adresser i linjen
                ip_adresser = find_ipv4_adresser(linje)
                alle_ip_adresser.extend(ip_adresser)
        
        print(f"✓ Læste {linje_nummer} linjer")
        print(f"✓ Fandt {len(alle_ip_adresser)} IP-adresser i alt")
        
        # Tæl unikke IP-adresser
        ip_counter = Counter(alle_ip_adresser)
        print(f"✓ Fandt {len(ip_counter)} unikke IP-adresser\n")
        
        return ip_counter
    
    except FileNotFoundError:
        print(f"❌ Fejl: Filen '{fil_sti}' findes ikke!")
        return Counter()
    except PermissionError:
        print(f"❌ Fejl: Ingen adgang til '{fil_sti}'")
        return Counter()
    except Exception as e:
        print(f"❌ Fejl ved læsning af fil: {e}")
        return Counter()

def vis_resultater(ip_counter, top_n=10):
    """
    Viser resultaterne af IP-analyse.
    
    Args:
        ip_counter (Counter): Counter med IP-adresser
        top_n (int): Antal top IP'er der skal vises
    """
    if not ip_counter:
        print("❌ Ingen IP-adresser fundet!")
        return
    
    print("="*70)
    print("📊 ANALYSE RESULTATER")
    print("="*70)
    
    total_requests = sum(ip_counter.values())
    
    print(f"\n📈 Total antal requests: {total_requests}")
    print(f"🌐 Unikke IP-adresser: {len(ip_counter)}")
    
    # Vis top IP-adresser
    print(f"\n🏆 Top {top_n} mest aktive IP-adresser:")
    print("-"*70)
    print(f"{'Rank':<6} {'IP-adresse':<18} {'Antal':<10} {'Procent':<10}")
    print("-"*70)
    
    for rank, (ip, count) in enumerate(ip_counter.most_common(top_n), 1):
        procent = (count / total_requests) * 100
        print(f"{rank:<6} {ip:<18} {count:<10} {procent:.2f}%")
    
    # Statistik
    print("\n" + "="*70)
    print("📊 STATISTIK:")
    print("="*70)
    
    counts = list(ip_counter.values())
    print(f"Højeste antal requests fra én IP: {max(counts)}")
    print(f"Laveste antal requests fra én IP: {min(counts)}")
    print(f"Gennemsnitligt antal requests per IP: {sum(counts) / len(counts):.2f}")

def gem_resultater(ip_counter, output_fil="ip_analyse.txt"):
    """
    Gemmer analyseresultater til en fil.
    
    Args:
        ip_counter (Counter): Counter med IP-adresser
        output_fil (str): Filnavn til output
    """
    try:
        with open(output_fil, 'w', encoding='utf-8') as f:
            f.write("IP ADRESSE ANALYSE RAPPORT\n")
            f.write("="*70 + "\n\n")
            
            total = sum(ip_counter.values())
            f.write(f"Total requests: {total}\n")
            f.write(f"Unikke IP-adresser: {len(ip_counter)}\n\n")
            
            f.write("ALLE IP-ADRESSER (sorteret efter antal):\n")
            f.write("-"*70 + "\n")
            f.write(f"{'IP-adresse':<18} {'Antal':<10} {'Procent':<10}\n")
            f.write("-"*70 + "\n")
            
            for ip, count in ip_counter.most_common():
                procent = (count / total) * 100
                f.write(f"{ip:<18} {count:<10} {procent:.2f}%\n")
        
        print(f"\n✓ Resultater gemt i: {output_fil}")
        return True
    
    except Exception as e:
        print(f"\n❌ Kunne ikke gemme resultater: {e}")
        return False

def opret_test_logfil():
    """
    Opretter en test webserver logfil.
    """
    test_fil = "webserver_log.txt"
    
    log_indhold = """192.168.1.100 - - [07/Oct/2024:10:15:23 +0000] "GET /index.html HTTP/1.1" 200 2326
192.168.1.101 - - [07/Oct/2024:10:15:24 +0000] "GET /about.html HTTP/1.1" 200 1542
192.168.1.100 - - [07/Oct/2024:10:15:25 +0000] "GET /style.css HTTP/1.1" 200 8945
10.0.0.50 - - [07/Oct/2024:10:15:26 +0000] "GET /products.html HTTP/1.1" 200 4521
192.168.1.102 - - [07/Oct/2024:10:15:27 +0000] "POST /login HTTP/1.1" 200 156
192.168.1.100 - - [07/Oct/2024:10:15:28 +0000] "GET /contact.html HTTP/1.1" 200 2145
10.0.0.50 - - [07/Oct/2024:10:15:29 +0000] "GET /images/logo.png HTTP/1.1" 200 15478
192.168.1.103 - - [07/Oct/2024:10:15:30 +0000] "GET /index.html HTTP/1.1" 200 2326
192.168.1.100 - - [07/Oct/2024:10:15:31 +0000] "GET /api/data HTTP/1.1" 200 845
10.0.0.51 - - [07/Oct/2024:10:15:32 +0000] "GET /admin HTTP/1.1" 403 195
192.168.1.101 - - [07/Oct/2024:10:15:33 +0000] "GET /products.html HTTP/1.1" 200 4521
192.168.1.100 - - [07/Oct/2024:10:15:34 +0000] "GET /cart HTTP/1.1" 200 3214
10.0.0.50 - - [07/Oct/2024:10:15:35 +0000] "POST /checkout HTTP/1.1" 200 542
192.168.1.104 - - [07/Oct/2024:10:15:36 +0000] "GET /index.html HTTP/1.1" 200 2326
192.168.1.100 - - [07/Oct/2024:10:15:37 +0000] "GET /logout HTTP/1.1" 302 0
10.0.0.50 - - [07/Oct/2024:10:15:38 +0000] "GET /search?q=python HTTP/1.1" 200 6547
203.0.113.45 - - [07/Oct/2024:10:15:39 +0000] "GET /robots.txt HTTP/1.1" 404 162
192.168.1.100 - - [07/Oct/2024:10:15:40 +0000] "GET /blog HTTP/1.1" 200 8754
10.0.0.50 - - [07/Oct/2024:10:15:41 +0000] "GET /blog/post-1 HTTP/1.1" 200 5421
203.0.113.45 - - [07/Oct/2024:10:15:42 +0000] "GET /sitemap.xml HTTP/1.1" 200 1245
"""
    
    with open(test_fil, 'w', encoding='utf-8') as f:
        f.write(log_indhold)
    
    print(f"✓ Test logfil oprettet: {test_fil}")
    print(f"✓ Filen indeholder Apache/Nginx stil webserver logs\n")
    
    return test_fil

def test_regex_pattern():
    """
    Tester regular expression pattern med forskellige eksempler.
    """
    print("\n" + "="*70)
    print("🧪 TEST AF REGEX PATTERN")
    print("="*70 + "\n")
    
    test_tekster = [
        "Gyldig IP: 192.168.1.1",
        "Flere IPs: 10.0.0.1 og 172.16.0.1",
        "Ugyldig: 256.1.1.1 og 192.168.1.256",
        "Edge case: 0.0.0.0 og 255.255.255.255",
        "I log: 192.168.1.100 - - [07/Oct/2024] GET /",
    ]
    
    for tekst in test_tekster:
        ips = find_ipv4_adresser(tekst)
        print(f"Tekst: {tekst}")
        print(f"Fundet: {ips if ips else 'Ingen IP-adresser'}\n")

# Hovedprogram
if __name__ == "__main__":
    print("\n" + "="*70)
    print("           IP-ADRESSE UDTRÆKKER FRA LOGFILER")
    print("="*70)
    
    print("\nVælg en funktion:")
    print("1. Analyser eksisterende logfil")
    print("2. Opret og analyser test logfil")
    print("3. Test regex pattern")
    
    valg = input("\nDit valg (1-3): ").strip()
    
    if valg == "1":
        fil_sti = input("\nIndtast sti til logfil: ").strip()
        
        if not os.path.exists(fil_sti):
            print(f"\n❌ Filen '{fil_sti}' findes ikke!")
        else:
            ip_counter = analyser_logfil(fil_sti)
            
            if ip_counter:
                vis_resultater(ip_counter)
                
                # Gem resultater?
                gem = input("\nVil du gemme resultaterne? (j/n): ").strip().lower()
                if gem == 'j':
                    output_navn = input("Filnavn (Enter=ip_analyse.txt): ").strip() or "ip_analyse.txt"
                    gem_resultater(ip_counter, output_navn)
    
    elif valg == "2":
        test_fil = opret_test_logfil()
        
        print("Analyserer test logfil...\n")
        ip_counter = analyser_logfil(test_fil)
        
        if ip_counter:
            vis_resultater(ip_counter)
            
            print("\n💡 TIP: Du kan nu:")
            print(f"   - Åbne og se '{test_fil}'")
            print("   - Ændre filen og analysere igen")
            print("   - Bruge den som reference til dine egne logfiler")
    
    elif valg == "3":
        test_regex_pattern()
    
    else:
        print("\n❌ Ugyldigt valg!")
    
    print("\n✅ Færdig!\n")