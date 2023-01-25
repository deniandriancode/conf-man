#---------- CONSTANTS --------------
RETURN_SUCCESS=0
RETURN_FAILED=1
PROGNAME="confman"
VERSION="0.1.0"
#-----------------------------------

# define default text editor
if [[ -z $EDITOR ]]; then
    EDITOR=vim
fi

# define xdg config home environment variable
if [[ -z $XDG_CONFIG_HOME ]]; then
    XDG_CONFIG_HOME=$HOME/.config
fi

# Define config file location
conf_loc_vim=''
conf_loc_neovim=''
conf_loc_emacs=''

# Declare config file locations
conf_loc_vim=$HOME/.vimrc                              #-- vim
[[ -f $XDG_CONFIG_HOME/nvim/init.vim ]] &&             #-- neovim
    conf_loc_neovim=$XDG_CONFIG_HOME/nvim/init.vim ||
    conf_loc_neovim=$XDG_CONFIG_HOME/nvim/init.lua
[[ -f $HOME/.emacs ]] &&                               #-- emacs
    conf_loc_emacs=$HOME/.emacs ||
    conf_loc_emacs=$HOME/.emacs.d/init.el

#----------- Config File and Global Variable Defintion -----------
declare -A config_file_list=(
    [vim]=$conf_loc_vim
    [nvim]=$conf_loc_neovim
    [neovim]=$conf_loc_neovim
    [emacs]=$conf_loc_emacs
    [dummy]=$HOME/.dummyrc # debug only
)
default_config_file=$HOME/.bashrc
#-----------------------------------------------------------------

#---------------- Util Functions Definition ---------------

# exists_in_list $needle $haystack
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

# confirm_delete_config $config_file
function confirm_delete_config()
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

#----------------------------------------------------


#-------------- Function Operation Definition --------------

# open_config $config_file
function open_config()
{
    local config_file=$1
    if [[ -n $config_file ]] && ! exists_in_list $config_file "${!config_file_list[@]}"; then
        echo "Configuration file for '$config_file' doesn't exist." >&2
        return $RETURN_FAILED
    fi

    if [[ -z $config_file ]]; then
        $EDITOR $default_config_file
        return $RETURN_SUCCESS
    fi

    $EDITOR ${config_file_list[$config_file]}

    return $RETURN_SUCCESS
}

# delete_config $config_file
function delete_config()
{
    local config_file=$1

    if [[ -z $config_file ]]; then
        echo "Please enter config file you want to delete." >&2
        return $RETURN_FAILED
    fi

    if [[ ! -f ${config_file_list[$config_file]} ]] || ! exists_in_list $config_file "${!config_file_list[@]}"; then
        echo "You don't have '$config_file' config file" >&2
        return $RETURN_FAILED
    fi

    confirm_delete_config ${config_file_list[$config_file]}

    return $RETURN_SUCCESS
}

# backup_config $config_file
function backup_config()
{
    local config_file=$1

    if [[ -z config_file ]]; then
        echo "Please enter config file you want to backup." >&2
        return $RETURN_FAILED
    fi

    if [[ ! -f ${config_file_list[$config_file]} ]] || ! exists_in_list $config_file "${!config_file_list[@]}"; then
        echo "You don't have '$config_file' config file" >&2
        return $RETURN_FAILED
    fi

    cp -rv ${config_file_list[$config_file]} ${config_file_list[$config_file]}.bak

    return $RETURN_SUCCESS
}

# copy_config $config_file_src $config_file_dest
function copy_config()
{
    local config_file_src=$1
    local config_file_dest=$2

    if [[ -z config_file_src ]]; then
        echo "Please enter config file you want to copy." >&2
        return $RETURN_FAILED
    fi

    if [[ -z config_file_dest ]]; then
        echo "Please enter destination file." >&2
        return $RETURN_FAILED
    fi

    if [[ ! -f ${config_file_list[$config_file_src]} ]] || ! exists_in_list $config_file_src "${!config_file_list[@]}"; then
        echo "You don't have '$config_file' config file" >&2
        return $RETURN_FAILED
    fi

    cp -rv ${config_file_list[$config_file_src]} ${config_file_dest}

    return $RETURN_SUCCESS
}

function version_info()
{
    echo "$PROGNAME v$VERSION"

    return $RETURN_SUCCESS
}

#---------------------------------------------------------


#---------------- Help Function --------------------------
function help_prompt()
{
    echo "Usage: $(basename $PROGNAME) [options] file"
    echo "Options:"
    echo "      -o    open config"
    echo "      -d    delete config"
    echo "      -b    backup config"
    echo "      -h -? show this message"
    echo "      -V    print software version"

    return $RETURN_SUCCESS
}
#---------------------------------------------------------

#---------------------------------------------------------
# TODO copy config
# TODO connect to remote
# TODO add more config
