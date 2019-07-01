#!/bin/bash

CONFIG="`cat config.json`"
# PROJECTS=$(jq 'keys' config.json)
PROJECTS=$(echo $CONFIG | jq 'keys')

echo "Projects: ${PROJECTS}"

# nanobox start

while true
do
for PROJECT in $PROJECTS
do
if [ $PROJECT != '{' ] && [ $PROJECT != '}' ]
then
    PROJECT_NAME=$(echo $PROJECT | sed 's/^"\(.*\)".*/\1/')
    # PROJECT_PATH=$(jq '.["'$PROJECT_NAME'"]' config.json)
    PROJECT_PATH=$(echo $CONFIG | jq '.["'$PROJECT_NAME'"]')
    PROJECT_PATH=$(echo $PROJECT_PATH | sed 's/^"\(.*\)".*/\1/')
    echo \n"Folder name: $PROJECT_PATH"
    cd $PROJECT_PATH

    UPSTREAM=${1:-'@{u}'}
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse "$UPSTREAM")
    BASE=$(git merge-base @ "$UPSTREAM")
    BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

    if [ $LOCAL = $REMOTE ]; then
        echo "Branch $BRANCH_NAME up to date"
    elif [ $LOCAL = $BASE ]; then
        echo "Need to pull $BRANCH_NAME"
        git pull origin
        if /usr/bin/git pull; then
            nanobox deploy $PROJECT_NAME

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
sleep 30
done
