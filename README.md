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
