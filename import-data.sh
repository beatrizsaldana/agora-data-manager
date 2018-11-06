# This script gets data from synapse then imports the data to an agora DB.
# This script needs to be run from an agora bastian machine, it assumes that
# the bastian is already setup with mongoimport and mongofiles tools
#!/bin/bash
set -ex

CURRENT_DIR=$(pwd)
PARENT_DIR="$(dirname "$CURRENT_DIR")"
DATA_DIR=$CURRENT_DIR/data
TEAM_IMAGES_DIR=$DATA_DIR/team_images
REMOTE_DATA_DIR=data_$TRAVIS_BRANCH

# get package.json file from agora repo
wget https://raw.githubusercontent.com/Sage-Bionetworks/Agora/$TRAVIS_BRANCH/package.json -O $CURRENT_DIR/package-$TRAVIS_BRANCH.json

# Version key/value should be on his own line
DATA_VERSION=$(cat $CURRENT_DIR/package-$TRAVIS_BRANCH.json | grep data-version | head -1 | awk -F: '{ print $2 }' | sed 's/[",]//g' | tr -d '[[:space:]]')
echo "package-$TRAVIS_BRANCH.json DATA_VERSION = $DATA_VERSION"

[ -d $DATA_DIR/ ] || mkdir $DATA_DIR/
synapse -u $SYNAPSE_USERNAME -p $SYNAPSE_PASSWORD cat --version $DATA_VERSION syn13363290 | tail -n +2 | while IFS=, read -r id version; do
  synapse -u $SYNAPSE_USERNAME -p $SYNAPSE_PASSWORD get --downloadLocation $DATA_DIR -v $version $id ;
done

[ -d $TEAM_IMAGES_DIR/ ] || mkdir $TEAM_IMAGES_DIR/
synapse -u $SYNAPSE_USERNAME -p $SYNAPSE_PASSWORD get -r --downloadLocation $TEAM_IMAGES_DIR/ syn12861877

# copy data to bastian machine
scp -i ~/.ssh/toptal_org-sagebase-scicomp.pem -r $DATA_DIR ec2-user@$BASTIAN_HOST:~/$REMOTE_DATA_DIR

# Imports the data and wipes the current collections.  All executed from the bastian host.
# Not using --mode upsert fow now because we don't have unique indexes properly set for the collections
ssh -i ~/.ssh/toptal_org-sagebase-scicomp.pem ec2-user@$BASTIAN_HOST mongoimport -h DB_HOST_$TRAVIS_BRANCH -d agora -u DB_USER_$TRAVIS_BRANCH -p DB_PASS_$TRAVIS_BRANCH --collection genes --jsonArray --drop --file $REMOTE_DATA_DIR/rnaseq_differential_expression.json
ssh -i ~/.ssh/toptal_org-sagebase-scicomp.pem ec2-user@$BASTIAN_HOST mongoimport -h DB_HOST_$TRAVIS_BRANCH -d agora -u DB_USER_$TRAVIS_BRANCH -p DB_PASS_$TRAVIS_BRANCH --collection geneslinks --jsonArray --drop --file $REMOTE_DATA_DIR/network.json
ssh -i ~/.ssh/toptal_org-sagebase-scicomp.pem ec2-user@$BASTIAN_HOST mongoimport -h DB_HOST_$TRAVIS_BRANCH -d agora -u DB_USER_$TRAVIS_BRANCH -p DB_PASS_$TRAVIS_BRANCH --collection geneinfo --jsonArray --drop --file $REMOTE_DATA_DIR/gene_info.json
ssh -i ~/.ssh/toptal_org-sagebase-scicomp.pem ec2-user@$BASTIAN_HOST mongoimport -h DB_HOST_$TRAVIS_BRANCH -d agora -u DB_USER_$TRAVIS_BRANCH -p DB_PASS_$TRAVIS_BRANCH --collection teaminfo --jsonArray --drop --file $REMOTE_DATA_DIR/team_info.json

# pushd $CURRENT_DIR/data/team_images
# ls -1r *.jpg | while read x; do ssh -i ~/.ssh/toptal_org-sagebase-scicomp.pem ec2-user@$BASTIAN_HOST mongofiles -h DB_HOST_$TRAVIS_BRANCH -d agora -u DB_USER_$TRAVIS_BRANCH -p DB_PASS_$TRAVIS_BRANCH -v put $x --replace; echo $x; done
# popd
