function embed_shell_alias() {
  local embed_shell_alias_NAME
  local embed_shell_alias_BASE
  for embed_shell_alias_NAME in "$@"
  do
    local embed_shell_alias_FILE="$embed_shell_alias_NAME.sh"
    echo
    echo "Embedding '$embed_shell_alias_NAME' into '$embed_shell_alias_FILE'"
    embed_shell_alias_BASE=$(shell_alias_location "$embed_shell_alias_NAME")
    case $embed_shell_alias_BASE in
      "")
        echo "There is no '$embed_shell_alias_NAME' alias. Aborting!"
        return 10
        ;;
    esac

    echo "Adding:"

    shell_alias_dependencies_recursive "$embed_shell_alias_NAME" | sort -u | \
      parallel \
        "source $SHELL_ALIASES_COMPILER_ALIASES_PATH/shell_alias_location.sh && \
         shell_alias_location {}" | sort -u | \
           parallel "cat {} ; echo {} 1>&2" >> "$embed_shell_alias_FILE"

    echo "$embed_shell_alias_BASE"
    cat "$embed_shell_alias_BASE" >> "$embed_shell_alias_FILE"

    echo "$embed_shell_alias_NAME \$@ || exit \$?" >> "$embed_shell_alias_FILE"
  done
}
