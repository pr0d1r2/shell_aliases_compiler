#!/bin/bash

D_R=$(cd "$(dirname "$0")" || exit 1 ; pwd -P)
cd "$D_R" || return $?

for PARAM in "$@"
do
  case $PARAM in
    -o | --offline)
      OFFLINE=1
      ;;
    -c | --consistency-check)
      CONSISTENCY_CHECK=1
      ;;
    -C | --shell-check)
      SHELL_CHECK=1
      ;;
    -s | --silent)
      SILENT=1
      ;;
  esac
done

function cache_cleanup() {
  if [ -z $SILENT ]; then
    echo "Cleaning up cache files..."
  fi
  rm -f $HOME/.compiled_shell_aliases.tmp.* || true
}

# Functions
for SOURCE in $(find "$D_R/setup.d" -maxdepth 1 -name '*.sh')
do
  source "$SOURCE"
done

cache_cleanup

if [ -z $OFFLINE ]; then
  when_online true && git pull || return $?
fi

if [ ! -e "$D_R/.config.sh" ]; then
  echo "shell_aliases_compiler: $D_R/.config.sh does not exist. Using example configuration ..."
  cp "$D_R/.config.sh.example" "$D_R/.config.sh" || return $?
fi
# shellcheck disable=SC1090
source "$D_R/.config.sh" || return $?

# shellcheck disable=SC2153
for SOURCE in $SOURCES
do
  case $SOURCE in
    git@github.com:?* | git@gitlab.com:?* | https://github.com/?*)
      GIT_REPO=$(echo "$SOURCE" | cut -f 1-2 -d :)
      case $SOURCE in
        git@github.com:?*:?* | git@gitlab.com:?*:?*)
          DELIMITER_FIELD=2
          ;;
        https://github.com/*)
          DELIMITER_FIELD=5
          ;;
      esac
      PROJECT_NAME=$(echo "$SOURCE" | cut -f $DELIMITER_FIELD -d / | cut -f 1 -d : | sed -e 's/.git//g')
      case $SOURCE in
        git@github.com:?*:?* | git@gitlab.com:?*:?* | https://github.com/?*:?*)
          SUBDIR=$(echo "$SOURCE" | cut -f $DELIMITER_FIELD -d / | cut -f 2 -d :)
          if [ -z $SILENT ]; then
            echo "Using $GIT_REPO as $HOME/projects/$PROJECT_NAME/$SUBDIR"
          fi
          SOURCE_DIRS="$SOURCE_DIRS $HOME/projects/$PROJECT_NAME/$SUBDIR"
          ;;
      esac
      if [ -z $OFFLINE ]; then
        when_online true
        if [ ! -d "$HOME/projects/$PROJECT_NAME" ]; then
          git clone "$GIT_REPO" "$HOME/projects/$PROJECT_NAME" || return $?
        else
          cd "$HOME/projects/$PROJECT_NAME" || return $?
          git pull &
        fi
      else
        if [ -z $SILENT ]; then
          echo "Using offline mode"
        fi
      fi
      if [ -f "$HOME/projects/$PROJECT_NAME/.ruby-version" ]; then
        RUBY_VERSIONS="$RUBY_VERSIONS $(cat "$HOME/projects/$PROJECT_NAME/.ruby-version")"
      fi
      ;;
    *)
      if [ -d "$SOURCE" ]; then
        SOURCE_DIRS="$SOURCE_DIRS $SOURCE"
      elif [ -f "$SOURCE" ]; then
        SOURCE_FILES="$SOURCE_FILES $SOURCE"
      fi
      ;;
  esac
done

if [ -z $OFFLINE ]; then
  RUBY_VERSIONS=$(echo $RUBY_VERSIONS | tr ' ' "\n" | sort -u)
  for RUBY_VERSION in $RUBY_VERSIONS
  do
    if [ ! -d "$HOME/.rbenv/versions/$RUBY_VERSION" ]; then
      when_online true
      rbenv install $RUBY_VERSION &
    fi
  done
  wait # for parallel git pull (and ruby install) to finish

  for RUBY_VERSION in $RUBY_VERSIONS
  do
    when_online true
    "$HOME/.rbenv/versions/$RUBY_VERSION/bin/gem" install bundler --no-document &
  done
  wait # for parallel install of bundler
fi


# shellcheck disable=SC2153
for PRE_SETUP_TRIGGER in $PRE_SETUP_TRIGGERS
do
  if [ -z $SILENT ]; then
    echo "Running pre-setup trigger: $PRE_SETUP_TRIGGER ..."
  fi
  case $PRE_SETUP_TRIGGER in
    *.sh)
      if [ -z $SILENT ]; then
        bash "$PRE_SETUP_TRIGGER" || exit $?
      else
        bash "$PRE_SETUP_TRIGGER" &>/dev/null || exit $?
      fi
      ;;
    *.rb)
      if [ -z $SILENT ]; then
        ruby "$PRE_SETUP_TRIGGER" || exit $?
      else
        ruby "$PRE_SETUP_TRIGGER" &>/dev/null || exit $?
      fi
      ;;
  esac
done

echo > "$HOME/.compiled_shell_aliases.tmp"

if [ -z $OFFLINE ]; then
  for SOURCE_DIR in $SOURCE_DIRS
  do
    if [ -d "$SOURCE_DIR/.git" ]; then
      cd "$SOURCE_DIR" || exit $?

      if (git remote -v | grep fetch | grep origin | grep -q "\.local:"); then
        if [ -z $SILENT ]; then
          echo "Directory '$SOURCE_DIR' contains local git fetch origin, running system git pull ..."
        fi
        PATH="/usr/bin:/bin" /usr/bin/git pull &
      else
        if (git remote -v | grep fetch | grep -q origin); then
          if [ -z $SILENT ]; then
            echo "Directory '$SOURCE_DIR' contains git fetch origin, running git pull ..."
          fi
          when_online true && git pull &
        fi
      fi
    fi
  done

  wait # for parallel git pull to finish
