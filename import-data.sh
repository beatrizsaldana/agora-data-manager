# This script imports db data from a bastian host.  It assumes that the bastian
# is already setup with mongoimport and mongofiles tools
#!/bin/bash
set -ex

CURRENT_DIR=$(pwd)
PARENT_DIR="$(dirname "$CURRENT_DIR")"
DATA_DIR=$CURRENT_DIR/data
REMOTE_DATA_DIR=data_$TRAVIS_BRANCH

# copy data to bastian machine
scp -i ./toptal_org-sagebase-scicomp.pem -r $DATA_DIR ec2-user@$BASTIAN_HOST:~/$REMOTE_DATA_DIR

# Imports the data and wipes the current collections from the bastian
# Not using --mode upsert fow now because we don't have unique indexes properly set for the collections
ssh -i ./toptal_org-sagebase-scicomp.pem ec2-user@$BASTIAN_HOST mongoimport -h DB_HOST_$TRAVIS_BRANCH -d agora -u DB_USER_$TRAVIS_BRANCH -p DB_PASS_$TRAVIS_BRANCH --collection genes --jsonArray --drop --file $REMOTE_DATA_DIR/rnaseq_differential_expression.json
ssh -i ./toptal_org-sagebase-scicomp.pem ec2-user@$BASTIAN_HOST mongoimport -h DB_HOST_$TRAVIS_BRANCH -d agora -u DB_USER_$TRAVIS_BRANCH -p DB_PASS_$TRAVIS_BRANCH --collection geneslinks --jsonArray --drop --file $REMOTE_DATA_DIR/network.json
ssh -i ./toptal_org-sagebase-scicomp.pem ec2-user@$BASTIAN_HOST mongoimport -h DB_HOST_$TRAVIS_BRANCH -d agora -u DB_USER_$TRAVIS_BRANCH -p DB_PASS_$TRAVIS_BRANCH --collection geneinfo --jsonArray --drop --file $REMOTE_DATA_DIR/gene_info.json
ssh -i ./toptal_org-sagebase-scicomp.pem ec2-user@$BASTIAN_HOST mongoimport -h DB_HOST_$TRAVIS_BRANCH -d agora -u DB_USER_$TRAVIS_BRANCH -p DB_PASS_$TRAVIS_BRANCH --collection teaminfo --jsonArray --drop --file $REMOTE_DATA_DIR/team_info.json

pushd $CURRENT_DIR/data/team_images
ls -1r *.jpg | while read x; do ssh -i ./toptal_org-sagebase-scicomp.pem ec2-user@$BASTIAN_HOST mongofiles -h DB_HOST_$TRAVIS_BRANCH -d agora -u DB_USER_$TRAVIS_BRANCH -p DB_PASS_$TRAVIS_BRANCH -v put $x --replace; echo $x; done
popd
