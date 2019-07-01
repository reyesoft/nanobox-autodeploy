#!/bin/bash

FOLDERS=$(jq '.project_folders' config.json)
echo "Folders name: ${FOLDERS}"

read -sp 'SUDO Password: ' PASSWORD

while true
do
for FOLDER in $FOLDERS
do
if [ $FOLDER != '[' ] && [ $FOLDER != ']' ]
then
    FOLDER_NAME=$(echo $FOLDER | sed 's/^"\(.*\)".*/\1/')
    echo "Folder name: $FOLDER_NAME"
    cd $FOLDER_NAME

    git fetch

    UPSTREAM=${1:-'@{u}'}
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse "$UPSTREAM")
    BASE=$(git merge-base @ "$UPSTREAM")

    if [ $LOCAL = $REMOTE ]; then
        BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
        echo "Branch $BRANCH_NAME up to date"
    elif [ $LOCAL = $BASE ]; then
        BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
        echo "Need to pull $BRANCH_NAME"
        git pull origin
        if /usr/bin/git pull; then
            printf PASSWORD | nanobox deploy $BRANCH_NAME
        else
            echo "WARNING: Failed to pull data form remote repository!"
        fi
    elif [ $REMOTE = $BASE ]; then
        echo "Need to push"
    else
        echo "Diverged"
    fi
fi
done
sleep 5
done
