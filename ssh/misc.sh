#!/bin/bash

# Add a public key to authorized_keys.pub if it is not already present
function ssh_add_key()
{
# If grep finds the given key, nothing happens. If grep does not, it emits a
# failed exit, and the given key is appended to the key index.
	grep "$(cat "keys/$1")" \
	<  "${HOME}/sysconfig/keys/authorized_keys.pub" \
	>  /dev/null \
	|| cat "keys/$1" \
	>> "keys/authorized_keys.conf"
}

# Remove a public key from authorized_keys.pub if it is present.
function ssh_del_key()
{
# If sed finds the given key, it replaces it with a blank line. If not, nothing
# happens. Overuse of these functions will eventually leave many empty lines in
# the key index. Manual curation is required to fix that.
	sed s:"$(cat "keys/$1")":'':g \
	< "${HOME}/sysconfig/keys/authorized_keys.conf" \
	> "${HOME}/sysconfig/keys/authorized_keys.conf.tmp"
	sync
	mv "${HOME}/sysconfig/keys/authorized_keys.conf.tmp" \
	   "${HOME}/sysconfig/keys/authorized_keys.conf"
}

# Get an array of key names matching parameters
function ssh_get_key()
{
# If no arguments are given, produce all keys
	if [ -z "$1" ]
	then
		KEYS=$(ls ${HOME}/sysconfig/ssh/keys/*.pub)
# If one argument is given, it must be the username.
	elif [ -z "$2" ]
	then
		KEYS=$(ls ${HOME}/sysconfig/ssh/keys/$1-*.pub)
# If two arguments are given, the second must be the machine
	elif [ -z "$3" ]
	then
		KEYS=$(ls ${HOME}/sysconfig/ssh/keys/$1-$2-*.pub)
# If three arguments are given, the third is they keytype
	elif [ -z "$4" ]
	then
		KEYS=$(ls ${HOME}/sysconfig/ssh/keys/$1-$2-$3-*.pub)
# If four or more are provided, uh, you did it wrong
	else
		cat <<-EOS
[**] ERROR: Too many arguments provided!
[**] Call as `ssh_get_key [USER [HOST [TYPE]]]`
[**] Possible arguments are:
[**] None -- yields all pubkeys
[**] One -- yields all pubkeys belonging to the given USER
[**] Two -- yields all pubkeys belonging to the USER at the given HOST
[**] Three -- yields the pubkey belonging to the USER at HOST of the given TYPE.
		EOS
	fi

	echo $KEYS
}

function ssh_fix_perms()
{
	chown -R "$(whoami):$(whoami)" "${HOME}/sysconfig/ssh/keys"
	chmod 600 "${HOME}/sysconfig/ssh/keys/*.prv"
	chmod 644 "${HOME}/sysconfig/ssh/keys/*.pub"
	chmod 644 "${HOME}/sysconfig/ssh/keys/*.conf"
}
