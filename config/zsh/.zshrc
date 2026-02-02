# Load modules
zmodload zsh/complist
autoload -U colors && colors	# Load colors
autoload -U compinit && compinit    # Load completion system

# Set prompt
PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "

# History Opts
HISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/history"
HISTSIZE=100000
SAVEHIST=100000
setopt inc_append_history hist_ignore_dups share_history hist_reduce_blanks

# Source aliases if exists
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc"

# Source fzf if installed
if command -v fzf >/dev/null 2>&1; then
  [ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
  [ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh
fi

# Activate mise if installed
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi


# Cmp Opts
zstyle ':completion:*' menu select

# Extra Opts
setopt menu_complete # Autofill first match right away, tab to fill rest
setopt autocd # Change to a directory by typing its name
setopt auto_param_slash # Auto add slash to directories when completing
setopt no_case_glob no_case_match # Case insensitive cmp
setopt globdots # Indlude dotfiles
setopt interactive_comments # Allow comments
stty stop undef # disable accidental pausing

# vi mode
bindkey -v
export KEYTIMEOUT=1


# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Load syntax highlighting; should be last.
source /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh 2>/dev/null

