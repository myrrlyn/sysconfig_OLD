#!/bin/bash

help_general()
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

help_general
