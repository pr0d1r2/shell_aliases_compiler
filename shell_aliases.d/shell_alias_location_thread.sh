function shell_alias_location_thread() {
  shell_alias_directories | \
    parallel "ls {}/$1.sh" \
      2>/dev/null
}
