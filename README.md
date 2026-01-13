# dotfiles

## Introduction

The main source of inspiration for this repo are the dotfiles from [Dries Vints](https://github.com/driesvints/dotfiles)

This repository serves as my way to help me setup and maintain my Mac. It takes the effort out of installing everything manually. Everything needed to install my preferred setup of macOS is detailed in this readme. Feel free to explore, learn and copy parts for your own dotfiles. Enjoy!

📖 - [Read his blog post](https://driesvints.com/blog/getting-started-with-dotfiles)  
📺 - [Watch his screencast on Laracasts](https://laracasts.com/series/guest-spotlight/episodes/1)  
💡 - [Learn how to build your own dotfiles](https://github.com/driesvints/dotfiles#your-own-dotfiles)

## A Fresh macOS Setup

These instructions are for when you've already set up your dotfiles. If you want to get started with your own dotfiles you can [find instructions below](#your-own-dotfiles).

### Before you re-install

First, go through the checklist below to make sure you didn't forget anything before you wipe your hard drive.

- Did you commit and push any changes/branches to your git repositories?
- Did you remember to save all important documents from non-iCloud directories?
- Did you save all of your work from apps which aren't synced through iCloud?
- Did you remember to export important data from your local database?

### Installing macOS cleanly

After going to our checklist above and making sure you backed everything up, we're going to cleanly install macOS with the latest release. Follow [this article](https://www.imore.com/how-do-clean-install-macos) to cleanly install the latest macOS version.

### Setting up your Mac

If you did all of the above you may now follow these install instructions to setup a new Mac.

1. Update macOS to the latest version with the App Store
2. Clone this repo to `~/.dotfiles`:

    ```zsh
    git clone https://github.com/tplesnar/dotfiles.git ~/.dotfiles
    cd ~/.dotfiles
    git submodule update --init --recursive
    ```

4. Run `setup.sh` in `~/.dotfiles/` to start the installation
5. Set up 1Password SSH agent, then switch to SSH:
```zsh
   cd ~/.dotfiles
   git remote set-url origin git@github.com:tplesnar/dotfiles.git
```
6. Restart your computer to finalize the process

Your Mac is now ready to use!

> Note: you can use a different location than `~/.dotfiles` if you want. Just make sure you also update the reference in the [`.zshrc`](./.zshrc#L2) file.

### Optional Software

Some software requires manual installation or special handling:

#### Logitech Options+

If you use Logitech peripherals, install the offline version of Options+ (no telemetry, works without internet):

```zsh
cd ~/.dotfiles
./install-logitech-options.sh
```

This script downloads and installs the offline version plus the certificate patch.

#### Neovim with LazyVim

The setup uses the official [LazyVim](https://www.lazyvim.org/) starter template - a modern Neovim configuration that provides:

- ✅ **Out-of-the-box IDE features** - LSP, Treesitter, Telescope, Git integration
- ✅ **Lazy-loaded plugins** - fast startup time
- ✅ **Extensible** - easy to customize and add plugins
- ✅ **Well-documented** - extensive help and community support
- ✅ **Auto-install** - everything sets up automatically

**First launch**:
```zsh
nvim
```

Plugins auto-install on first run (~1-2 minutes). Run `:LazyHealth` after to verify.

**Learn more**: See `~/.dotfiles/nvim/README.md` or [LazyVim docs](https://www.lazyvim.org/)

## Your Own Dotfiles

**Please note that the instructions below assume you already have set up Oh My Zsh so make sure to first [install Oh My Zsh](https://github.com/robbyrussell/oh-my-zsh#getting-started) before you continue.**

If you want to start with your own dotfiles from this setup, it's pretty easy to do so. First of all you'll need to fork this repo. After that you can tweak it the way you want.

Go through the [`.macos`](./.macos) file and adjust the settings to your liking. You can find much more settings at [the original script by Mathias Bynens](https://github.com/mathiasbynens/dotfiles/blob/master/.macos) and [Kevin Suttle's macOS Defaults project](https://github.com/kevinSuttle/MacOS-Defaults).

Check out the [`Brewfile`](./Brewfile) file and adjust the apps you want to install for your machine. Use [their search page](https://caskroom.github.io/search) to check if the app you want to install is available.

Check out the [`aliases.zsh`](./aliases.zsh) file and add your own aliases. If you need to tweak your `$PATH` check out the [`path.zsh`](./path.zsh) file. These files get loaded in because the `$ZSH_CUSTOM` setting points to the `.dotfiles` directory. You can adjust the [`.zshrc`](./.zshrc) file to your liking to tweak your Oh My Zsh setup. More info about how to customize Oh My Zsh can be found [here](https://github.com/robbyrussell/oh-my-zsh/wiki/Customization).


You can tweak the shell theme, the Oh My Zsh settings and much more. Go through the files in this repo and tweak everything to your liking.

Enjoy your own Dotfiles!

## Thanks To...

I want to thank Dries Vints for the amazing quality of his work.
