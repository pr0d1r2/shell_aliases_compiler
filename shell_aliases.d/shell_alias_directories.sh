function shell_alias_directories() {
  grep "^  " "$PROJECTS_PATH/shell_aliases_compiler/.config.sh" | cut -b3- | \
    parallel \
      "PROJECTS_PATH=$PROJECTS_PATH && \
       source $SHELL_ALIASES_COMPILER_ALIASES_PATH/shell_alias_directories_thread.sh && \
       shell_alias_directories_thread {}"
  return $?
}
