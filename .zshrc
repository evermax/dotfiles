[[ -s "$HOME/.profile" ]] && source "$HOME/.profile" # Load the default .profile

# Path to your oh-my-zsh installation.
export ZSH=/Users/maximelasserre/.oh-my-zsh
export SHELL=/bin/zsh

# Look in ~/.oh-my-zsh/themes/
ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh

export LANG=en_US.UTF-8

[[ -s "$HOME/.bash_profile" ]] && source "$HOME/.bash_profile"

unsetopt share_history
