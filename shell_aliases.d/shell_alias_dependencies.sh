function shell_alias_dependencies() {
  if [ -f $1 ]; then
    shell_alias_dependencies_FILE=$1
  else
    local shell_alias_dependencies_FILE=`shell_alias_location $1`
    case $shell_alias_dependencies_FILE in
      "")
        return 10
        ;;
    esac
  fi

  cat $shell_alias_dependencies_FILE | \
    tr '`' ' ' | \
    tr '$' ' ' | \
    tr '/' ' ' | \
    tr -s '[[:space:]]' '\n' | \
    grep "^[A-Za-z]" | \
    grep "[A-Za-z0-9]$" | \
    grep -v "[^A-Za-z0-9_]" | \
    sort | \
    uniq | \
    grep -v "^local$" | \
    grep -v "^done$" | \
    grep -v "^echo$" | \
    grep -v "^open$" | \
    grep -v "^else$" | \
    grep -v "^then$" | \
    grep -v "^uniq$" | \
    grep -v "^sort$" | \
    grep -v "^grep$" | \
    grep -v "^sed$" | \
    grep -v "^parallel$" | \
    grep -v "^fi$" | \
    grep -v "^if$" | \
    grep -v "^exit$" | \
    grep -v "^git$" | \
    grep -v "^do$" | \
    grep -v "^in$" | \
    grep -v "^for$" | \
    grep -v "^esac$" | \
    grep -v "^cd$" | \
    grep -v "^function$" | \
    grep -v "^diff$" | \
    grep -v "^case$" | \
    grep -v "^return$" | \
    grep -v "^checkout$" | \
    grep -v "^fetch$" | \
    grep -v "^pull$" | \
    grep -v "^cut$" | \
    grep -v "^curl$" | \
    grep -v "^wc$" | \
    grep -v "^while$" | \
    grep -v "^expr$" | \
    grep -v "^$1$" | \
    grep -v "^$1_[A-Z0-9]"
}
