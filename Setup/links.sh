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
	touch "${HOME}/sysconfig/$2"
# Check if a dotfile already exists and if so, back it up. If the dotfile is
# a symlink, remove the link.
	if test_file "${HOME}/$1"
	then
		touch "${HOME}/sysconfig/Backup/$(basename $1)"
		cat "${HOME}/$1" > "${HOME}/sysconfig/Backup/$(basename $1)"
		delete_file "${HOME}/$1"
	elif test_link "${HOME}/$1"
		delete_file "${HOME}/$1"
	fi
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
# If the link was removed and replaced with an actual file, well...
# RIP that file. The backup's coming in, choo choo.
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
# I don't use any other shells
	for CONFIG in ".bashrc" ".zshrc"
	do
# Look for if the config file exists
		if test_file "${HOME}/${CONFIG}"
		then
# Look for the target line to already exist
# If it isn't there, grep reports a failure, so we add the line.
			grep "source \${HOME}/sysconfig/$1" \
			< "${HOME}/${CONFIG}" \
			> /dev/null \
			|| echo "source \${HOME}/sysconfig/$1" \
			>> "${HOME}/${CONFIG}"
		fi
	done
}

function config_remove()
{
	for CONFIG in ".bashrc" ".zshrc"
	do
		if test_file "${HOME}/${CONFIG}"
		then
# Search for the appropriate line, and if found, kill it.
# Note: Reading from and writing to the same file results in the file being
# emptied. Write to a tmpfile, flush to filesystem, and then finalize.
			sed s:"source \${HOME}/sysconfig/$1":'':g \
			< "${HOME}/${CONFIG}" \
			> "${HOME}/${CONFIG}.tmp"
			sync
			mv "${HOME}/${CONFIG}.tmp" "${HOME}/${CONFIG}"
		fi
	done
}

##
# LINKERS
##

function ssh_link()
{
	file_link ".ssh/authorized_keys" "ssh/authorized_keys.conf"
	file_link ".ssh/config" "ssh/configc.conf"
	file_link ".ssh/environment" "ssh/environment.conf"
	config_inject "ssh/misc.sh"
	for KEY in "ecdsa" "ed25519" "rsa"
	do
		if test_file "${HOME}/.ssh/id_${KEY}" \
		&& test_file "${HOME}/.ssh/id_${KEY}.pub"
		then
			cat <<-EOS
[**] NOTE: Pre-existing ${KEY} keys found!
[**] Copying to ~/sysconfig/Backup and ~/sysconfig/ssh/keys
[**] Linking from ~/.ssh/id_KEYTYPE to ~/sysconfig/ssh/keys/USER-HOST-${KEY}
			EOS
			touch "${HOME}/sysconfig/Backup/id_${KEY}"
			touch "${HOME}/sysconfig/Backup/id_${KEY}.pub"
cp "${HOME}/.ssh/id_${KEY}" \
   "${HOME}/sysconfig/Backup/id_${KEY}"
cp "${HOME}/.ssh/id_${KEY}" \
   "${HOME}/sysconfig/ssh/keys/$(whoami)-$(cat /etc/hostname)-${KEY}.prv"
cp "${HOME}/.ssh/id_${KEY}.pub" \
   "${HOME}/sysconfig/Backup/id_${KEY}.pub"
cp "${HOME}/.ssh/id_${KEY}.pub" \
   "${HOME}/sysconfig/ssh/keys/$(whoami)-$(cat /etc/hostname)-${KEY}.pub"
delete_file "${HOME}/.ssh/id_${KEY}"
delete_file "${HOME}/.ssh/id_${KEY}.pub"
ln -fs \
   "${HOME}/sysconfig/ssh/keys/$(whoami)-$(cat /etc/hostname)-${KEY}.prv" \
   "${HOME}/.ssh/id_${KEY}"
ln -fs \
   "${HOME}/sysconfig/ssh/keys/$(whoami)-$(cat /etc/hostname)-${KEY}.pub" \
   "${HOME}/.ssh/id_${KEY}.pub"
			cat <<-EOS
[**] Key relocation complete.
			EOS
		fi
	done
	cat <<-EOS
Consider adding elements from sysconfig/ssh/configd.conf to your system's
/etc/ssh/sshd_config file. This script cannot do so for you.
	EOS
}

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

function ssh_unlink()
{
	file_unlink ".ssh/authorized_keys" "ssh/authorized_keys.txt"
	file_unlink ".ssh/config" "ssh/configc.conf"
	file_unlink ".ssh/environment" "ssh/environment.conf"
	config_remove "ssh/misc.sh"
	for KEY in "dsa" "ecdsa" "ed25519" "rsa"
	do
		test_link "${HOME}/.ssh/id_${KEY}" && \
		delete_file "${HOME}/.ssh/id_${KEY}"
		test_link "${HOME}/.ssh/id_${KEY}.pub" && \
		delete_file "${HOME}/.ssh/id_${KEY}.pub"
		if test_file "${HOME}/Backup/id_${KEY}" \
		&& test_file "${HOME}/Backup/id_${KEY}.pub"
		then
			cp "${HOME}/Backup/id_${KEY}" "${HOME}/.ssh/id_${KEY}"
			cp "${HOME}/Backup/id_${KEY}.pub" "${HOME}/.ssh/id_${KEY}.pub"
		fi
	done
}

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
		ssh_link
		tmux_link
		zsh_link
	;;
	LINK_SSH)
		ssh_link
	;;
	LINK_TMUX)
		tmux_link
	;;
	LINK_ZSH)
		zsh_link
	;;
	UNLINK_ALL)
		ssh_link
		tmux_unlink
		zsh_unlink
	;;
	UNLINK_SSH)
		ssh_unlink
	;;
	UNLINK_TMUX)
		tmux_unlink
	;;
	UNLINK_ZSH)
		zsh_unlink
	;;
# God forbid this should ever be printed. If it is, something's fucky.
	*)
		cat <<-EOS
This script must be given an argument $1 in order to function properly. It
should only be called from within the init script, and not by itself.
		EOS
	;;
esac
