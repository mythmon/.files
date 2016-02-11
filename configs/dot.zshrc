HISTFILE=~/.zsh/history
HISTSIZE=1000000
SAVEHIST=1000000

ttyctl -f

setopt autocd            # cd to directory without saying cd.
setopt extendedglob      # Better globbing.
setopt extended_history  # Put timestamp and runtime in history file
setopt histignoredups    # De-dupe history
setopt histreduceblanks  # Remove extra whitespace from history
setopt hist_ignore_space # Don't history commands that start with a space
setopt notify            # report status of background jobs
setopt longlistjobs      # display PID when suspending processes
setopt nohup             # don't kill background jobs
unsetopt beep            # shutup!

# Colors for ls. sets LS_COLORS
eval $(dircolors)

fpath=(~/.zsh/completions $fpath)

autoload -Uz compinit promptinit add-zsh-hook
compinit

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' expand prefix
zstyle ':completion:*' ignore-parents parent pwd ..
zstyle ':completion:*' list-suffixes true
zstyle ':completion:*' max-errors 2
zstyle ':completion:*' menu select

# use colors for file completion
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
# use groups for completion
zstyle ':completion:*:descriptions' format "Completing %B%d%b%"
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*' group-name ''
# warn if there are no matches
zstyle ':completion:*:warnings' format \
    "%{$fg[red]%}No matches for:%{$reset_color%} %d"
# display all processes for killall/...
zstyle ':completion:*:processes-names' command \
    'ps c -u ${USER} -o command | uniq'
# group man pages per section
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.*' insert-sections true
# verbose output
zstyle ':completion:*' verbose true
# show file types
setopt listtypes
# Matcher rules:
#  1. Exact match
#  2. extend on the right, extend -._
#  3. case insensitive, extend on right, extend -._
#  4. case swap, allow extension on left or right.
zstyle ':completion:*' matcher-list \
    '' \
    'r:|[._-]=** r:|=**' \
    'm:{[:lower:]}={[:upper:]} r:|[._-]=** r:|=**' \
    'm:{[:lower:][:upper:]}={[:upper:][:lower:]} r:|[._-]=** r:|=** l:|=* r:|=*'

# Make "words" delimited by more things (ie: path pieces instead of full paths)
WORDCHARS=${WORDCHARS//[&=\/;!#%\{]}

export PATH="$HOME/.gem/ruby/2.0.0/bin:$PATH"
export PATH="$HOME/node_modules/.bin:$PATH"
export PATH="$HOME/.cabal/bin:$PATH"
export PATH="$HOME/bin:$PATH"

export EDITOR="vim"
export BROWSER="browser"

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

#task-fortune

# Include various sub-.zshrc files
# but don't include vim .swp files
for file in $(ls $HOME/.zshrc.d/* | grep -ve ".swp$" | grep -ve ".bak$")
do
    source $file
done
