import psutil

# Vis alle kørende processer og deres PID
for proces in psutil.process_iter(['pid', 'name']):
    try:
        print(f"PID: {proces.info['pid']}, Navn: {proces.info['name']}")
    except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
        pass
