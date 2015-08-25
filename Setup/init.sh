#!/bin/bash

# Tilde doesn't need to expand here because it will be done when exec asks
LINK_SCRIPT="${HOME}/sysconfig/Setup/links.sh"

for TOOL in "cat" "cp" "ln" "rm" "touch"
do
	if which "$TOOL" > /dev/null
	then
		true
	else
		cat <<-EOS
[XX] ERROR: Cannot find "${TOOL}" on system.
		EOS
		exit
	fi
done

function help_general()
{
	cat <<-EOS
These scripts serve to add some level of management to the Unix tradition of
configuration "dotfiles" -- files in the home directory typically starting with
a period to hide them from plain 'ls' that customize user programs -- and allow
rapid redeployment of a user's environment to new machines. This project cannot
declutter the home directory, as the programs using these files have the paths
hardwired into their source code. Rather, the dotfiles will be backed up and
replaced with symlinks into this folder, which is under version control.
	EOS
}

function help_args()
{
	cat <<-EOS
This script takes two arguments.
1. One of two ACTIONS
  link:   place symlinks from traditional dotfiles to sysconfig files
  unlink: remove symlinks and restore any dotfiles that existed before `link`
2. The CONFIG set to target
  ssh:  Manipulate the sysconfig SSH collection. Provides helper functions.
  tmux: Manipulate the sysconfig tmux collection. Provides helper functions.
  zsh:  Manipulate the sysconfig zsh collection.

A config set that provides helper functions stores them in $CONFIG/misc.sh and
your shell's rc file will be given a source directive to activate them. This
directive will be removed by the `unlink` action.
	EOS
}

case "$1" in
	help)
		help_general
	;;
	link)
		if [ -z "$2" ]
		then
			exec "${LINK_SCRIPT}" LINK_ALL
		else
			case "$2" in
				ssh)
					exec "${LINK_SCRIPT}" LINK_SSH
				;;
				tmux)
					exec "${LINK_SCRIPT}" LINK_TMUX
				;;
				zsh)
					exec "${LINK_SCRIPT}" LINK_ZSH
				;;
			esac
		fi
	;;
	unlink)
		if [ -z "$2" ]
		then
			exec "${LINK_SCRIPT}" UNLINK_ALL
		else
			case "$2" in
				ssh)
					exec "${LINK_SCRIPT}" UNLINK_SSH
				;;
				tmux)
					exec "${LINK_SCRIPT}" UNLINK_TMUX
				;;
				zsh)
					exec "${LINK_SCRIPT}" UNLINK_ZSH
				;;
			esac
		fi
	;;
	*)
		help_args
	;;
esac

unset LINK_SCRIPT
