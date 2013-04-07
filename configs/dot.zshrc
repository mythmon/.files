HISTFILE=~/.zsh/history
HISTSIZE=10000
SAVEHIST=1000000
setopt appendhistory autocd extendedglob nomatch notify extended_history
setopt hist_ignore_dups hist_reduce_blanks extendedglob
unsetopt beep

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' expand prefix
zstyle ':completion:*' ignore-parents parent pwd ..
zstyle ':completion:*' list-suffixes true
zstyle ':completion:*' matcher-list \
    '' \
    'r:|[._-]=** r:|=**' \
    'm:{[:lower:]}={[:upper:]} r:|[._-]=** r:|=**' \
    'm:{[:lower:][:upper:]}={[:upper:][:lower:]} r:|[._-]=** r:|=** l:|=* r:|=*'

zstyle ':completion:*' max-errors 2
zstyle ':completion:*' preserve-prefix '//[^/]##/'
zstyle :compinstall filename '$HOME/.zshrc'

autoload -Uz compinit promptinit add-zsh-hook
compinit

bindkey -e
bindkey "[3~" delete-char

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

# preexec hook shows command in title as it's running, and precmd sets it to
# something else when it's done. this should work with screen and
# gnome-terminal2/multi-gnome-terminal

case $TERM in
    xterm*|screen*)
        preexec () {
            export CURRENTCMD="$1"
            if [ x$WINDOW != x ]; then
                print -Pn "\ek$1\e\\"
            else
                print -Pn "\e]0;$1\a"
            fi
        }
        precmd () {
            if [[ ! -z $CURRENTCMD ]]; then
                if [ x$WINDOW != x ]; then
                    print -Pn "\ek($CURRENTCMD)\e\\"
                else
                    print -Pn "\e]0;($CURRENTCMD)\a"
                fi
            fi
        }
    ;;
esac

PATH="$HOME/bin:$PATH:$HOME/.cabal/bin"

export EDITOR="vim"

alias ls='ls --color=if-tty --group-directories-first -hF'
alias rm='rm -r'
alias cp='cp -r'

fortune -ac
echo

# Include various sub-.zshrc files
# but don't include vim .swp files
for file in $(ls $HOME/.zshrc.d/* | grep -ve ".swp$" | grep -ve ".bak$")
do
    source $file
done
