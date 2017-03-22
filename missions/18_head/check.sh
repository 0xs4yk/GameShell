#!/bin/bash

# turn history on (off by default for non-interactive shells
HISTFILE=$GASH_DATA/history

pc=$(fc -nl -2 -2 | grep 'head')

goal=$(readlink -f $GASH_HOME/Montagne/Grotte)
current=$(readlink -f "$PWD")

expected=$(head -n 4 $GASH_HOME/Montagne/Grotte/ingredients_potion)
res=$($pc)

if [ "$goal" = "$current"  -a  \
     -n "$pc"  -a  \
     "$res" = "$expected" ]
then
    unset pc goal current expected res
    true
else
    unset pc goal current expected res
    false
fi
