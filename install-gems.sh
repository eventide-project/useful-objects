#!/usr/bin/env bash

echo "Removing gems directory..."
rm -rf gems
echo "Removing .bundle directory..."
rm -rf .bundle
echo "Removing Gemfile.lock file..."
rm -f Gemfile.lock
echo

echo "Installing gems to ./gems"
echo '= = ='

cmd="bundle install --standalone --path=./gems"

echo $cmd
($cmd)

echo '- - -'
echo '(done)'
echo
