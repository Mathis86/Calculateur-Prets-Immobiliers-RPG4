# PRETIMMO.RPGLE
Programme principal, gère les écrans

# PRETCALCS.RPGLE
Module qui gère tous les calculs (mensualités, intérêts, etc...)

# PRETGRAPH.RPGLE
Module qui gère les graphiques sur un écran 24x80.

## Draw(packed(10:2) dim(80))
Dessine une courbe sur le graphique en fonction de données en entrée.

## WriteTitle(varchar(30))
Écrit un titre en haut du graphique.

## WriteCaptions(varchar(30) dim(5))
Écrit une suite de légendes en haut à droite du graphique.

## GetGraphString(): char(1839)
Récupère la chaîne de caractères représentant le graphique. 

Conçu pour être affectée à une zone alphanumérique de 1839 qui prend 23 lignes et 80 colonnes à l'écran.

# EPRETIMMO.DSPF
Écrans du programme

# PRETIMMO.PRTF
Fichier d'impression du résultat du calcul
