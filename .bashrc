#!/bin/bash
# A basically sane bash environment.
#
# Ryan Tomayko <http://tomayko.com/about> (with help from the internets).

# setup some basic variables
: ${HOME=~}
: ${LOGNAME=$(id -un)}
: ${UNAME=$(uname)}

# ----------------------------------------------------------------------
# CONFIGURATION
# ----------------------------------------------------------------------

# complete hostnames from
: ${HOSTFILE=~/.ssh/known_hosts}

# readline inputrc
: ${INPUTRC=~/.inputrc}


# ----------------------------------------------------------------------
#  SHELL OPTIONS
# ----------------------------------------------------------------------

# bring in system bashrc
test -r /etc/bashrc &&
      . /etc/bashrc

# notify of bg job completion immediately
set -o notify

# shell opts. see bash(1) for details
shopt -s cdspell >/dev/null 2>&1
shopt -s extglob >/dev/null 2>&1
shopt -s histappend >/dev/null 2>&1
shopt -s hostcomplete >/dev/null 2>&1
shopt -s interactive_comments >/dev/null 2>&1
shopt -u mailwarn >/dev/null 2>&1
shopt -s no_empty_cmd_completion >/dev/null 2>&1

# fuck that you have new mail shit
unset MAILCHECK

# disable core dumps
ulimit -S -c 0

# default umask
umask 0022

# ----------------------------------------------------------------------
# PATH
# ----------------------------------------------------------------------

# we want the various sbins on the path along with /usr/local/bin
PATH="$PATH:/usr/local/sbin:/usr/sbin:/sbin"
PATH="/usr/local/bin:$PATH"

# put MySQL on PATH if you have it
test -d "/usr/local/mysql/bin" &&
PATH="/usr/local/mysql/bin:$PATH"

# put ~/bin on PATH if you have it
test -d "$HOME/bin" &&
PATH="$HOME/bin:$PATH"

# put ~/.gem/ruby/1.8/bin on PATH if you have it
test -d "$HOME/.gem/ruby/1.8/bin" &&
PATH="$HOME/.gem/ruby/1.8/bin:$PATH"

# Node.js
NODE_PATH="/usr/local/lib/node_modules"
export NODE_PATH
test -d "/usr/local/share/npm/bin" &&
PATH="/usr/local/share/npm/bin:$PATH"

# Go
test -d "/usr/local/go/bin" && PATH="/usr/local/go/bin:$PATH"
GOPATH="$HOME/go"
export GOPATH
test -d "$GOPATH/bin" && PATH="$GOPATH/bin:$PATH"

# rbenv
test -d "$HOME/.rbenv/bin" &&
PATH="$HOME/.rbenv/bin:$PATH"

# ----------------------------------------------------------------------
# ENVIRONMENT CONFIGURATION
# ----------------------------------------------------------------------

# detect interactive shell
case "$-" in
    *i*) INTERACTIVE=1 ;;
    *)   unset INTERACTIVE ;;
esac

# detect login shell
case "$0" in
    -*) LOGIN=1 ;;
    *)  unset LOGIN ;;
esac

# enable en_US locale w/ utf-8 encodings if not already configured
: ${LANG:="en_US.UTF-8"}
: ${LANGUAGE:="en"}
: ${LC_CTYPE:="en_US.UTF-8"}
: ${LC_ALL:="en_US.UTF-8"}
export LANG LANGUAGE LC_CTYPE LC_ALL

# always use PASSIVE mode ftp
: ${FTP_PASSIVE:=1}
export FTP_PASSIVE

# ignore backups, CVS directories, python bytecode, vim swap files
FIGNORE="~:CVS:#:.pyc:.swp:.swa:apache-solr-*"
HISTCONTROL=ignoreboth

# ----------------------------------------------------------------------
# PAGER / EDITOR
# ----------------------------------------------------------------------

# See what we have to work with ...
HAVE_VIM=$(command -v vim)
HAVE_GVIM=$(command -v gvim)
HAVE_TEXTMATE=$(command -v mate)
HAVE_MATE_WAIT=$(command -v mate_wait)
HAVE_SUBL=$(command -v subl)

# EDITOR
if test -n "$HAVE_SUBL" ; then
    EDITOR=subl
