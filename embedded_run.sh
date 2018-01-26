#!/usr/bin/env zsh

if [ ! -e "$HOME/.compiled_shell_aliases.sh" ]; then
  D_R=$(cd $(dirname $0) ; pwd -P)
  $D_R/setup.sh || exit $?
fi

source "$HOME/.compiled_shell_aliases.sh" || exit $?

$@ || exit $?
