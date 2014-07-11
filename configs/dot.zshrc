HISTFILE=~/.zsh/history
HISTSIZE=1000000
SAVEHIST=1000000

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

# Colors for ls. sets LSCOLORS
if [[ -f ~/.dircolors ]]; then
    eval $(dircolors ~/.dircolors)
else
    eval $(dircolors)
fi

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' expand prefix
zstyle ':completion:*' ignore-parents parent pwd ..
zstyle ':completion:*' list-suffixes true
zstyle ':completion:*' max-errors 2
zstyle ':completion:*' preserve-prefix '//[^/]##/'
# Show menu if >5 completions
zstyle ':completion:*' menu select

# use colors for file completion
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
# use groups for completion
zstyle ':completion:*:descriptions' format \
    "%{$fg[red]%}completing %B%d%b%{$reset_color%}"
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

zstyle :compinstall filename '$HOME/.zshrc'

autoload -Uz compinit promptinit add-zsh-hook
compinit

# Make "words" delimited by more things (ie: path pieces instead of full paths)
WORDCHARS=${WORDCHARS//[&=\/;!#%\{]}

rationalise-dot() {
    if [[ $LBUFFER = *.. ]]; then
        LBUFFER+=/../
    elif [[ $LBUFFER = *../ ]]; then
        LBUFFER+=../
    else
        LBUFFER+=.
    fi
}
zle -N rationalise-dot
bindkey . rationalise-dot

export PATH="$HOME/bin:$PATH:$HOME/.gem/ruby/2.0.0/bin:$HOME/node_modules/.bin"
export CDPATH="$HOME"
export EDITOR="vim"

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

alias ls='ls --color=if-tty --group-directories-first -hF'
alias rm='rm -r'
alias cp='cp -r'

#fortune -ac
task fortune

# Include various sub-.zshrc files
# but don't include vim .swp files
for file in $(ls $HOME/.zshrc.d/* | grep -ve ".swp$" | grep -ve ".bak$")
do
    source $file
done
