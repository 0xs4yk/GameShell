#!/bin/bash

_local_check() {
    # turn history on (off by default for non-interactive shells
    HISTFILE=$GASH_DATA/history

    local pc
    pc=$(fc -nl -2 -2 | grep 'tail')

    local goal
    goal=$(CANONICAL_PATH "$GASH_HOME/Montagne/Grotte")
    local current
    current=$(CANONICAL_PATH "$PWD")

    local expected
    expected=$(tail -n 4 "$GASH_HOME/Montagne/Grotte/ingredients_potion")
    local res
    res=$($pc)

    if [ "$goal" != "$current" ]
    then
        echo "Vous n'êtes pas dans la grotte, avec l'ermite !"
        return 1
    fi
    if [ -z "$pc" ]
    then
        echo "Vous n'avez pas utilisé la commande tail"
        return 1
    fi
    if [ "$res" != "$expected" ]
    then
        echo "Votre commande ne fournit pas le bon résultat..."
        return 1
    fi
    return 0
}


if _local_check
then
    unset -f _local_check
    true
else
    unset -f _local_check
    false
fi
