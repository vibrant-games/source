#!/bin/sh

echo "Setting up tools..."
sudo echo "You must have sudo permission to run this script."

sudo apt-get install -y curl git \
    || exit 1

# https://brew.sh/
echo "homebrew (for dasel):"
if test ! -d /home/linuxbrew
then
    echo "" | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
	|| exit 1
fi

if test -z "$HOMEBREW_BREW_FILE"
then
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bash_profile \
	|| exit 3
fi
sudo apt-get install -y build-essential \
    || exit 4
/home/linuxbrew/.linuxbrew/bin/brew install gcc \
    || exit 5

# https://daseldocs.tomwright.me/installation
echo "dasel:"
/home/linuxbrew/.linuxbrew/bin/brew install dasel \
    || exit 2

echo "ruby (for mustache):"
sudo apt-get install -y ruby \
    || exit 3

# https://linux.die.net/man/1/mustache
sudo gem install mustache \
    || exit 4

# wkhtmlktopdf for html -> pdf conversions
sudo apt-get install -y wkhtmltopdf zip \
    || exit 5

echo ""
echo "SUCCESS setting up tools."
echo ""
echo "*** IMPORTANY *** Update your environment: . ~/.bash_profile"
echo ""

exit 0
