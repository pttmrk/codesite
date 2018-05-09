#!/bin/bash

# bash script for deploying hugo site to github pages.

# I have a two branch develop and master.
# develop branch keeps source files of my blog
# master branch keeps generated website files
# If you have unstaged or not tracked files, script adds these files to stash.
# So you unstash these changes after deploy.

if [[ $(git diff --name-only) ]]; then
    echo 'Commit or stash changes before deploy.'
    echo 'Untracked files will be stash automatically.'
    exit 1
fi

_untracked_files_exist=0
if [[ $(git ls-files -o --exclude-standard) ]]; then
    # stash all untracked files if exist
    git stash save -u
    _untracked_files_exist=1
fi

# Generate site
hugo -d public

# move generated files to /tmp
rm -rf /tmp/public
mv public /tmp

git checkout master

# Remove all files in master branch
rm -rf `pwd`/*

# Move all generated files from public directory to here
mv /tmp/public/* .
rm -r /tmp/public/

# Add new created files.
git add .
git commit -m 'Site updated'
git push

# Go back develop branch and pop changes from stash
git checkout -

# If stashed untracked files exist, pop them
if [[ $_untracked_files_exist -eq "1" ]]; then
    git stash pop
    git reset .
fi
