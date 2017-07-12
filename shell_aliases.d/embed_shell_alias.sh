function embed_shell_alias() {
  local embed_shell_alias_NAME
  local embed_shell_alias_ATOM_LOCATION
  for embed_shell_alias_NAME in $@
  do
    local embed_shell_alias_FILE="$embed_shell_alias_NAME.sh"
    echo
    echo "Embedding '$embed_shell_alias_NAME' into '$embed_shell_alias_FILE'"
    embed_shell_alias_ATOM_LOCATION=`shell_alias_location $embed_shell_alias_NAME`
    case $embed_shell_alias_ATOM_LOCATION in
      "")
        echo "There is no '$embed_shell_alias_NAME' alias. Aborting!"
        return 10
        ;;
    esac

    echo "Adding:"

    for embed_shell_alias_ATOM_LOCATION in `shell_alias_location \`shell_alias_dependencies_recursive $embed_shell_alias_NAME | sort | uniq\` | sort | uniq`
    do
      echo $embed_shell_alias_ATOM_LOCATION
      cat $embed_shell_alias_ATOM_LOCATION >> $embed_shell_alias_FILE
    done

    echo $embed_shell_alias_ATOM_LOCATION
    cat $embed_shell_alias_ATOM_LOCATION >> $embed_shell_alias_FILE

    echo "$embed_shell_alias_NAME \$@ || exit \$?" >> $embed_shell_alias_FILE
  done
}
