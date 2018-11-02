#!/bin/bash
set -ex

CURRENT_DIR=$(pwd)
PARENT_DIR="$(dirname "$CURRENT_DIR")"
DATA_DIR=$CURRENT_DIR/data
REMOTE_DATA_DIR=data_$TRAVIS_BRANCH

# copy data to bastian machine
scp -i ./deploy_key -r $DATA_DIR ec2-user@$BASTIAN_HOST:~/$REMOTE_DATA_DIR

# Imports the data and wipes the current collections
# Not using --mode upsert fow now because we don't have unique indexes properly set for the collections
ssh -i ./deploy_key ec2-user@$BASTIAN_HOST mongoimport --db db_host_$TRAVIS_BRANCH --collection genes --jsonArray --drop --file $REMOTE_DATA_DIR/rnaseq_differential_expression.json
ssh -i ./deploy_key ec2-user@$BASTIAN_HOST mongoimport --db db_host_$TRAVIS_BRANCH --collection geneslinks --jsonArray --drop --file $REMOTE_DATA_DIR/network.json
ssh -i ./deploy_key ec2-user@$BASTIAN_HOST mongoimport --db db_host_$TRAVIS_BRANCH --collection geneinfo --jsonArray --drop --file $REMOTE_DATA_DIR/gene_info.json
ssh -i ./deploy_key ec2-user@$BASTIAN_HOST mongoimport --db db_host_$TRAVIS_BRANCH --collection teaminfo --jsonArray --drop --file $REMOTE_DATA_DIR/team_info.json

pushd $CURRENT_DIR/data/team_images
ls -1r *.jpg | while read x; do ssh -i ./deploy_key ec2-user@$BASTIAN_HOST mongofiles -d db_host_$TRAVIS_BRANCH -v put $x --replace; echo $x; done
popd
