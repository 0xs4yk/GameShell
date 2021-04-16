#!/bin/bash

IN_ENTRANCE=$(CANONICAL_PATH "$(eval_gettext "\$GASH_TMP/in_entrance")")
CASTLE_ENTRANCE=$(CANONICAL_PATH "$(eval_gettext "\$GASH_HOME/Castle/Entrance")")
GASH_HUT=$(CANONICAL_PATH "$(eval_gettext "\$GASH_HOME/Forest/Hut")")
HAY=$(gettext "hay")
GRAVEL=$(gettext "gravel")
DETRITUS=$(gettext "detritus")
ORNEMENT=$(gettext "ornement")

check () {

    if ! diff -q "$IN_ENTRANCE" <(command ls "$CASTLE_ENTRANCE" | sort) > /dev/null
    then
        echo "$(gettext "You have changed the contents of the entrance!")"
        return 1
    fi

    if [ ! -d "$GASH_HUT" ]
    then
        echo "$(gettext "Where is the hut???")"
        return 1
    fi

    if [ -z "$GASH_HUT" ]
    then
        echo "$(gettext "Where is the hut???")"
        return 1
    fi

    if command ls "$GASH_HUT" | grep -Eq "_${HAY}|_${GRAVEL}|_${DETRITUS}"
    then
        echo "$(gettext "I wanted only the ornements of the entrance!")"
        return 1
    fi

    if ! diff -q <(grep "_${ORNEMENT}" "$IN_ENTRANCE") <(command ls "$GASH_HUT" | sort | grep "_${ornement}") > /dev/null
    then
        echo "$(gettext "I wanted all the entrance ornements!")"
        return 1
    fi

}

if check
then
    rm -f "$IN_ENTRANCE"
    unset -f check IN_ENTRANCE CASTLE_ENTRANCE GASH_HUT HAY GRAVEL DETRITUS ORNEMENT
    true
else
    rm -f "$IN_ENTRANCE"
    find "$CASTLE_ENTRANCE" \( -name "*${ORNEMENT}" -o -name "*${DETRITUS}" -o -name "*${GRAVEL}" -o -name "*${HAY}" \) -print0 | xargs -0 rm -f
    mkdir -p "$GASH_HUT"
    find "$GASH_HUT" \( -name "*${ORNEMENT}" -o -name "*${DETRITUS}" -o -name "*${GRAVEL}" -o -name "*${HAY}" \) -print0 | xargs -0 rm -f
    unset -f check IN_ENTRANCE CASTLE_ENTRANCE GASH_HUT HAY GRAVEL DETRITUS ORNEMENT
    false
fi

