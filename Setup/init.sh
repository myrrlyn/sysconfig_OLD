#!/bin/bash

#echo "$(pwd)/$0"

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

case "$1" in
	help)
		exec "${HOME}/sysconfig/Setup/help.sh"
	;;
	link)
		if [ -z "$2" ]
		then
			exec "${LINK_SCRIPT}" LINK_ALL
		else
			case "$2" in
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
				tmux)
					exec "${LINK_SCRIPT}" UNLINK_TMUX
				;;
				zsh)
					exec "${LINK_SCRIPT}" UNLINK_ZSH
				;;
			esac
		fi
	;;
esac

unset LINK_SCRIPT
