#!/usr/bin/env bash

#---------- CONSTANTS --------------
RETURN_SUCCESS=0
RETURN_FAILED=1
#-----------------------------------

# define default text editor
if [[ -z $EDITOR ]]
then
    EDITOR=nvim
fi

# define xdg config home environment variable
if [[ -z $XDG_CONFIG_HOME ]]; then
    XDG_CONFIG_HOME=$HOME/.config
fi

#---------------- Specific Function Definition ---------------
function exists_in_list()
{
    local needle=$1
    local haystack=("$@")
    local len=$#
    for ((i = 1; i < len; i++)); do
        if [ $needle = ${haystack[$i]} ]; then
            return $RETURN_SUCCESS
        fi
    done

    return $RETURN_FAILED
}

function open_config_vim()
{
    $EDITOR $HOME/.vimrc
}

# using vimscript by default
# TODO: use getopt to set option to use lua config instead of vimscript
function open_config_neovim()
{

    if [[ ! -d $XDG_CONFIG_HOME/nvim ]]; then
        mkdir $XDG_CONFIG_HOME/nvim
        touch $XDG_CONFIG_HOME/nvim/init.vim
    fi
    $EDITOR $XDG_CONFIG_HOME/nvim/init.vim
}

# the default emacs config is in $HOME/.emacs.d/init.el unless $HOME/.emacs file already exists
function open_config_emacs()
{
    if [[ -f $HOME/.emacs ]]; then
        $EDITOR $HOME/.emacs
    elif [[ -f $HOME/.emacs.d/init.el ]]; then
        $EDITOR $HOME/.emacs.d/init.el
    else
        mkdir $HOME/.emacs.d
        touch $HOME/.emacs.d/init.el
        $EDITOR $HOME/.emacs.d/init.el
    fi
}

function confirm_remove_config()
{
    local conf_loc=$1

    echo "Are you sure you want to delete $conf_loc? [y/n]"
    while true; do
        echo -n "> "
        read confirm
        if [[ $confirm = "n" ]]; then
            echo "Operation aborted"
            return $RETURN_SUCCESS
        elif [[ $confirm = "y" ]]; then
            echo "Removing config file: $conf_loc"
            rm -rv $conf_loc
            return $RETURN_SUCCESS
        else
            echo "Please type y or n"
        fi
    done
}

function remove_config_vim()
{
    if [[ ! -f $HOME/.vimrc ]]; then
        echo "You don't have vim config file." >&2
        return $RETURN_FAILED
    fi

    confirm_remove_config "$HOME/.vimrc"
}

function remove_config_neovim()
{
    if [[ ! -f $XDG_CONFIG_HOME/nvim/init.vim ]]; then
        echo "You don't have neovim config file." >&2
        return $RETURN_FAILED
    fi

    confirm_remove_config "$XDG_CONFIG_HOME/nvim"
}

function remove_config_emacs()
{
    if [[ ! -f $HOME/.emacs || ! -f $HOME/.emacs.d/init.el ]]; then
        echo "You don't have emacs config file." >&2
        return $RETURN_FAILED
    fi

    if [[ -f $HOME/.emacs ]]; then
        confirm_remove_config "$HOME/.emacs"
    elif [[ -f $HOME/.emacs.d/init.el ]]; then
        confirm_remove_config "$HOME/.emacs.d"
    fi

}

#----------------------------------------------------


#-------------- General Function Definition --------------
function open_config()
{
    local config_file=$1
    if ! exists_in_list $config_file "${config_file_list[@]}"; then
        echo "Configuration file '$config_file' doesn't exist." >&2
        return $RETURN_FAILED
    fi

    case $config_file in
        vim)
            open_config_vim
            ;;
        nvim | neovim)
            open_config_neovim
            ;;
        emacs)
            open_config_emacs
            ;;
    esac

    return $RETURN_SUCCESS
}

function remove_config()
{
    local config_file=$1

    case $config_file in
        vim)
            remove_config_vim
            ;;
        nvim | neovim)
            remove_config_neovim
            ;;
        emacs)
            remove_config_emacs
            ;;
    esac
}

#---------------------------------------------------------

# TODO copy config
# TODO connect to remote
# TODO add more config
