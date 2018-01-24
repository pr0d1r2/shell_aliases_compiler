function rg_shell_aliases() {
  shell_alias_directories | parallel "rg '$*' {}"
}
