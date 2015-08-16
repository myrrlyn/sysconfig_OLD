#!/bin/bash

##
# Handles linking and unlinking of dotfiles
##

# Checks if a given file exists and is not a symlink
# -f checks for existence
# -h checks if it is a link
# -s checks if it has contents
# If the file is already a symlink, then we do not care about backing up the
# target. That's on the user.
function test_file()
{
	   [ -f "$1" ] \
	&& [ -s "$1" ] \
	&& [ ! -h "$1" ]
}

function test_link()
{
	[ -h "$1" ]
}

# Echo an error message if a file cannot be deleted
function delete_file()
{
	rm -f "$1" || echo "[>>] ERROR: Cannot delete file $1"
}

# Back up a dotfile and create a symlink to the appropriate sysconfig file.
# Call with dotfile first and sysconfig file second. Dotfile assumes it is in ~
# and sysconfig file assumes it is in ~/sysconfig
function file_link()
{
	# Check if a dotfile already exists and if so, back it up
	if test_file "${HOME}/$1"
	then
		touch "${HOME}/sysconfig/Backup/$(basename $1)"
		cat "${HOME}/$1" > "${HOME}/sysconfig/Backup/$(basename $1)"
		delete_file "${HOME}/$1"
	fi
	# Check if a symlink already exists, and if so, kill it
	test_link "${HOME}/$1" && delete_file "${HOME}/$1"
	# Create a symlink from the dotfile to the sysconfig file
	# ln creates a link to the first argument, from the second argument. FYI.
	ln -fs "${HOME}/sysconfig/$2" "${HOME}/$1"
}

# Remove a symlink and restore the dotfile, if present.
# Same call pattern as file_link
function file_unlink()
{
	# Check if a symlink exists and if so, remove it
	test_link "${HOME}/$1" && delete_file "${HOME}/$1"
	touch "${HOME}/$1"
	# Check if a backup of the dotfile exists and if so, restore it
	if test_file "${HOME}/sysconfig/Backup/$(basename $1)"
	then
		cat "${HOME}/sysconfig/Backup/$(basename $1)" > "${HOME}/$1"
		delete_file "${HOME}/sysconfig/Backup/$(basename $1)"
	# If a backup does not exist, use the sysconfig file instead
	# DO NOT DELETE THE SYSCONFIG FILE
	else
		cat "${HOME}/sysconfig/$2" > "${HOME}/$1"
	fi
}

function config_inject()
{
	for CONFIG in ".bashrc" ".zshrc"
	do
		if test_file "${HOME}/${CONFIG}"
		then
			grep "source \${HOME}/sysconfig/$1" < "${HOME}/${CONFIG}" > /dev/null \
			|| echo "source \${HOME}/sysconfig/$1" >> "${HOME}/${CONFIG}"
		fi
	done
}

function config_remove()
{
	for CONFIG in ".bashrc" ".zshrc"
	do
		if test_file "${HOME}/${CONFIG}"
		then
			sed s:"source \${HOME}/sysconfig/$1":'':g < "${HOME}/${CONFIG}"
		fi
	done
}

##
# LINKERS
##

function tmux_link()
{
	file_link ".tmux.conf" "tmux/tmux.conf"
	# Inject tmux-ing functions into shell configuration
	config_inject "tmux/misc.sh"
}

function zsh_link()
{
	file_link ".zshrc" "zsh/zshrc.sh"
	file_link ".zshenv" "zsh/zshenv.sh"
}

##
# UNLINKERS
##

function tmux_unlink()
{
	file_unlink ".tmux.conf" "tmux/tmux.conf"
	# Remove tmux-ing functions from shell configuration
	config_remove "tmux/misc.sh"
}

function zsh_unlink()
{
	file_unlink ".zshrc" "zsh/zshrc.sh"
	file_unlink ".zshenv" "zsh/zshenv.sh"
}

case "$1" in
	LINK_ALL)
		tmux_link
		zsh_link
	;;
	LINK_TMUX)
		tmux_link
	;;
	LINK_ZSH)
		zsh_link
	;;
	UNLINK_ALL)
		tmux_unlink
		zsh_unlink
	;;
	UNLINK_TMUX)
		tmux_unlink
	;;
	UNLINK_ZSH)
		zsh_unlink
	;;
esac
