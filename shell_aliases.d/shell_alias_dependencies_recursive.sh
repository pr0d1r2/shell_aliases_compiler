function shell_alias_dependencies_recursive() {
  shell_alias_dependencies "$1" | \
    parallel \
      "PROJECTS_PATH=$PROJECTS_PATH && \
       SHELL_ALIASES_COMPILER_ALIASES_PATH=$SHELL_ALIASES_COMPILER_ALIASES_PATH && \
       source $SHELL_ALIASES_COMPILER_ALIASES_PATH/shell_alias_location.sh && \
       source $SHELL_ALIASES_COMPILER_ALIASES_PATH/shell_alias_dependencies.sh && \
       source $SHELL_ALIASES_COMPILER_ALIASES_PATH/shell_alias_dependencies_recursive.sh && \
       echo {} && \
       shell_alias_dependencies_recursive {}"
  return $?
}
