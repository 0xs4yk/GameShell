#!/bin/bash

export NATURE=chat

$GASH_BIN/chat.sh &
disown
$GASH_BIN/chat.sh &
disown
$GASH_BIN/chat.sh &
disown

unset NATURE
trap "" SIGTERM SIGSTOP SIGINT
tail -f /dev/null
