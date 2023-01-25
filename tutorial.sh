#!/usr/bin/env bash

# determining emacs config location
[[ -f $HOME/.emacs ]] &&
    emacs_config=$HOME/.emacs ||
    emacs_config=$HOME/.emacs.d/init.el

declare -A config_list=(
    [vim]=$HOME/.vimrc
    [nvim]=$HOME/.config/nvim/init.vim
    [emacs]=$emacs_config
)

for i in "${!config_list[@]}"; do
    echo $i
done

a=vim

echo ${config_list[$a]}
