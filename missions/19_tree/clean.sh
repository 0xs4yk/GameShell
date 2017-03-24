#!/bin/bash

# mise à jours du répertoire courant, qui pourrait être supprimé lors du ménage
case $PWD in
    *labyrinthe*)
        cd "$(find $GASH_HOME/Chateau/Cave/ -type d -name '.Long*Couloir*')" &&
            echo "Vous voila téléporté à l'entrée du labyrinthe..."
        ;;
esac

rm -f $GASH_VAR/argent
find $GASH_HOME/Chateau/Cave/ -name "labyrinthe" -type d -print0 | xargs -0 rm -rf
find $GASH_HOME -iname "*argent*" | xargs rm -f
