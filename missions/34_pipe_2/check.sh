#!/bin/bash

y=$(cat "$GASH_TMP/nbImpayes")
read -erp "Combien y a t'il de dettes impayées ? " d

x=$(checksum "$d")

if [ "$NB_CMD" -ge 0 ] && [ "$x" == "$y" ]
then
    PROMPT_COMMAND=$OLD_PROMPT_COMMAND
    unset OLD_PROMPT_COMMAND NB_CMD y x d
    true
else
    PROMPT_COMMAND=$OLD_PROMPT_COMMAND
    unset OLD_PROMPT_COMMAND NB_CMD y x d
    false
fi
