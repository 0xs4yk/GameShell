#!/bin/bash

echo "Quel est la clé qui fait apparaitre le coffre de Merlin ? "
read -e dcode
if [ "$dcode" = "$_secret_key" ]
then
    unset dcode _secret_key
    mkdir -p "$GASH_HOME/Chateau/Cave/Coffre_de_merlin"                       # je met le coffre
    cp "$GASH_MISSIONS"/*_tr/recette_secrete "$GASH_HOME/Chateau/Cave/Coffre_de_merlin" # et son contenu (cela ne sert à rien pour la mission, mais si 
    true                                                                    # l'utilisateur à la curiosité d'aller voir, il y aura qqch)
else
    echo "Ce n'est pas la bonne clé.."
    unset dcode _secret_key
    false
fi

