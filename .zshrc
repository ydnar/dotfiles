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

# completions
autoload -U compinit && compinit
zmodload -i zsh/complist

# complete hostnames from
: ${HOSTFILE=~/.ssh/known_hosts}

# readline inputrc
: ${INPUTRC=~/.inputrc}

# ----------------------------------------------------------------------
#  SHELL OPTIONS
# ----------------------------------------------------------------------

# bring in system zshrc
test -r /etc/zshrc &&
      . /etc/zshrc

# notify of bg job completion immediately
set -o notify

# fuck that you have new mail shit
unset MAILCHECK

# disable core dumps
ulimit -S -c 0

# default umask
umask 0022

# ----------------------------------------------------------------------
# PATH
# ----------------------------------------------------------------------

# Homebrew provided Ruby
test -d "/usr/local/opt/ruby/bin" &&
PATH="/usr/local/opt/ruby/bin:$PATH"

# we want the various sbins on the path along with /usr/local/bin
PATH="$PATH:/usr/local/sbin:/usr/sbin:/sbin"
PATH="/usr/local/bin:$PATH"

# put MySQL on PATH if you have it
test -d "/usr/local/mysql/bin" &&
PATH="/usr/local/mysql/bin:$PATH"

# put ~/bin on PATH if you have it
test -d "$HOME/bin" &&
PATH="$HOME/bin:$PATH"

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

# Homebrew QT
test -d "/usr/local/opt/qt/bin" &&
PATH="/usr/local/opt/qt/bin:$PATH"

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
HAVE_SUB=$(command -v sub)
HAVE_CODE=$(command -v code)

# EDITOR
if test -n "$HAVE_CODE" ; then
    EDITOR=code
elif test -n "$HAVE_SUB" ; then
    EDITOR=sub
elif test -n "$HAVE_SUBL" ; then
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

autoload -U promptinit; promptinit
prompt pure

# Base16 Shell
BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        eval "$("$BASE16_SHELL/profile_helper.sh")"

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
    JAVA_HOME=`/usr/libexec/java_home`
    ANT_HOME="/Developer/Java/Ant"
    export ANT_HOME JAVA_HOME

    # Android Studio
    export ANDROID_HOME=$HOME/Library/Android/sdk
    PATH=$PATH:$ANDROID_HOME/emulator
    PATH=$PATH:$ANDROID_HOME/tools
    PATH=$PATH:$ANDROID_HOME/tools/bin
    PATH=$PATH:$ANDROID_HOME/platform-tools

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

if [ -f ~/.zsh_aliases ]; then
    . ~/.zsh_aliases
fi

if [ -f ~/.git_aliases ]; then
    . ~/.git_aliases
fi

# ----------------------------------------------------------------------
# LS AND DIRCOLORS
# ----------------------------------------------------------------------

# we always pass these to ls(1)
LS_COMMON="-hBG"

# if the dircolors utility is available, set that up to
# dircolors="$(type -P gdircolors dircolors | head -1)"
# test -n "$dircolors" && {
#     COLORS=/etc/DIR_COLORS
#     test -e "/etc/DIR_COLORS.$TERM"   && COLORS="/etc/DIR_COLORS.$TERM"
#     test -e "$HOME/.dircolors"        && COLORS="$HOME/.dircolors"
#     test ! -e "$COLORS"               && COLORS=
#     eval `$dircolors --sh $COLORS`
# }
# unset dircolors

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

# -------------------------------------------------------------------
# MOTD / FORTUNE
# -------------------------------------------------------------------

test -n "$INTERACTIVE" -a -n "$LOGIN" && {
    uname -npsr
    uptime
}

# vim: ts=4 sts=4 shiftwidth=4 expandtab

# -------------------------------------------------------------------
# Ruby
# -------------------------------------------------------------------

# [[ -s ~/.rvm/scripts/rvm ]] &&
# . ~/.rvm/scripts/rvm

# which -s rbenv >> /dev/null && eval "$(rbenv init -)"

# test -d /usr/local/opt/chruby && {
#     source /usr/local/opt/chruby/share/chruby/chruby.sh
#     source /usr/local/share/chruby/auto.sh
# }

# -------------------------------------------------------------------
# Google Cloud
# -------------------------------------------------------------------

# The next line updates PATH for the Google Cloud SDK.
. /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc

# The next line enables bash completion for gcloud.
. /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc

# -------------------------------------------------------------------
# hub + GitHub CLI
# https://hub.github.com
# https://cli.github.com
# -------------------------------------------------------------------

alias git=hub
