#!/bin/sh

echo "Setting up your Mac..."

# Configure DNS
networksetup -setdnsservers Wi-Fi 80.67.169.12 80.67.169.40 2001:910:800::12 2001:910:800::40 208.67.222.222 208.67.220.220
networksetup -setdnsservers ethernet 80.67.169.12 80.67.169.40 2001:910:800::12 2001:910:800::40 208.67.222.222 208.67.220.220

# Check for Oh My Zsh and install if we don't have it
if test ! $(which omz); then
  /bin/sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Update Homebrew recipes
brew update

# Install all our dependencies with bundle (See Brewfile)
brew tap homebrew/bundle
brew bundle

# Turn Homebrew's analytics off
brew analytics off

# Set default MySQL root password and auth type.
mysql -u root -e "ALTER USER root@localhost IDENTIFIED WITH mysql_native_password BY 'password'; FLUSH PRIVILEGES;"

# Install PHP extensions with PECL
pecl install imagick redis

# Install global Composer packages
$(brew --prefix)/bin/composer global require laravel/installer laravel/valet beyondcode/expose spatie/global-ray spatie/visit

# Install Laravel Valet
$HOME/.composer/vendor/bin/valet install

# Install Global Ray
$HOME/.composer/vendor/bin/global-ray install

mkdir $HOME/BeepBoop

mkdir $HOME/.vim
mkdir $HOME/.vim/backups
mkdir $HOME/.vim/swaps
mkdir $HOME/.vim/undo

ln -s $HOME/.dotfiles/warp $HOME/.warp

touch $HOME/.hushlogin

# Removes .zshrc from $HOME (if it exists) and symlinks the .zshrc file from the .dotfiles
rm -rf $HOME/.zshrc
ln -s $HOME/.dotfiles/.zshrc $HOME/.zshrc
ln -s $HOME/.dotfiles/.p10k.zsh $HOME/.p10k.zsh

# Add global gitignore
ln -s $HOME/.dotfiles/.gitignore_global $HOME/.gitignore_global
git config --global core.excludesfile $HOME/.gitignore_global

# Symlink the Mackup config file to the home directory
ln -s $HOME/.dotfiles/.mackup.cfg $HOME/.mackup.cfg
ln -s $HOME/.dotfiles/.mackup $HOME/.mackup

# Set macOS preferences
# We will run this last because this will reload the shell
source .macos
