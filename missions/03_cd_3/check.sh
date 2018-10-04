#!/bin/bash

# TODO : better check ???

# turn history on (off by default for non-interactive shells
HISTFILE=$GASH_DATA/history

ppc=$(fc -nl -3 -3 | xargs)      # note: xargs removes the trailing spaces

goal=$(CANNONICAL_PATH "$GASH_HOME/Chateau/Batiment_principal/Salle_du_trone")
current=$(CANNONICAL_PATH "$PWD")

if [ "$goal" = "$current"  -a  "$ppc" = "cd" ]
then
    unset ppc goal current
    true
else
    unset ppc goal current
    false
fi

