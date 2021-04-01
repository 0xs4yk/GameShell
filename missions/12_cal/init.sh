#!/bin/bash

# fichier lu par le shell à chaque démarrage de la mission

YYYY=$((1900 + RANDOM % 200))
MM=$( echo "00$((1 + RANDOM % 12))" | tail -c3 )
DD=$( echo "00$((1 + RANDOM % 28))" | tail -c3 )

sed -i "s/[0-9]\{2\}-[0-9]\{2\}-[0-9]\{4\}/$DD-$MM-$YYYY/" "$MISSION_DIR"/goal.txt

