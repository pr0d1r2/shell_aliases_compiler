function shell_alias_dependencies_recursive() {
  local shell_alias_dependencies_recursive_DEP
  for shell_alias_dependencies_recursive_DEP in `shell_alias_dependencies $1`
  do
    echo $shell_alias_dependencies_recursive_DEP
    shell_alias_dependencies_recursive $shell_alias_dependencies_recursive_DEP
  done
}
