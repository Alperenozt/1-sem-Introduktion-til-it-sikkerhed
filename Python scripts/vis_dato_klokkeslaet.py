import datetime

# Hent nuværende dato og tid
nu = datetime.datetime.now()

# Formater og print
print("Nuværende dato og tid:", nu.strftime("%d-%m-%Y %H:%M:%S"))
