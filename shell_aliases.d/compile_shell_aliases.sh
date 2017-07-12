function compile_shell_aliases() {
  local compile_shell_aliases_OLD_PWD=`pwd -P`
  local compile_shell_aliases_ERROR
  cd $PROJECTS_PATH/shell_aliases_compiler || return $?
  sh setup.sh $@
  compile_shell_aliases_ERROR=$?
  if [ $compile_shell_aliases_ERROR -eq 0 ]; then
    source ~/.compiled_shell_aliases.sh
    compile_shell_aliases_ERROR=$?
  fi
  cd $compile_shell_aliases_OLD_PWD
  return $compile_shell_aliases_ERROR
}
