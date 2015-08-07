#!/bin/zsh

# zshenv files (system and user) are sourced first, for ALL instances of zsh.
# Thus, they should ONLY set up the environment, and make no assumptions about
# interactivity or even terminal attachment.

# Let's mess with the path
# The typeset -U directive means zsh will strip duplicate entries for us
# The "path" variable in zsh automatically becomes a properly-formatted PATH
# variable in the environment
# Side note: On Arch Linux, zsh is told to source /etc/profile which hard-sets
# $PATH, so path may have to be set in zshrc as well as zshenv to ensure desired
# performance. However, since I am writing this for cross-platform use, zshenv
# gets it as well.
typeset -U path
path=(~/bin ~/node_modules/.bin $path)
