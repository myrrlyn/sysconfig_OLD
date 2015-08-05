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
test_file()
{
	   [ -f "$1" ] \
	&& [ -s "$1" ] \
	&& [ ! -h "$1" ]
}
test_link()
{
	[ -h "$1" ]
}

# Echo an error message if a file cannot be deleted
delete_file()
{
	$(which rm) -f "$1" || echo "[>>] ERROR: Cannot delete file $1"
}

# Back up a dotfile and create a symlink to the appropriate sysconfig file.
# Call with dotfile first and sysconfig file second. Dotfile assumes it is in ~
# and sysconfig file assumes it is in ~/sysconfig
file_link()
{
	# Check if a dotfile already exists and if so, back it up
	if test_file "$HOME/$1" ; then
		touch "$HOME/sysconfig/Backup/$1"
		cat "$HOME/$1" > "$HOME/sysconfig/Backup/$1"
		delete_file "$HOME/$1"
	fi
	# Check if a symlink already exists, and if so, kill it
	test_link "$HOME/$1" && delete_file "$HOME/$1"
	# Create a symlink from the dotfile to the sysconfig file
	# ln creates a link to the first argument, from the second argument. FYI.
	$(which ln) -fs "$HOME/sysconfig/$2" "$HOME/$1"
}
# Remove a symlink and restore the dotfile, if present.
# Same call pattern as file_link
file_unlink()
{
	# Check if a symlink exists and if so, remove it
	test_link "$HOME/$1" && delete_file "$HOME/$1"
	touch "$HOME/$1"
	# Check if a backup of the dotfile exists and if so, restore it
	if test_file "$HOME/sysconfig/Backup/$1" ; then
		cat "$HOME/sysconfig/Backup/$1" > "$HOME/$1"
		delete_file "$HOME/sysconfig/Backup/$1"
	# If a backup does not exist, use the sysconfig file instead
	# DO NOT DELETE THE SYSCONFIG FILE
	else
		cat "$HOME/sysconfig/$2" > "$HOME/$1"
	fi
}

##
# LINKERS
##

##
# UNLINKERS
##

case "$1" in
	LINK_ALL)
		true
	;;
	UNLINK_ALL)
		true
	;;
esac
