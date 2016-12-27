#!/bin/bash

case $1 in
  -o | --offline)
    OFFLINE=1
    ;;
esac

cd $HOME/projects/shell_aliases_compiler || return $?
git pull || return $?

for SOURCE in \
  git@github.com:pr0d1r2/plexus.git:bash_profile.d \
  git@github.com:pr0d1r2/osx_crond.git:shell_aliases.d \
  git@github.com:pr0d1r2/ruby_dev_shell_aliases.git:. \
  git@github.com:pr0d1r2/git_shell_aliases.git:. \
  git@github.com:pr0d1r2/osx_shell_aliases.git:. \
  git@gitlab.com:doubledrones/dt_shell_aliases.git:. \
  git@gitlab.com:pr0d1r2/tt_shell_aliases.git:. \
  $HOME/projects/local_shell_aliases \
  $HOME/projects/shell_aliases_compiler/shell_aliases.d \

do
  case $SOURCE in
    git@github.com:?*:?* | git@gitlab.com:?*:?*)
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

for SOURCE_DIR in $SOURCE_DIRS
do
  if [ -d $SOURCE_DIR ]; then
    for FILE in `ls $SOURCE_DIR/*.sh`
    do
      echo "Adding file: $FILE"
      cat $FILE >> $HOME/.compiled_shell_aliases.tmp
    done
  fi
done

mv $HOME/.compiled_shell_aliases.tmp $HOME/.compiled_shell_aliases.sh
