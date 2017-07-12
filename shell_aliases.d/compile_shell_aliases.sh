function compile_shell_aliases() {
  local compile_shell_aliases_OLD_PWD=`pwd -P`
  cd $PROJECTS_PATH/shell_aliases_compiler || return $?
  sh setup.sh $@ || return $?
  source ~/.compiled_shell_aliases.sh
  cd $compile_shell_aliases_OLD_PWD
}
