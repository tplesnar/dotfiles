# Shortcuts
alias copyssh="pbcopy < $HOME/.ssh/id_ed25519.pub"
alias reloadshell="source $HOME/.zshrc"
alias reloaddns="dscacheutil -flushcache && sudo killall -HUP mDNSResponder"
alias ll="/opt/homebrew/opt/coreutils/libexec/gnubin/ls -AhlFo --color --group-directories-first"
alias phpstorm='open -a /Applications/PhpStorm.app "`pwd`"'
alias cpwd='pwd|tr -d "\n"|pbcopy'
alias shrug="echo '¯\_(ツ)_/¯' | pbcopy"
alias c="clear"

o() {
    if [ $# -eq 0 ]; then
        open .;
    else
        open "$@";
    fi;
}

vs() {
    if [ $# -eq 0 ]; then
        code .;
    else
        code "$@";
    fi;
}

# php test functions
# https://freek.dev/2142-a-bash-function-to-run-tests-for-both-phpunit-and-pest
function p() {
    if [ -f vendor/bin/pest ]; then
        vendor/bin/pest "$@"
    else
        vendor/bin/phpunit "$@"
    fi
}

function pf() {
    if [ -f vendor/bin/pest ]; then
        vendor/bin/pest --filter "$@"
    else
        vendor/bin/phpunit --filter "$@"
    fi
}

# Get macOS Software Updates, and update installed Ruby gems, Homebrew, npm, and their installed packages
alias update='sudo softwareupdate -i -a; brew update; brew upgrade; brew cleanup; sudo npm install npm -g; sudo npm update -g; composer global update;'
# Clean up LaunchServices to remove duplicates in the “Open With” menu
alias lscleanup="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"
# PlistBuddy alias, because sometimes `defaults` just doesn’t cut it
alias plistbuddy="/usr/libexec/PlistBuddy"

alias path='echo -e ${PATH//:/\\n}'

# Directories
alias dotfiles="cd $DOTFILES"
alias library="cd $HOME/Library"
alias bb="cd $HOME/BeepBoop"
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"

# Laravel
alias a="php artisan"
alias fresh="php artisan migrate:fresh --seed"
alias seed="php artisan db:seed"
alias tinker="php artisan tinker"
alias larastan="vendor/bin/phpstan analyse"
alias pest="php artisan test"
alias pestp="php artisan test --parallel"

# PHP
alias cfresh="rm -rf vendor/ composer.lock && composer i"
alias composer="php -d memory_limit=-1 $(brew --prefix)/bin/composer"
alias cda="composer dump-autoload -o"

# JS
alias nfresh="rm -rf node_modules/ package-lock.json && npm install"
alias yfresh="rm -rf node_modules/ yarn.lock && yarn"
alias watch="npm run watch"

# Git
alias g="git"
alias gst="git status"
alias gb="git branch"
alias gc="git checkout"
alias gl="git log --oneline --decorate --color"
alias amend="git add . && git commit --amend --no-edit"
alias commit="git add . && git commit -m"
alias diff="git diff"
alias force="git push --force"
alias nuke="git clean -df && git reset --hard"
alias pop="git stash pop"
alias pull="git pull"
alias push="git push"
alias resolve="git add . && git commit --no-edit"
alias stash="git stash -u"
alias unstage="git restore --staged ."
alias wip="commit wip"

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"
