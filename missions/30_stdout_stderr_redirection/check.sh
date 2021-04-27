#!/bin/bash

secret="MRGLPZYMAMLAJNBWRQPYACQBDYUFWQFUWVXQELCCGCJZUEJUEZXLDYQPVHLHGLXKZJAAUKKFCTQJQKMMCNLUUEFFYEYPHNWCMKDMBKQAJPSHGBTJJQKDAAPCWFHTKGLTWRFTEWMPDHCHQNVVLHDWNMLFCLEAZWCQLVBXFFRRZMMJGLMKEVUXXDHUCHWAYQJFWAUYEHUP"

read -erp "$(gettext "What is the secret key?") " r

if [ "$secret" = "$r" ]
then
    unset secret r
    true
else
    unset secret r
    false
fi
