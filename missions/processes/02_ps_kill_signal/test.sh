COLUMNS=512 ps -ce | awk -v spell="$(gettext "spell")" '$0 ~ spell {print $1}' | xargs kill 2> /dev/null
COLUMNS=512 ps -ce | awk -v spell="$(gettext "spell")" '$0 ~ spell {print $1}' | xargs kill -9 2> /dev/null
gsh assert check true

COLUMNS=512 ps -ce | awk -v spell="$(gettext "spell")" '$0 ~ spell {print $1}' | xargs kill -9 2> /dev/null
gsh assert check false

COLUMNS=512 ps -ce | awk -v spell="$(gettext "spell")" '$0 ~ spell {print $1}' | xargs kill 2> /dev/null
COLUMNS=512 ps -ce | awk -v spell="$(gettext "spell")" '$0 ~ spell {print $1}' | xargs kill 2> /dev/null
COLUMNS=512 ps -ce | awk -v spell="$(gettext "spell")" '$0 ~ spell {print $1}' | head -n2 | xargs kill -9 2> /dev/null
gsh assert check false
