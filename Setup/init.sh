#!/bin/bash

#echo "$(pwd)/$0"

# Tilde doesn't need to expand here because it will be done when exec asks
LINK_SCRIPT="~/sysconfig/Setup/links.sh"

case "$1" in
	help)
		exec ~/sysconfig/Setup/help.sh
	;;
	link)
		if [ -z "$2" ] ; then
			exec $LINK_SCRIPT LINK_ALL
		else
			case "$2" in
				tmux)
					exec $LINK_SCRIPT LINK_TMUX
				;;
			esac
		fi
	;;
	unlink)
		if [ -z "$2" ] ; then
			exec $LINK_SCRIPT UNLINK_ALL
		else
			case "$2" in
				tmux)
					exec $LINK_SCRIPT UNLINK_TMUX
				;;
			esac
		fi
	;;
esac

unset LINK_SCRIPT
