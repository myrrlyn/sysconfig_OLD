#!/bin/bash

#echo "$(pwd)/$0"

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
				# Specific cases go here
			esac
		fi
	;;
	unlink)
		if [ -z "$2" ] ; then
			exec $LINK_SCRIPT UNLINK_ALL
		else
			case "$2" in
				# Specific cases go here
			esac
		fi
	;;
esac

unset LINK_SCRIPT
