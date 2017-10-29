function shell_alias_dependencies_recursive() {
  shell_alias_dependencies "$1" || \
    parallel \
      "echo {} && \
       source $SHELL_ALIASES_COMPILER_ALIASES_PATH/shell_alias_dependencies.sh && \
       source $SHELL_ALIASES_COMPILER_ALIASES_PATH/shell_alias_dependencies_recursive.sh && \
       shell_alias_dependencies_recursive {}"
  return $?
}
