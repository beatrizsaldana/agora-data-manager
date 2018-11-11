# This script gets data from synapse then imports the data to an agora DB.
# This script needs to be run from an agora bastian machine, it assumes that
# the bastian is already setup with synapse, mongoimport and mongofiles
# command line clients
#!/bin/bash
set -e

TRAVIS_BRANCH=$1
SYNAPSE_USERNAME=$2
SYNAPSE_PASSWORD=$3
DB_HOST=$4
DB_USER=$5
DB_PASS=$6

CURRENT_DIR=$(pwd)
PARENT_DIR="$(dirname "$CURRENT_DIR")"
TMP_DIR=/tmp
WORKING_DIR=$TMP_DIR/work
DATA_DIR=$WORKING_DIR/data
TEAM_IMAGES_DIR=$DATA_DIR/team_images

# get data version from agora repo
wget https://raw.githubusercontent.com/Sage-Bionetworks/Agora/$TRAVIS_BRANCH/package.json -O $WORKING_DIR/package-$TRAVIS_BRANCH.json

# Version key/value should be on his own line
DATA_VERSION=$(cat $WORKING_DIR/package-$TRAVIS_BRANCH.json | grep data-version | head -1 | awk -F: '{ print $2 }' | sed 's/[",]//g' | tr -d '[[:space:]]')
echo "package-$TRAVIS_BRANCH.json DATA_VERSION = $DATA_VERSION"

# get data from synapse
synapse -u $SYNAPSE_USERNAME -p $SYNAPSE_PASSWORD cat --version $DATA_VERSION syn13363290 | tail -n +2 | while IFS=, read -r id version; do
  synapse -u $SYNAPSE_USERNAME -p $SYNAPSE_PASSWORD get --downloadLocation $DATA_DIR -v $version $id ;
done

synapse -u $SYNAPSE_USERNAME -p $SYNAPSE_PASSWORD get -r --downloadLocation $TEAM_IMAGES_DIR/ syn12861877

echo "Data Files: "
ls -al $WORKING_DIR
ls -al $DATA_DIR
ls -al $TEAM_IMAGES_DIR

# Import synapse data to database
# Not using --mode upsert for now because we don't have unique indexes properly set for the collections
mongoimport -h $DB_HOST -d agora -u $DB_USER -p $DB_PASS --authenticationDatabase admin --collection genes --jsonArray --drop --file $DATA_DIR/rnaseq_differential_expression.json
mongoimport -h $DB_HOST -d agora -u $DB_USER -p $DB_PASS --authenticationDatabase admin --collection geneslinks --jsonArray --drop --file $DATA_DIR/network.json
mongoimport -h $DB_HOST -d agora -u $DB_USER -p $DB_PASS --authenticationDatabase admin --collection geneinfo --jsonArray --drop --file $DATA_DIR/gene_info.json
mongoimport -h $DB_HOST -d agora -u $DB_USER -p $DB_PASS --authenticationDatabase admin --collection teaminfo --jsonArray --drop --file $DATA_DIR/team_info.json

pushd $TEAM_IMAGES_DIR
ls -1r *.jpg | while read x; do mongofiles -h $DB_HOST -d agora -u $DB_USER -p $DB_PASS --authenticationDatabase admin -v put $x --replace; echo $x; done
popd
