#!/bin/bash

D_R=`cd \`dirname $0\` ; pwd -P`
cd $D_R || return $?

case $1 in
  -o | --offline)
    OFFLINE=1
    ;;
esac

if [ -z $OFFLINE ]; then
  git pull || return $?
fi

source $D_R/.config.sh || return $?

for SOURCE in $SOURCES
do
  case $SOURCE in
    git@github.com:?*:?* | git@gitlab.com:?*:?* | https://github.com/*)
      GIT_REPO=`echo $SOURCE | cut -f 1-2 -d :`
      PROJECT_NAME=`echo $SOURCE | cut -f 2 -d / | cut -f 1 -d : | sed -e 's/.git//g'`
      SUBDIR=`echo $SOURCE | cut -f 2 -d / | cut -f 2 -d :`
      echo "Using $GIT_REPO as $HOME/projects/$PROJECT_NAME/$SUBDIR"
      if [ -z $OFFLINE ]; then
        if [ ! -d ~/projects/$PROJECT_NAME ]; then
          git clone $GIT_REPO ~/projects/$PROJECT_NAME || return $?
        else
          cd ~/projects/$PROJECT_NAME || return $?
          git pull &
        fi
      else
        echo "Using offline mode"
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
        echo "Directory '$SOURCE_DIR' contains local git fetch origin, running system git pull ..."
        PATH="/usr/bin:/bin" /usr/bin/git pull &
      else
        git remote -v | grep fetch | grep -q origin
        if [ $? -eq 0 ]; then
          echo "Directory '$SOURCE_DIR' contains git fetch origin, running git pull ..."
          git pull &
        fi
      fi
    fi
  done

  wait # for parallel git pull to finish
fi

case `uname` in
  Darwin)
    MD5="md5"
    ;;
  *)
    MD5="md5sum"
    ;;
esac

function compile_directory_contents() {
  local compile_directory_contents_FILE
  if [ -d $1 ]; then
    local compile_directory_contents_SOURCE_DIR_HASH=`echo $1 | $MD5`
    for compile_directory_contents_FILE in `ls $1/*.sh`
    do
      echo "Adding file: $compile_directory_contents_FILE"
      cat $compile_directory_contents_FILE >> $HOME/.compiled_shell_aliases.tmp.$compile_directory_contents_SOURCE_DIR_HASH
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
  echo "Merging $SOURCE_DIR ..."
  SOURCE_DIR_HASH=`echo $SOURCE_DIR | $MD5`
  cat $HOME/.compiled_shell_aliases.tmp.$SOURCE_DIR_HASH >> $HOME/.compiled_shell_aliases.tmp || exit $?
  rm -f $HOME/.compiled_shell_aliases.tmp.$SOURCE_DIR_HASH || exit $?
done

mv $HOME/.compiled_shell_aliases.tmp $HOME/.compiled_shell_aliases.sh
