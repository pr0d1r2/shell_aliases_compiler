function shell_alias_directories() {
  local shell_alias_directories_ENTRY
  local shell_alias_directories_DELIMITER_FIELD
  local shell_alias_directories_PROJECT_NAME
  local shell_alias_directories_SUBDIR
  for shell_alias_directories_ENTRY in `cat $PROJECTS_PATH/shell_aliases_compiler/.config.sh | grep "^  " | cut -b3-`
  do
    case $shell_alias_directories_ENTRY in
      git@github.com:?*:?* | git@gitlab.com:?*:?* | https://github.com/*)
        case $shell_alias_directories_ENTRY in
          git@github.com:?*:?* | git@gitlab.com:?*:?*)
            shell_alias_directories_DELIMITER_FIELD=2
            ;;
          https://github.com/*)
            shell_alias_directories_DELIMITER_FIELD=5
            ;;
        esac
        shell_alias_directories_PROJECT_NAME=`echo $shell_alias_directories_ENTRY | \
          cut -f $shell_alias_directories_DELIMITER_FIELD -d / | \
          cut -f 1 -d : | \
          sed -e 's/.git//g'`
        shell_alias_directories_SUBDIR=`echo $shell_alias_directories_ENTRY | \
          cut -f $shell_alias_directories_DELIMITER_FIELD -d / | \
          cut -f 2 -d :`
        echo "$PROJECTS_PATH/$shell_alias_directories_PROJECT_NAME/$shell_alias_directories_SUBDIR"
        ;;
      *)
        eval "echo $shell_alias_directories_ENTRY"
        ;;
    esac
  done
}
