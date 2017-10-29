function shell_alias_location_thread() {
  shell_alias_directories | \
    parallel "test -f {}/$1.sh && echo {}/$1.sh"
}
