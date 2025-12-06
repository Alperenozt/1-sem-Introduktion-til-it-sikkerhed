#!/bin/bash

# Script til at vise dato og klokkeslæt
# Forfatter: [Dit navn]
# Dato: $(date +%Y-%m-%d)

echo "Nuværende dato og tid:"
date

echo ""
echo "Formateret visning:"
date "+%A den %d. %B %Y kl. %H:%M:%S"

echo ""
echo "Kort format:"
date "+%d-%m-%Y %H:%M"
