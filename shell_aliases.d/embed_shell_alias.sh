function embed_shell_alias() {
  parallel \
    "PROJECTS_PATH=$PROJECTS_PATH && \
     SHELL_ALIASES_COMPILER_ALIASES_PATH=$SHELL_ALIASES_COMPILER_ALIASES_PATH && \
     source $SHELL_ALIASES_COMPILER_ALIASES_PATH/embed_shell_alias_thread.sh && \
     source $SHELL_ALIASES_COMPILER_ALIASES_PATH/shell_alias_location.sh && \
     source $SHELL_ALIASES_COMPILER_ALIASES_PATH/shell_alias_dependencies.sh && \
     source $SHELL_ALIASES_COMPILER_ALIASES_PATH/shell_alias_dependencies_recursive.sh && \
     embed_shell_alias_thread {}" \
    ::: \
    "$@"
}
