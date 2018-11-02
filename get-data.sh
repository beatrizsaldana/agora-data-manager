#!/bin/bash
set -ex

CURRENT_DIR=$(pwd)
PARENT_DIR="$(dirname "$CURRENT_DIR")"
DATA_DIR=$CURRENT_DIR/data
TEAM_IMAGES_DIR=$DATA_DIR/team_images

# get package.json file from agora repo
wget https://raw.githubusercontent.com/Sage-Bionetworks/Agora/$TRAVIS_BRANCH/package.json -o $CURRENT_DIR/package-$TRAVIS_BRANCH.json

# Version key/value should be on his own line
DATA_VERSION=$(cat $CURRENT_DIR/package-$TRAVIS_BRANCH.json | grep data-version | head -1 | awk -F: '{ print $2 }' | sed 's/[",]//g' | tr -d '[[:space:]]')
echo "package-$TRAVIS_BRANCH.json DATA_VERSION=$DATA_VERSION"

[ -d $DATA_DIR/ ] || mkdir $DATA_DIR/
synapse -u $SYNAPSE_USERNAME -p $SYNAPSE_PASSWORD cat --version $DATA_VERSION syn13363290 | tail -n +2 | while IFS=, read -r id version; do
  synapse -u $SYNAPSE_USERNAME -p $SYNAPSE_PASSWORD get --downloadLocation $DATA_DIR -v $version $id ;
done

[ -d $TEAM_IMAGES_DIR/ ] || mkdir $TEAM_IMAGES_DIR/
synapse -u $SYNAPSE_USERNAME -p $SYNAPSE_PASSWORD get -r --downloadLocation $TEAM_IMAGES_DIR/ syn12861877
