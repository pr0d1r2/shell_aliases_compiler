#!/bin/bash

D_R=`cd \`dirname $0\` ; pwd -P`
cd $D_R || return $?

for PARAM in $@
do
  case $PARAM in
    -o | --offline)
      OFFLINE=1
      ;;
    -s | --silent)
      SILENT=1
      ;;
  esac
done

if [ -z $OFFLINE ]; then
  git pull || return $?
fi

if [ ! -e $D_R/.config.sh ]; then
  echo "shell_aliases_compiler: $D_R/.config.sh does not exist. Using example configuration ..."
  cp $D_R/.config.sh.example $D_R/.config.sh || return $?
fi
source $D_R/.config.sh || return $?

for SOURCE in $SOURCES
do
  case $SOURCE in
    git@github.com:?*:?* | git@gitlab.com:?*:?* | https://github.com/*)
      GIT_REPO=`echo $SOURCE | cut -f 1-2 -d :`
      case $SOURCE in
        git@github.com:?*:?* | git@gitlab.com:?*:?*)
          DELIMITER_FIELD=2
          ;;
        https://github.com/*)
          DELIMITER_FIELD=5
          ;;
      esac
      PROJECT_NAME=`echo $SOURCE | cut -f $DELIMITER_FIELD -d / | cut -f 1 -d : | sed -e 's/.git//g'`
      SUBDIR=`echo $SOURCE | cut -f $DELIMITER_FIELD -d / | cut -f 2 -d :`
      if [ -z $SILENT ]; then
        echo "Using $GIT_REPO as $HOME/projects/$PROJECT_NAME/$SUBDIR"
      fi
      if [ -z $OFFLINE ]; then
        if [ ! -d ~/projects/$PROJECT_NAME ]; then
          git clone $GIT_REPO ~/projects/$PROJECT_NAME || return $?
        else
          cd ~/projects/$PROJECT_NAME || return $?
          git pull &
        fi
      else
        if [ -z $SILENT ]; then
          echo "Using offline mode"
        fi
      fi
      SOURCE_DIRS="$SOURCE_DIRS $HOME/projects/$PROJECT_NAME/$SUBDIR"
      ;;
    *)
      if [ -d $SOURCE ]; then
        SOURCE_DIRS="$SOURCE_DIRS $SOURCE"
      fi
      ;;
  esac
done

wait # for parallel git pull to finish

echo > $HOME/.compiled_shell_aliases.tmp

if [ -z $OFFLINE ]; then
  for SOURCE_DIR in $SOURCE_DIRS
  do
    if [ -d $SOURCE_DIR/.git ]; then
      cd $SOURCE_DIR

      git remote -v | grep fetch | grep origin | grep -q "\.local:"
      if [ $? -eq 0 ]; then
        if [ -z $SILENT ]; then
          echo "Directory '$SOURCE_DIR' contains local git fetch origin, running system git pull ..."
        fi
        PATH="/usr/bin:/bin" /usr/bin/git pull &
      else
        git remote -v | grep fetch | grep -q origin
        if [ $? -eq 0 ]; then
          if [ -z $SILENT ]; then
            echo "Directory '$SOURCE_DIR' contains git fetch origin, running git pull ..."
          fi
          git pull &
        fi
      fi
    fi
  done

  wait # for parallel git pull to finish
fi

UNAME=`uname`

case $UNAME in
  Darwin)
    ;;
  *)
    function md5() {
      md5sum | cut -f 1 -d ' '
    }
    ;;
esac

function compile_directory_contents() {
  local compile_directory_contents_FILE
  if [ -d $1 ]; then
    local compile_directory_contents_SOURCE_DIR_HASH=`echo $1 | md5`
    for compile_directory_contents_FILE in `ls $1/*.sh`
    do
      if [ -z $SILENT ]; then
        echo "Adding file: $compile_directory_contents_FILE"
      fi
      cat "$compile_directory_contents_FILE" | \
        grep -v -E "^\s{0,}#" >> "$HOME/.compiled_shell_aliases.tmp.$compile_directory_contents_SOURCE_DIR_HASH"
    done
  fi
}

for SOURCE_DIR in $SOURCE_DIRS
do
  compile_directory_contents $SOURCE_DIR &
done

wait # for parallel compilation

for SOURCE_DIR in $SOURCE_DIRS
do
  if [ -z $SILENT ]; then
    echo "Merging $SOURCE_DIR ..."
  fi
  SOURCE_DIR_HASH=`echo $SOURCE_DIR | md5`
  case $UNAME in
    Darwin)
      cat $HOME/.compiled_shell_aliases.tmp.$SOURCE_DIR_HASH | \
        grep -v " ##Linux$" | \
        sed -e "s/ ##Darwin$//" >> $HOME/.compiled_shell_aliases.tmp || exit $?
      ;;
    Linux)
      cat $HOME/.compiled_shell_aliases.tmp.$SOURCE_DIR_HASH | \
        grep -v " ##Darwin$" | \
        sed -e "s/ ##Linux$//" >> $HOME/.compiled_shell_aliases.tmp || exit $?
      ;;
  esac
  rm -f $HOME/.compiled_shell_aliases.tmp.$SOURCE_DIR_HASH || exit $?
done

mv $HOME/.compiled_shell_aliases.tmp $HOME/.compiled_shell_aliases.sh
