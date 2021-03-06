function shell_alias_dependencies() {
  local shell_alias_dependencies_FILE

  if [ -f "$1" ]; then
    shell_alias_dependencies_FILE=$1
  else
    shell_alias_dependencies_FILE=$(shell_alias_location "$1")
    case $shell_alias_dependencies_FILE in
      "")
        echo "WARNING: No file for: $1" 1>&2
        return 10
        ;;
    esac
  fi

  # shellcheck disable=SC2002
  cat "$shell_alias_dependencies_FILE" | \
    tr '`' ' ' | \
    tr '$' ' ' | \
    tr '/' ' ' | \
    tr -s '[:space:]' '\n' | \
    grep "^[A-Za-z]" | \
    grep "[A-Za-z0-9]$" | \
    grep -v "[^A-Za-z0-9_]" | \
    sort -u | \
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
    grep -v "^HOME$" | \
    grep -v "^shellcheck$" | \
    grep -v "^shell_aliases_compiler$" | \
    grep -v "^source$" | \
    grep -v "^eval$" | \
    grep -v "^is$" | \
    grep -v "^no$" | \
    grep -v "^cat$" | \
    grep -v "^tr$" | \
    grep -v "^file$" | \
    grep -v "^into$" | \
    grep -v "^No$" | \
    grep -v "^$1$" | \
    grep -v "^$1_[A-Z0-9]"
}
