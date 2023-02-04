# Load Composer tools
export PATH="$HOME/.composer/vendor/bin:$PATH"

# Load Node global installed binaries
export PATH="$HOME/.node/bin:$PATH"

# Use project specific binaries before global ones
export PATH="node_modules/.bin:vendor/bin:$PATH"

# Make sure coreutils are loaded before system commands
# Disabled for now because the can be refered with g prefix like
# ls -> gls
# export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
export PATH="$(brew --prefix python)/libexec/bin:$PATH"
export PATH="/usr/local/opt/curl/bin:$PATH"

#Homebrew's "sbin"
export PATH="/usr/local/sbin:$PATH"

# pnpm
export PNPM_HOME="/Users/thierry/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"
# pnpm end