elif test -n "$HAVE_MATE_WAIT" ; then
    EDITOR=mate_wait
elif test -n "$HAVE_TEXTMATE" ; then
    EDITOR=mate
elif test -n "$HAVE_VIM" ; then
    EDITOR=vim
else
    EDITOR=vi
fi
export EDITOR

# PAGER
if test -n "$(command -v less)" ; then
    PAGER="less -FirSwX"
    MANPAGER="less -FiRswX"
else
    PAGER=more
    MANPAGER="$PAGER"
fi
export PAGER MANPAGER

# ----------------------------------------------------------------------
# PROMPT
# ----------------------------------------------------------------------

RED="\[\033[0;31m\]"
BROWN="\[\033[0;33m\]"
CYAN="\[\e[01;36m\]"
GREEN="\[\e[01;32m\]"
GREY="\[\033[0;97m\]"
BLUE="\[\033[0;34m\]"
PS_CLEAR="\[\033[0m\]"
SCREEN_ESC="\[\033k\033\134\]"

if [ "$LOGNAME" = "root" ]; then
    COLOR1="${RED}"
    COLOR2="${BROWN}"
    P="#"
elif hostname | grep -q 'squareup\.com'; then
    SQUARE=yep
    COLOR1="\[\e[0;94m\]"
    COLOR2="\[\e[0;92m\]"
    P="\$"
else
    COLOR1="${BLUE}"
    COLOR2="${BROWN}"
    P="\$"
fi

prompt_simple() {
    unset PROMPT_COMMAND
    PS1="[\u@\h:\w]\$ "
    PS2="> "
}

prompt_compact() {
    unset PROMPT_COMMAND
    PS1="${COLOR1}${P}${PS_CLEAR} "
    PS2="> "
}

prompt_color() {
    PS1="${GREY}[${COLOR1}\u${GREY}@${COLOR2}\h${GREY}:${COLOR1}\W${GREY}]${COLOR2}$P${PS_CLEAR} "
    PS2="\[[33;1m\]continue \[[0m[1m\]> "
}

prompt_color_git() {
    PS1="${GREEN}\u@\h${CYAN} \w \$(__git_ps1 '(%s) ')$P${PS_CLEAR} "
    PS2="\[[33;1m\]continue \[[0m[1m\]> "
}

# ----------------------------------------------------------------------
# MACOS X / DARWIN SPECIFIC
# ----------------------------------------------------------------------

if [ "$UNAME" = Darwin ]; then
    # XCode and iOS Simulator
    XCODE_PATH=`xcode-select -p`
    alias simulator="open $XCODE_PATH/Applications/iOS\ Simulator.app"

    # put ports on the paths if /opt/local exists
    test -x /opt/local && {
        PORTS=/opt/local

        # setup the PATH and MANPATH
        PATH="$PORTS/bin:$PORTS/sbin:$PATH"
        MANPATH="$PORTS/share/man:$MANPATH"

        # nice little port alias
        alias port="sudo nice -n +18 $PORTS/bin/port"
    }

    test -x /usr/pkg && {
        PATH="/usr/pkg/sbin:/usr/pkg/bin:$PATH"
        MANPATH="/usr/pkg/share/man:$MANPATH"
    }

    # setup java environment. puke.
    JAVA_HOME="/System/Library/Frameworks/JavaVM.framework/Home"
    ANT_HOME="/Developer/Java/Ant"
    export ANT_HOME JAVA_HOME

    # hold jruby's hand
    test -d /opt/jruby &&
    JRUBY_HOME="/opt/jruby"
    export JRUBY_HOME

    # setup scala environment
    test -x /usr/local/scala && {
      SCALA_HOME=/usr/local/scala
      PATH="$SCALA_HOME/bin:$PATH"
      MANPATH="$SCALA_HOME/man:$MANPATH"
      export SCALA_PATH
    }
fi

# ----------------------------------------------------------------------
# ALIASES / FUNCTIONS
# ----------------------------------------------------------------------

