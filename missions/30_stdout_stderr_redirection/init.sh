#!/bin/bash

mkdir -p "$GASH_HOME/Chateau/Observatoire"
# certains se débrouillent pour écraser merlin ! Il faut mieux le regénérer,
# même si le fichier existe !
gcc -o "$GASH_HOME/Chateau/Observatoire/merlin" "$GASH_MISSIONS"/*_stdout_stderr_redirection/merlin.c

