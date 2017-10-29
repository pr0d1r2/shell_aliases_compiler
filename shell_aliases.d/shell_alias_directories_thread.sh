function shell_alias_directories_thread() {
  local shell_alias_directories_thread_DELIMITER_FIELD
  local shell_alias_directories_thread_PROJECT_NAME
  local shell_alias_directories_thread_SUBDIR
  case $1 in
    git@github.com:?*:?* | git@gitlab.com:?*:?* | https://github.com/*)
      case $1 in
        git@github.com:?*:?* | git@gitlab.com:?*:?*)
          shell_alias_directories_thread_DELIMITER_FIELD=2
          ;;
        https://github.com/*)
          shell_alias_directories_thread_DELIMITER_FIELD=5
          ;;
      esac
      shell_alias_directories_thread_PROJECT_NAME=$(
        echo "$1" | \
        cut -f $shell_alias_directories_thread_DELIMITER_FIELD -d / | \
        cut -f 1 -d : | \
        sed -e 's/.git//g'
      )
      shell_alias_directories_thread_SUBDIR=$(
        echo "$1" | \
        cut -f $shell_alias_directories_thread_DELIMITER_FIELD -d / | \
        cut -f 2 -d :
      )
      echo "$PROJECTS_PATH/$shell_alias_directories_thread_PROJECT_NAME/$shell_alias_directories_thread_SUBDIR"
      ;;
    *)
      eval "echo $1"
      ;;
  esac
}