# disk usage with human sizes and minimal depth
alias du1='du -h --max-depth=1'
alias fn='find . -name'
alias hi='history | tail -20'
alias pg="ps ax | grep -v grep | grep -i "
alias ip="ifconfig | grep 'inet '"
alias empties="find . -empty -type d -maxdepth 2"

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f ~/.git_aliases ]; then
    . ~/.git_aliases
fi

if [ -f ~/.rails_aliases ]; then
    . ~/.rails_aliases
fi

# ----------------------------------------------------------------------
# BASH COMPLETION
# ----------------------------------------------------------------------

if test -z "$BASH_COMPLETION" ; then
    bash=${BASH_VERSION%.*}; bmajor=${bash%.*}; bminor=${bash#*.}
    if [ "$PS1" ] && [ $bmajor -gt 1 ] ; then
        # search for a bash_completion file to source
        for f in /usr/pkg/etc/back_completion \
            /usr/local/etc/bash_completion \
            /opt/local/etc/bash_completion \
            /etc/bash_completion \
            ~/.bash_completion ;
        do
            test -f $f && {
                . $f
                break
            }
        done
    fi
    unset bash bmajor bminor
fi

# enable git completion
if [ -f ~/.git_completion ]; then
    . ~/.git_completion
fi

# override and disable tilde expansion
_expand() {
    return 0
}

# ----------------------------------------------------------------------
# LS AND DIRCOLORS
# ----------------------------------------------------------------------

# we always pass these to ls(1)
LS_COMMON="-hBG"

# if the dircolors utility is available, set that up to
dircolors="$(type -P gdircolors dircolors | head -1)"
test -n "$dircolors" && {
    COLORS=/etc/DIR_COLORS
    test -e "/etc/DIR_COLORS.$TERM"   && COLORS="/etc/DIR_COLORS.$TERM"
    test -e "$HOME/.dircolors"        && COLORS="$HOME/.dircolors"
    test ! -e "$COLORS"               && COLORS=
    eval `$dircolors --sh $COLORS`
}
unset dircolors

# setup the main ls alias if we've established common args
test -n "$LS_COMMON" &&
alias ls="command ls $LS_COMMON"

# these use the ls aliases above
alias ll="ls -l"
alias l.="ls -d .*"

# --------------------------------------------------------------------
# MISC COMMANDS
# --------------------------------------------------------------------

# push SSH public key to another box
push_ssh_cert() {
    local _host
    test -f ~/.ssh/id_dsa.pub || ssh-keygen -t dsa
    for _host in "$@";
    do
        echo $_host
        ssh $_host 'cat >> ~/.ssh/authorized_keys' < ~/.ssh/id_dsa.pub
    done
}

saa() {
  eval $(ssh-agent)
  ssh-add ~/.ssh/id_rsa
}

# SSH Agent Socket
export SSH_AUTH_SOCK=$(ls -1t $(find /tmp/* -type s -name 'Listeners' 2>/dev/null) | head -n 1)

# -------------------------------------------------------------------
# USER SHELL ENVIRONMENT
# -------------------------------------------------------------------

# source ~/.shenv now if it exists
test -r ~/.shenv &&
. ~/.shenv

# Use the color prompt by default when interactive
test -n "$PS1" &&
prompt_color_git

# -------------------------------------------------------------------
# MOTD / FORTUNE
# -------------------------------------------------------------------

test -n "$INTERACTIVE" -a -n "$LOGIN" && {
    uname -npsr
    uptime
}

# vim: ts=4 sts=4 shiftwidth=4 expandtab

# -------------------------------------------------------------------
# rvm & rbenv
# -------------------------------------------------------------------

[[ -s ~/.rvm/scripts/rvm ]] &&
. ~/.rvm/scripts/rvm

which -s rbenv && eval "$(rbenv init -)"

# -------------------------------------------------------------------
# Google Cloud
# -------------------------------------------------------------------

# goapp for App Engine
alias goapp=~/google-cloud-sdk/platform/google_appengine/goapp

# The next line updates PATH for the Google Cloud SDK.
. ~/google-cloud-sdk/path.bash.inc

# The next line enables bash completion for gcloud.
. ~/google-cloud-sdk/completion.bash.inc

# -------------------------------------------------------------------
# Heroku
# -------------------------------------------------------------------

export PATH="/usr/local/heroku/bin:$PATH"
