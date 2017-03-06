#!/bin/bash

set -e

################################################################
## Based on https://github.com/joshleecreates/wpengine-deploy-script
################################################################

## Copy stuff to prevent side effects
echo "Copying to backup directory..."
mkdir -p $HOME/wpe-deploy/
cp -r . $HOME/wpe-deploy/repo/
cd $HOME/wpe-deploy/repo/

## Generate unique branch/remote to avoid issues with original repo
WPE_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
WPE_BRANCH=wpengine-$WPE_KEY

if [[ ! -z "$WPE_REMOTE_URL" ]]; then
   WPE_REMOTE=wpengine-remote-$WPE_KEY
   git remote add $WPE_REMOTE $WPE_REMOTE_URL;
fi

## Assign private SSH key
eval $(ssh-agent -s)
ssh-add <(echo "$SSH_PRIVATE_KEY")
mkdir -p ~/.ssh


## Configure git
echo "Configuring git..."
git config --global user.email "gitlab-ci@utulsa.co"
git config --global user.name "GitLab CI"


## Push to WPEngine
echo "Preparing for WPEngine deploy..."
git checkout --orphan $WPE_BRANCH

## Recursively add .wpe-gitignore files into the .gitignore in that directory
echo "Recursively modifying gitignored files..."
echo -e "\n.wpe-gitignore" >> .gitignore
for i in $(find . -type f -name ".wpe-gitignore"); do
    echo -e "\n\n## WP ENGINE GITIGNORE" >> $(dirname $i)/.gitignore;
    cat $i >> $(dirname $i)/.gitignore;
    echo "" >> $(dirname $i)/.gitignore;
done


## Recursively delete submodules
echo "Removing submodules..."
for i in $(find ./*/ -type d -name ".git"); do
    rm -rf $i
done


## Track files
echo "Tracking all files..."
git rm -rf --cached . > /dev/null
git add -A
git commit -am "WPEngine build at `date`."


## Push to WPEngine
echo "Pushing to WPEngine..."
git push $WPE_REMOTE $WPE_BRANCH:master --force


echo "Successfully deployed."
