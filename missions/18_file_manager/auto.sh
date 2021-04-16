#!/bin/bash

mkdir -p "$GASH_CHEST"

cd "$(find "$(eval_gettext '$GASH_HOME/Castle/Cellar')" -name "$(gettext "maze")" -type d)"

find . -name "$(gettext "copper_coin")" -type f -print0 | xargs -0 mv -t "$GASH_CHEST"

gash check
