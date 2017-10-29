function shell_alias_location() {
  parallel \
    "PROJECTS_PATH=$PROJECTS_PATH && \
     SHELL_ALIASES_COMPILER_ALIASES_PATH=$SHELL_ALIASES_COMPILER_ALIASES_PATH && \
     source $SHELL_ALIASES_COMPILER_ALIASES_PATH/shell_alias_location_thread.sh && \
     source $SHELL_ALIASES_COMPILER_ALIASES_PATH/shell_alias_directories.sh && \
     shell_alias_location_thread {}" \
    ::: \
    "$@"
  return $?
}
