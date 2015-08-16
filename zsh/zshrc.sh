#!/bin/zsh

# zshrc files (system and user) are read for all interactive zsh instances.
# zshrc comes after zshenv and zprofile, and before zlogin and zlogout, in the
# load order

# Let's mess with the PATH! (See zshenv.sh)
typeset -U path
path=(~/bin ~/node_modules/.bin $path .)

# Get colorful output
autoload -U colors && colors

# Get a nifty prompt
# zsh apparently doesn't like using \n to indicate linebreaks, and is okay with
# ACTUAL LINEBREAKS in a string
# user@hostname directory (linebreak) lambda
PROMPT="%F{green}%n%f@%F{green}%m%f %F{blue}%~%f
%F{green}λ%f "
# Indicate success/failure of previous command in the right prompt
RPROMPT="%(?.%F{yellow}:)%f.%F{red}:(%f)"

# Load the tmux shell configuration
source ${HOME}/sysconfig/tmux/misc.sh

function vscode()
{
	[ $(uname) = "Darwin" ] && \
	VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;
}
