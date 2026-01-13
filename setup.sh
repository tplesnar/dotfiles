#!/bin/bash
set -e

echo "Setting up your Mac..."

# Check for Homebrew and install if we don't have it
if ! command -v brew &> /dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Update Homebrew and install dependencies
brew update
brew bundle --file=$HOME/.dotfiles/Brewfile
brew analytics off

# Check for Oh My Zsh and install if we don't have it
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  /bin/sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# PHP Development (uncomment when needed)
# mysql -u root -e "ALTER USER root@localhost IDENTIFIED WITH mysql_native_password BY 'password'; FLUSH PRIVILEGES;"
# pecl install imagick redis
# $(brew --prefix)/bin/composer global require laravel/installer laravel/valet beyondcode/expose spatie/global-ray spatie/visit
# $HOME/.composer/vendor/bin/valet install
# $HOME/.composer/vendor/bin/global-ray install

# Create directories
mkdir -p $HOME/BeepBoop
mkdir -p $HOME/.vim/{backups,swaps,undo}

# Symlinks
ln -sf "$HOME/.dotfiles/.zshrc" "$HOME/.zshrc"
ln -sf "$HOME/.dotfiles/.p10k.zsh" "$HOME/.p10k.zsh"
ln -sf "$HOME/.dotfiles/.gitignore_global" "$HOME/.gitignore_global"
git config --global core.excludesfile $HOME/.gitignore_global

# Silence login message
touch $HOME/.hushlogin

# Set macOS preferences (runs last as it reloads the shell)
source $HOME/.dotfiles/.macos
