# shell_aliases_compiler
Easily compile your shell aliases to load single file on shell initialisation

## installing

### run commands

```
mkdir ~/projects
mkdir ~/projects/local_shell_aliases
git clone git@github.com:pr0d1r2/shell_aliases_compiler.git \
  ~/projects/shell_aliases_compiler
cd ~/projects/shell_aliases_compiler
cp .config.sh.example .config.sh # you probably will need to adjust it
sh setup.sh
```

### Add `source $HOME/.compiled_shell_aliases.sh` to your profile:

#### When you have `zsh`:

```
echo "source $HOME/.compiled_shell_aliases.sh" >> ~/.zshrc```
```

#### When you have `bash`:

```
echo "source $HOME/.compiled_shell_aliases.sh" >> ~/.bash_profile```
```

## updating

Just run:

```
compile_shell_aliases
```

### updating when offline

Or when you do not want to make external requests:

```
compile_shell_aliases -o
```

## embedding

If you want to give someone complete solution made out-of-your script
atoms in form of single shell script you need to embed it:

```
embed_shell_alias my_fancy_shell_alias_with_multiple_dependencies
```

Note that this can time time consuming for aliases with lots of
dependencies.

Be careful, as some of your aliases can contain sensitive data like API
credentials - always review compilation result.
