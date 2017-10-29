function embed_shell_alias_thread() {
  local embed_shell_alias_thread_BASE
  local embed_shell_alias_thread_FILE="$1.sh"
  echo
  echo "Embedding '$1' into '$embed_shell_alias_thread_FILE'"
  embed_shell_alias_thread_BASE=$(shell_alias_location "$1")
  case $embed_shell_alias_thread_BASE in
    "")
      echo "There is no '$1' alias. Aborting!"
      return 10
      ;;
  esac

  echo "Adding:"

  shell_alias_dependencies_recursive "$1" | sort -u | \
    parallel \
      "PROJECTS_PATH=$PROJECTS_PATH && \
       SHELL_ALIASES_COMPILER_ALIASES_PATH=$SHELL_ALIASES_COMPILER_ALIASES_PATH && \
       source $SHELL_ALIASES_COMPILER_ALIASES_PATH/shell_alias_location.sh && \
       shell_alias_location {}" | sort -u | \
         parallel "cat {} ; echo {} 1>&2" >> "$embed_shell_alias_thread_FILE"

  echo "$embed_shell_alias_thread_BASE"
  cat "$embed_shell_alias_thread_BASE" >> "$embed_shell_alias_thread_FILE"

  echo "$1 \$@ || exit \$?" >> "$embed_shell_alias_thread_FILE"
}
