#!/bin/bash

cd $HOME/projects/shell_aliases_compiler || return $?
git pull || return $?

for SOURCE in \
  git@github.com:pr0d1r2/plexus.git:bash_profile.d \
  $HOME/projects/local_shell_aliases \
  $HOME/projects/shell_aliases_compiler/shell_aliases.d \

do
  case $SOURCE in
    git@github.com:?*:?*)
      GIT_REPO=`echo $SOURCE | cut -f 1-2 -d :`
      PROJECT_NAME=`echo $SOURCE | cut -f 2 -d / | cut -f 1 -d : | sed -e 's/.git//g'`
      SUBDIR=`echo $SOURCE | cut -f 2 -d / | cut -f 2 -d :`
      echo "Using $GIT_REPO as $HOME/projects/$PROJECT_NAME/$SUBDIR"
      if [ ! -d ~/projects/$PROJECT_NAME ]; then
        git clone $GIT_REPO ~/projects/$PROJECT_NAME || return $?
      else
        cd ~/projects/$PROJECT_NAME || return $?
        git pull
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

echo > $HOME/.compiled_shell_aliases.tmp

for SOURCE_DIR in $SOURCE_DIRS
do
  if [ -d $SOURCE_DIR/.git ]; then
    cd $SOURCE_DIR
    git remote -v | grep fetch | grep -q origin
    if [ $? -eq 0 ]; then
      echo "Directory '$SOURCE_DIR' contains git fetch origin, running git pull ..."
      git pull
    fi
  fi
  if [ -d $SOURCE_DIR ]; then
    for FILE in `ls $SOURCE_DIR/*.sh`
    do
      echo "Adding file: $FILE"
      cat $FILE >> $HOME/.compiled_shell_aliases.tmp
    done
  fi
done

mv $HOME/.compiled_shell_aliases.tmp $HOME/.compiled_shell_aliases.sh
