[[ -s "$HOME/.profile" ]] && source "$HOME/.profile" # Load the default .profile

export PATH=/usr/bin:/bin:/usr/sbin:/sbin

# add homebrew programs before system provided ones
export PATH=/usr/local/bin:$PATH

# Add python binaries to the path
#export PATH=$PATH:/Users/maximelasserre/Library/Python/2.7/bin

# What is this?
export PATH=/opt/X11/bin:$PATH
export PATH=/usr/texbin:$PATH

# Add Mac GPG suite binaries
export PATH=/usr/local/MacGPG2/bin:$PATH

# Add Android binaries
export PATH=/Developer/SDKs/AndroidSDK/tools:$PATH

# Gradle
export PATH=$PATH:/usr/local/gradle/bin

# Personal binaries
export PATH=$PATH:$HOME/bin

# Expand history
HISTFILESIZE=10000

function vscode () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $*; }

alias startphp="php-fpm -p ~/dotfiles/phpconf"

# Editor configuration for tmuxinator
export EDITOR='vim'

# The font used in iTerm setup is the following:
# http://www.marksimonson.com/fonts/view/anonymous-pro

for file in ~/dotfiles/bash/*; do
    [[ -r "$file" ]] && [[ -f "$file" ]] && source "$file"
done
unset file
