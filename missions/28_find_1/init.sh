#!/bin/bash


coul=$(find $GASH_HOME/Chateau/Cave/ -name ".couloir * tres * long *")
if [ -z "$coul" ]
then
    coul=".couloir $(checksum $RANDOM) tres $(checksum $RANDOM) long $(checksum $RANDOM)"
    mkdir -p $GASH_HOME/Chateau/Cave/"$coul"
    coul=$(find $GASH_HOME/Chateau/Cave/ -name ".couloir * tres * long *")
fi

lab=$coul/labyrinthe

t=$(date +%s)

N=10
r1="$((1 + $RANDOM%$N)),$((1 + $RANDOM%$N)),$((1 + $RANDOM%$N))"
r2="$((1 + $RANDOM%$N)),$((1 + $RANDOM%$N)),$((1 + $RANDOM%$N))"

echo -n "génération du labyrinthe : "
for i in $(seq $N)
do
    I=$(checksum $t$i)
    mkdir -p "$lab/$I"
    for j in $(seq $N)
    do
        J=$(checksum $t$i$j)
        mkdir -p "$lab/$I/$J"
        for k in $(seq $N)
        do
            K=$(checksum $t$i$j$k)
            mkdir -p "$lab/$I/$J/$K"

            if [ "$r1" = "$i,$j,$k" ]
            then
                echo "$I $J $K" > "$lab/$I/$J/$K/piece_d_or"
                echo "$I $J $K" > "$GASH_VAR/piece_d_or"
            elif [ "$r2" = "$i,$j,$k" ]
            then
                echo "$I $J $K" > "$lab/$I/$J/$K/Piece_D_Or"
                echo "$I $J $K" > "$GASH_VAR/Piece_D_Or"
            fi
        done
        echo -n "."
    done
done
echo

# mise à jours du répertoire courant, qui peut être supprimé lors du ménage
cd - &> /dev/null ; cd - &> /dev/null

unset i j k t coul lab N r1 r2 I J K


