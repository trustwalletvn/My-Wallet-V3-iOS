#!/bin/sh
#
#  scripts/install-brew-dependencies.sh
#
#  What It Does
#  ------------
#  Install brew dependencies.
#

set -u

git -C "/usr/local/Homebrew/Library/Taps/homebrew/homebrew-core" remote set-url origin https://github.com/Homebrew/homebrew-core
brew update
brew bundle install
