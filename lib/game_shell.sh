#!/usr/bin/bash

#misc functions
source "$GASH_LIB/utils.sh"

trap "_gash_exit EXIT" EXIT
trap "_gash_exit TERM" SIGTERM
# trap "_gash_exit INT" SIGINT


# log an action to the missions.log file
_log_action() {
  local nb action
  nb=$1
  action=$2
  D="$(date +%s)"
  S="$(checksum "$GASH_UID#$nb#$action#$D")"
  echo "$nb $action $D $S" >> "$GASH_DATA/missions.log"
}


# get the last started mission
_get_current_mission() {
  awk '/^#/ {next}   $2=="START" {m=$1}  END {print (m)}' "$GASH_DATA/missions.log"
}


# get next mission number
_get_next_mission() {
  local nb=$1
  [ -z "$nb" ] && nb="0"

  while true
  do
    nb=$((10#$nb + 1))
    if [ -n "$(_get_mission_nb $nb)" ]
    then
      break
    fi
  done
  echo "$nb"
}


# get the complete mission number by appending leading '0's
_get_mission_nb() {
  local nb=$1
  if [ -d $GASH_MISSIONS/${nb}_*/ ]
  then
    echo "$nb"
  elif [ -d $GASH_MISSIONS/0${nb}_*/ ]
  then
    echo "0$nb"
  elif [ -d $GASH_MISSIONS/00${nb}_*/ ]
  then
    echo "00$nb"
  else
    echo ""
  fi
}


# get the mission directory
_get_mission_dir() {
  local nb=$1
  if [ -d $GASH_MISSIONS/${nb}_* ]
  then
    echo "$GASH_MISSIONS/${nb}"_*
  fi
}


# called when gash exits
_gash_exit() {
  local nb=$(_get_current_mission)
  local signal=$1
  _log_action "$nb" "$signal"
  _gash_clean "$nb"
  # jobs -p | xargs kill -sSIGHUP     # ??? est-ce qu'il faut le garder ???
}


# display the goal of a mission given by its number
_gash_show() {
  local nb="$(_get_mission_nb "$1")"
  if [ -z "$nb" ]
  then
    echo "Problème : mauvaise mission '$nb' (_gash_show)"
    return 1
  fi

  local MISSION_DIR="$(_get_mission_dir "$nb")"

  if [ -f "$MISSION_DIR/goal.txt" ]
  then
    parchment "$MISSION_DIR/goal.txt"
  fi
}


# start a mission given by its number
_gash_start() {
  local nb D S
  if [ -z "$1" ]
  then
    nb=$(_get_current_mission)
  else
    nb=$1
  fi

  [ -z "$nb" ] && nb=1
  nb="$(_get_mission_nb $nb)"

  if [ -z "$nb" ]
  then
    echo "Problème : mauvaise mission '$nb' (_gash_start)"
    return 1
  fi

  local MISSION_DIR="$(_get_mission_dir "$nb")"

  ### tester le fichier deps.sh
  if [ -f "$MISSION_DIR/deps.sh" ]
  then
    if ! bash "$MISSION_DIR/deps.sh"
    then
      echo "La mission est annulée"
      _log_action "$nb" "DEP_PB_CANCEL"
      _gash_start "$((nb + 1))"
      return
    fi
  fi

  if [ -f "$MISSION_DIR/init.sh" ]
  then
    # compgen -v | sort > /tmp/v1
    source "$MISSION_DIR/init.sh"
    # compgen -v | sort > /tmp/v2
    # comm -13 /tmp/v1 /tmp/v2 > /tmp/missions_var_$nb
    # rm -f /tmp/v1 /tmp/v2
    unset -f init
  fi

  _log_action "$nb" "START"
}


# restart a mission given by its number
_gash_restart() {
  local nb="$(_get_mission_nb "$1")"
  if [ -z "$nb" ]
  then
    echo "Problème : mauvaise mission '$nb' (_gash_restart)"
    return 1
  fi

  local MISSION_DIR="$(_get_mission_dir "$nb")"

  if [ -f "$MISSION_DIR/init.sh" ]
  then
    source "$MISSION_DIR/init.sh"
  fi

  _log_action "$nb" "RESTART"
}


# stop a mission given by its number
_gash_pass() {
  local nb="$(_get_mission_nb "$1")"
  if [ -z "$nb" ]
  then
    echo "Problème : mauvaise mission '$nb' (_gash_pass)"
    return 1
  fi

  _log_action "$nb" "PASS"

  _gash_clean "$nb"
  color_echo yellow "Vous avez abandonné la mission $nb..."

  nb=$(_get_next_mission "$nb")

  _gash_start "$nb"
  cat <<EOM
****************************************
*  Tapez la commande                   *
*    $ gash show                       *
*  pour découvrir l'objectif suivant.  *
****************************************
EOM
}

# applies auto.sh script, if it exists
_gash_auto() {
  local nb=$1

  nb="$(_get_mission_nb "$nb")"
  if [ -z "$nb" ]
  then
    echo "Problème : mauvaise mission '$nb' (_gash_check)"
    return 1
  fi

  local MISSION_DIR="$(_get_mission_dir "$nb")"

  if [ -f "$MISSION_DIR/auto.sh" ]
  then
    source "$MISSION_DIR/auto.sh"
    _log_action "$nb" "AUTO"
    return 0
  else
    echo "Cette mission n'a pas de script automatique..."
    return 1
  fi
}


# check completion of a mission given by its number
_gash_check() {
  local nb=$1

  nb="$(_get_mission_nb "$nb")"
  if [ -z "$nb" ]
  then
    echo "Problème : mauvaise mission '$nb' (_gash_check)"
    return 1
  fi

  local MISSION_DIR="$(_get_mission_dir "$nb")"

  if [ -f "$MISSION_DIR/check.sh" ]
  then
    check_prg="$MISSION_DIR/check.sh"
  else
    echo "Problème : je ne sais pas tester la mission '$nb'"
    return 1
  fi

  if grep -q "^$nb OK" "$GASH_DATA/missions.log"
  then
    echo
    color_echo yellow "La mission $nb a déjà été validée"
    echo
  else
    source "$check_prg"
    local exit_status=$?
    unset -f check
    # compare environment before / after?

    if [ "$exit_status" -eq 0 ]
    then
      echo
      color_echo green "La mission $nb est validée"
      echo

      _log_action "$nb" "CHECK_OK"

      _gash_clean "$nb"

      # récupération de la mission suivante
      nb=$(_get_next_mission "$nb")

      if [ -f "$MISSION_DIR/treasure.sh" ]
      then
        [ -f "$MISSION_DIR/treasure.txt" ] && cat "$MISSION_DIR/treasure.txt"
        source "$MISSION_DIR/treasure.sh"
        cp "$MISSION_DIR/treasure.sh" "$GASH_CONFIG/$(basename "$MISSION_DIR" /).sh"
      fi
      _gash_start "$nb"
      cat <<EOM
****************************************
*  Tapez la commande                   *
*    $ gash show                       *
*  pour découvrir l'objectif suivant.  *
****************************************
EOM
    else
      echo
      color_echo red "La mission $nb n'est **pas** validée."
      echo

      _log_action "$nb" "CHECK_OOPS"

      _gash_clean "$nb"
      _gash_restart "$nb"
    fi
  fi
}

_gash_clean() {
  local nb="$(_get_mission_nb "$1")"
  if [ -z "$nb" ]
  then
    echo "Problème : mauvaise mission '$nb' (_gash_show)"
    return 1
  fi

  local MISSION_DIR="$(_get_mission_dir "$nb")"

  if [ -f "$MISSION_DIR/clean.sh" ]
  then
    # echo "cleaning mission '$MISSION_DIR'"
    source "$MISSION_DIR/clean.sh"
  fi
}

_gash_help() {
  parchment "$GASH_LIB"/help.txt
}

_gash_HELP() {
  parchment "$GASH_LIB"/HELP.txt
}

_gash_finish() {
  if jobs | grep -iq stopped
  then
    cat <<EOM
ATTENTION, vous avez des tâches en pause...
Ces processus vont être stoppés.
(Vous pouvez obtenir la liste de ces tâches avec
$ jobs -s
)
Êtes-vous sûr de vouloir finaliser votre session ? [o/N]

EOM
    read r
    if [ "$r" != "o" -a "$r" != "O" ]
    then
      return
    fi
  fi

  _log_action "$nb" "FINISH"

  nb_journals=$(find "$GASH_HOME" -iname "*journal*" | wc -l)
  if [ "$nb_journals" -gt 1 ]
  then
    cat <<EOM
******************************************************
******************************************************

ATTENTION  ATTENTION  ATTENTION  ATTENTION  ATTENTION

Votre session contient plusieurs fichiers "journal"

EOM
    find "$GASH_HOME" -iname "*journal*"
    cat <<EOM

Il faut supprimer les fichiers en trop et ne conserver
que le "vrai" journal...
EOM
    read -p "Souhaitez-vous générer votre soumission quand même ? [o/N] " r
    if [ "$r" != "o"  -a  "$r" != "O" ]
    then
      cat <<EOM

Aucun fichier de soumissions n'a été créé...

ATTENTION  ATTENTION  ATTENTION  ATTENTION  ATTENTION

******************************************************
******************************************************
EOM
      return 1
    fi
  fi
  if [ "$nb_journals" -lt 1 ]
  then
    cat <<EOM
******************************************************
******************************************************

ATTENTION  ATTENTION  ATTENTION  ATTENTION  ATTENTION

Votre session ne contient pas de fichier "journal"

Si vous continuez, votre soumissions ne contiendra pas
de fichier "journal".
EOM
    read -p "Souhaitez-vous générer votre soumission quand même ? [o/N] " r
    if [ "$r" != "o"  -a  "$r" != "O" ]
    then
      cat <<EOM

Aucun fichier de soumissions n'a été créé...

ATTENTION  ATTENTION  ATTENTION  ATTENTION  ATTENTION

******************************************************
******************************************************
EOM
      return 1
    fi
  fi

  find "$GASH_DATA" -iname "*journal*" -print0 | xargs -0 rm -f
  find "$GASH_HOME" -iname "*journal*" -print0 | xargs -0 -I JOURNAL cp --backup=numbered JOURNAL "$GASH_DATA"

  tarfile=$REAL_HOME/GameShell_$(whoami)-LOG.tgz
  if tar -zcf "$tarfile" -C "$GASH_BASE" "$(basename $GASH_DATA)"
  then
    cat <<EOM
++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++

Une archive contenant les fichiers à envoyer à votre
encadrant a été créée dans votre répertoire personnel.
Le fichier se trouve ici :

$tarfile

++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++
EOM
    exit 0
  else
    cat <<EOM
******************************************************
******************************************************

ATTENTION  ATTENTION  ATTENTION  ATTENTION  ATTENTION

Un problème a été rencontré pendant la création de
l'archive contenant les fichiers à envoyer à votre
encadrant.

Si le fichier

$tarfile

existe, vous pouvez vérifier son contenu. Il doit y
avoir les fichiers suivants :
  - .../passeport.txt
  - .../missions.log
  - .../uid
  - .../journal.txt
  - .../history
  - .../script              (facultatif)

Si tous ces fichiers existent, vous pouvez l'envoyer.
Sinon, demandez à votre encadrant de TP...

ATTENTION  ATTENTION  ATTENTION  ATTENTION  ATTENTION

******************************************************
******************************************************
EOM
  fi
}


_gash_save() {
  if jobs | grep -iq stopped
  then
    cat <<EOM
ATTENTION, vous avez des tâches en pause...
Ces processus vont être stoppés.
(Vous pouvez obtenir la liste de ces tâches avec
$ jobs -s
)
Les changements non enregistrés ne seront pas sauvés.

Êtes-vous sûr de vouloir sauver ? [o/N]

EOM
    read r
    if [ "$r" != "o" -a "$r" != "O" ]
    then
      return
    fi
  fi

  _log_action "$nb" "SAVE"

  tarfile=$REAL_HOME/GameShell_$(whoami)-SAVE.tgz
  tar -zcf "$tarfile" -C "$GASH_BASE/.." "$(basename $GASH_BASE)"
  cat <<EOM
******************************************************
******************************************************

Une archive contenant l'état courant a été créée dans
votre répertoire personnel. Le fichier se trouve ici :

$tarfile

Vous pouvez transférer ce fichier sur un autre
ordinateur, à la racine de votre répertoire personnel,
et rétablir votre sauvegarde avec la commande

$ tar -zxvf $(basename "$tarfile")

******************************************************
******************************************************
EOM
  exit 0
}



gash() {
  local cmd=$1
  if [ -z "$cmd" ]
  then
    cat <<EOH
gash <commande>
commandes possibles : check, finish, help, restart, show, stop
EOH
  fi

  local nb="$(_get_current_mission)"

  case $cmd in
    "c" | "ch" | "che" | "chec" | "check")
      _gash_check "$nb"
      ;;
    "h" | "he" | "hel" | "help")
      _gash_help
      ;;
    "H" | "HE" | "HEL" | "HELP")
      _gash_HELP
      ;;
    "f" | "fi" | "fin" | "fini" | "finis" | "finish")
      _gash_finish
      ;;
    "sa" | "sav" | "save")
      _gash_save
      ;;
    "r" | "re" | "res" | "rest" | "resta" | "restar" | "restart")
      _gash_clean "$nb"
      _gash_restart "$nb"
      ;;
    "sh" | "sho" | "show")
      _gash_show "$nb"
      ;;
    "stat")
      awk -v GASH_UID="$GASH_UID" -f "$GASH_BIN/stat.awk" < "$GASH_DATA/missions.log"
      ;;

    # admin stuff
    # TODO: something to regenerate static world
    "pass")
      admin_mode
      if [ "$GASH_ADMIN" = "OK" ]
      then
        _gash_pass "$nb"
      else
        echo "oups..."
      fi
      ;;
    "auto")
      admin_mode
      if [ "$GASH_ADMIN" = "OK" ]
      then
        _gash_auto "$nb"
      else
        echo "oups..."
      fi
      ;;
    "clean")
      admin_mode
      if [ "$GASH_ADMIN" = "OK" ]
      then
        _gash_clean "$nb"
      else
        echo "oups..."
      fi
      ;;
    "start")
      admin_mode
      if [ "$GASH_ADMIN" = "OK" ]
      then
        if [ -n "$2" ]
        then
          _gash_clean "$nb"
          _gash_start "$2"
        else
          echo "Il faut donner un numero de mission"
        fi
      else
        echo "oups..."
      fi
      ;;
    *)
      echo "commande inconnue: '$cmd'"
      return 1
      ;;
  esac
}

# vim: shiftwidth=2 tabstop=2 softtabstop=2
