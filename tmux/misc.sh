#!/bin/bash

# Do not execute this; my editor just really likes having a shebang there
# Source this file from any shell that will accept it.

# tmux does not provide an internal function to rename panes. Run this function
# in a pane to rename it.
function tmux_pane_name()
{
	printf '\033]2;%s\033\\' "$1"
}
