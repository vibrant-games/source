#!/bin/sh

echo ""
echo "Installing tools requirements..."
echo ""

#
# YAML-to-HTML conversion:
#
echo "  Mustache:"
sudo gem install mustache \
    || exit 1

#
# YAML, XML querying and validating:
#
echo "  Dasel:"
brew install dasel \
    || exit 2

echo ""
echo "SUCCESS installing tools requirements"
echo ""

exit 0
