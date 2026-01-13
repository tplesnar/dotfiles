# Powerlevel10k instant prompt (must stay at top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Paths
export DOTFILES=$HOME/.dotfiles
export ZSH=$HOME/.oh-my-zsh
export ZSH_CUSTOM=$DOTFILES

# Powerlevel10k & autosuggestions (via Homebrew)
source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Oh My Zsh
plugins=(git alias-finder macos artisan)

# DISABLE_UNTRACKED_FILES_DIRTY="true"  # Faster git status in large repos
# COMPLETION_WAITING_DOTS="true"        # Show dots during completion

source $ZSH/oh-my-zsh.sh

# Powerlevel10k config
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Node version manager
eval "$(fnm env --use-on-cd)"
