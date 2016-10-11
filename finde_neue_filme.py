#!/opt/bin/python3

import os
import sys
from argparse import ArgumentParser
import csv

parser = ArgumentParser()
parser.add_argument("-b", "--path-bestand", dest="pfad_bestand", default="/volume1/PrivaterShare/Filme/",
                    help="Pfad in dem die gesicherten Filme (auf dem NAS) liegen, Default /volume1/PrivaterShare/Filme/")
parser.add_argument("-n", "--path-neu", dest="pfad_neu", default="/volumeUSB2/usbshare/Filme/",
                    help="Pfad in dem die neuen Filme (auf USB) liegen, Default: /volumeUSB2/usbshare/Filme/")
# Wenn man unterwegs ist, dann kann man nicht alle Filme dabei haben
parser.add_argument("-B", "--liste_bestand", dest="liste_bestand", help="Liste mit bestehenden Filmen", default="")
parser.add_argument("-N", "--file_neu", dest="liste_neu", help="Liste mit neuen Filmen", default="")

args = parser.parse_args()

#pfad_bestand = "/volume1/PrivaterShare/Filme/"
#pfad_neu = sys.argv[1]

#print(os.listdir(pfad_bestand))
#print(os.listdir(pfad_neu))

# Auf Kommandozeile absetzen:
#find $pfad_bestand -maxdepth 1 -type d -exec basename {} \; | sort > $filme_bestand
#find $pfad_neu -maxdepth 1 -type d -exec basename {} \; | sort > $filme_neu

def getFolderSize(folder):
    total_size = 0
    for item in os.listdir(folder):
        itempath = os.path.join(folder, item)
        if os.path.isfile(itempath):
            size = os.path.getsize(itempath)
            # Es werden nur Dateien in die Analyse gezogen, welche groesser als 10 mb sind
            if size > 10240:
                total_size += os.path.getsize(itempath)
        elif os.path.isdir(itempath):
            total_size += getFolderSize(itempath)
    return total_size



# Main:
bestand = {}
neu = {}

# Zunaechst den Bestand:
# Pruefe ob Datei mit 
print ("Bestand:", args.pfad_bestand)
if os.path.isfile(args.liste_bestand):
    for ordner, size_ordner in csv.reader(open(args.liste_bestand)):
        bestand[ordner] = size_ordner
        if size_ordner == "0":
            print ("Warnung, der Ordner ist leer:", ordner)
else:
    # Test ob args.liste_bestand belegt, ansosnten befuellen
    if args.liste_bestand == "":
        file_liste_bestand = "/tmp/liste_bestand.txt"
    else:
        file_liste_bestand = args.liste_bestand

    w = csv.writer(open(file_liste_bestand, "w"))

    for ordner in os.listdir(args.pfad_bestand):
        ordner_full = os.path.join(args.pfad_bestand, ordner)
        if os.path.isdir(ordner_full):
            size_ordner = getFolderSize(ordner_full)
            if size_ordner == 0:
                print ("Warnung, der Ordner ist leer:", ordner)
            #print (ordner, size_ordner)
            bestand[ordner] = size_ordner
            w.writerow([ordner, size_ordner])

# Jetzt die neuen Filme:
print ("Neu:", args.pfad_neu)
if os.path.isfile(args.liste_neu):
    for ordner, size_ordner in csv.reader(open(args.liste_neu)):
        neu[ordner] = size_ordner
        if size_ordner == "0":
            print ("Warnung, der Ordner ist leer:", ordner)
else:
    # Test ob args.liste_neu belegt, ansosnten befuellen
    if args.liste_neu == "":
        file_liste_neu = "/tmp/liste_neu.txt"
    else:
        file_liste_neu = args.liste_neu

    # Datei zum Schreiben oeffnen
    w = csv.writer(open(file_liste_neu, "w"))

    for ordner in os.listdir(args.pfad_neu):
        ordner_full = os.path.join(args.pfad_neu, ordner)
        if os.path.isdir(ordner_full):
            size_ordner = getFolderSize(ordner_full)
            if size_ordner == 0:
                print ("Warnung, der Ordner ist leer:", ordner)
            #print (ordner, size_ordner)
            neu[ordner] = size_ordner
            w.writerow([ordner, size_ordner])

# Jetzt kommts zum Vergleich:
for film in neu.keys():
    if film in bestand:
        #print (film)
        if bestand[film] != neu[film]:
            print ("Groesse der Ordner unterscheidet sich bei", film)
            print ("bestand[film]", bestand[film])
            print ("neu[film]",neu[film])
    else:
        print("Neu:", film)

