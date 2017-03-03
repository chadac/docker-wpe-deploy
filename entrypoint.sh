#!/bin/bash

set -e

################################################################
## Based on https://github.com/joshleecreates/wpengine-deploy-script
################################################################


## Copy stuff to prevent side effects
echo "Copying to backup directory..."
cp -r original copy
cd copy/


## Generate unique branch/remote to avoid issues with original repo
WPE_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
WPE_BRANCH=wpengine-$WPE_KEY


## Assign SSH keys
# echo "Assigning SSH keys..."
# mkdir -p ~/.ssh
# if [[ ! -z "$SSH_PRIVATE_KEY" ]]; then
#     echo " Assigning SSH private key..."
#     echo $SSH_PRIVATE_KEY > ~/.ssh/id_rsa
# fi
# if [[ ! -z "$SSH_PUBLIC_KEY" ]]; then
#     echo " Assigning SSH public key..."
#     echo $SSH_PUBLIC_KEY > ~/.ssh/id_rsa.pub
# fi
# chmod 700 ~/.ssh/id_rsa
# chmod 700 ~/.ssh/id_rsa.pub

## Adding the keys via ssh agent
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
git commit -am "WPEngine build at `date`." --quiet


## Push to WPEngine
echo "Pushing to WPEngine..."
git push $WPE_REMOTE $WPE_BRANCH:master --force


echo "Successfully deployed."