fi

UNAME=$(uname)

case $UNAME in
  Darwin)
    # shellcheck disable=SC2120
    function tac() {
      tail -r "$@"
    }
    ;;
  *)
    function md5() {
      md5sum | cut -f 1 -d ' '
    }
    ;;
esac

function consistency_check() {
  if [ -n "$CONSISTENCY_CHECK" ]; then
    local consistency_check_ERR
    source "$1"
    if [ $? -gt 0 ]; then
      echo "ERROR Adding file: $2"
      return 1
    fi
  fi
}

function compile_directory_contents() {
  local compile_directory_contents_FILE
  if [ -d "$1" ]; then
    local compile_directory_contents_SOURCE_DIR_HASH
    compile_directory_contents_SOURCE_DIR_HASH=$(echo "$1" | md5)
    # shellcheck disable=SC2010,SC2045,SC2086
    for compile_directory_contents_FILE in $(ls $1/[a-z]*.sh)
    do
      if [ -z "$SILENT" ]; then
        echo "Adding file: $compile_directory_contents_FILE"
      fi
      grep -v -E "^\s{0,}#" "$compile_directory_contents_FILE" \
        >> "$HOME/.compiled_shell_aliases.tmp.$compile_directory_contents_SOURCE_DIR_HASH"
      consistency_check "$HOME/.compiled_shell_aliases.tmp.$compile_directory_contents_SOURCE_DIR_HASH" "$compile_directory_contents_FILE" || exit $?
    done
    compile_directory_contents_SOURCE_DIR_HASH=$(echo "$1-constants" | md5)
    # shellcheck disable=SC2010,SC2045,SC2086
    for compile_directory_contents_FILE in $(ls $1/[A-Z]*.sh 2>/dev/null)
    do
      if [ -z $SILENT ]; then
        echo "Adding file: $compile_directory_contents_FILE"
      fi
      grep -v -E "^\s{0,}#" "$compile_directory_contents_FILE" \
        >> "$HOME/.compiled_shell_aliases.tmp.$compile_directory_contents_SOURCE_DIR_HASH"
      consistency_check "$HOME/.compiled_shell_aliases.tmp.$compile_directory_contents_SOURCE_DIR_HASH" "$compile_directory_contents_FILE" || exit $?
    done
  fi
}

if [ -n "$SHELL_CHECK" ]; then
  parallel "find {} -type f -name '*.sh'" ::: $SOURCE_DIRS | \
    parallel --halt-on-error now,fail=1 "shellcheck -e SC2148 {}" || exit $?
fi

for SOURCE_DIR in $SOURCE_DIRS
do
  if [ -n "$CONSISTENCY_CHECK" ]; then
    compile_directory_contents "$SOURCE_DIR" || exit $?
  else
    compile_directory_contents "$SOURCE_DIR" &
  fi
done

if [ -z "$CONSISTENCY_CHECK" ]; then
  wait # for parallel compilation
fi

for SOURCE_DIR in $SOURCE_DIRS
do
  if [ -z $SILENT ]; then
    echo "Merging $SOURCE_DIR ..."
  fi
  SOURCE_DIR_HASH=$(echo "$SOURCE_DIR" | md5)
  case $UNAME in
    Darwin)
      grep -v " ##Linux$" "$HOME/.compiled_shell_aliases.tmp.$SOURCE_DIR_HASH" | \
        sed -e "s/ ##Darwin$//" >> "$HOME/.compiled_shell_aliases.tmp" || exit $?
      ;;
    Linux)
      grep -v " ##Darwin$" "$HOME/.compiled_shell_aliases.tmp.$SOURCE_DIR_HASH" | \
        sed -e "s/ ##Linux$//" >> "$HOME/.compiled_shell_aliases.tmp" || exit $?
      ;;
  esac
  rm -f "$HOME/.compiled_shell_aliases.tmp.$SOURCE_DIR_HASH" || exit $?
done

for SOURCE_FILE in $SOURCE_FILES
do
  if [ -z $SILENT ]; then
    echo "Adding $SOURCE_FILE ..."
  fi
  cat "$SOURCE_FILE" >> "$HOME/.compiled_shell_aliases.tmp"
done

for SOURCE_DIR in $SOURCE_DIRS
do
  if [ -z $SILENT ]; then
    echo "Merging $SOURCE_DIR (constants) ..."
  fi
  SOURCE_DIR_HASH=$(echo "$SOURCE_DIR-constants" | md5)
  if [ -f "$HOME/.compiled_shell_aliases.tmp.$SOURCE_DIR_HASH" ]; then
    case $UNAME in
      Darwin)
        grep -v " ##Linux$" "$HOME/.compiled_shell_aliases.tmp.$SOURCE_DIR_HASH" | \
          sed -e "s/ ##Darwin$//" >> "$HOME/.compiled_shell_aliases.tmp" || exit $?
        ;;
      Linux)
        grep -v " ##Darwin$" "$HOME/.compiled_shell_aliases.tmp.$SOURCE_DIR_HASH" | \
          sed -e "s/ ##Linux$//" >> "$HOME/.compiled_shell_aliases.tmp" || exit $?
        ;;
    esac
    rm -f "$HOME/.compiled_shell_aliases.tmp.$SOURCE_DIR_HASH" || exit $?
  fi
done

mv "$HOME/.compiled_shell_aliases.tmp" "$HOME/.compiled_shell_aliases.sh"

cache_cleanup
