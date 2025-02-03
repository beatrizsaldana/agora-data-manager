# This script gets data from synapse then imports the data to an agora DB.
# This script needs to be run from an agora bastian machine, it assumes that
# the bastian is already setup with synapse, mongoimport and mongofiles
# command line clients
#!/bin/bash
set -e

BRANCH=$1
SYNAPSE_PASSWORD=$2
DB_HOST=$3
DB_USER=$4
DB_PASS=$5

CURRENT_DIR=$(pwd)
WORKING_DIR=$CURRENT_DIR
DATA_DIR=$WORKING_DIR/data
TEAM_IMAGES_DIR=$DATA_DIR/team_images

mkdir -p $TEAM_IMAGES_DIR

# Version key/value should be on his own line
DATA_VERSION=$(cat $WORKING_DIR/data-manifest.json | grep data_version | head -1 | awk -F: '{ print $2 }' | sed 's/[",]//g' | tr -d '[[:space:]]')
DATA_MANIFEST_ID=$(cat $WORKING_DIR/data-manifest.json | grep data_manifest_id | head -1 | awk -F: '{ print $2 }' | sed 's/[",]//g' | tr -d '[[:space:]]')
TEAM_IMAGES_ID=$(cat $WORKING_DIR/data-manifest.json | grep team_images_id | head -1 | awk -F: '{ print $2 }' | sed 's/[",]//g' | tr -d '[[:space:]]')
echo "$BRANCH branch, DATA_VERSION = $DATA_VERSION, manifest id = $DATA_MANIFEST_ID"

# Download the manifest file from synapse
synapse -p $SYNAPSE_PASSWORD get --downloadLocation $DATA_DIR -v $DATA_VERSION $DATA_MANIFEST_ID

# Ensure there's a newline at the end of the manifest file; otherwise the last listed file will not be downloaded
# echo >> $DATA_DIR/data_manifest.csv

# Download all files referenced in the manifest from synapse
cat $DATA_DIR/data_manifest.csv | tail -n +2 | while IFS=, read -r id version; do
  echo Downloading $id,$version
    synapse -p $SYNAPSE_PASSWORD get --downloadLocation $DATA_DIR -v $version $id ;
  done

# Download team images
synapse -p $SYNAPSE_PASSWORD get -r --downloadLocation $TEAM_IMAGES_DIR/ $TEAM_IMAGES_ID

echo "Data Files: "
ls -al $WORKING_DIR
ls -al $DATA_DIR
ls -al $TEAM_IMAGES_DIR

# Check if dataversion exists and handle different data format
DATAVERSION_PATH="${DATA_DIR}/dataversion.json"
DATAVERSION_FLAG="--jsonArray"
if [ ! -f "${DATAVERSION_PATH}" ]; then
  DATAVERSION_PATH="${WORKING_DIR}/data-manifest.json"
  DATAVERSION_FLAG=""
fi

# Import synapse data to database
# Not using --mode upsert for now because we don't have unique indexes properly set for the collections

mongoimport -h $DB_HOST -d agora -u $DB_USER -p $DB_PASS --authenticationDatabase admin --collection genes --jsonArray --drop --file $DATA_DIR/rnaseq_differential_expression.json
mongoimport -h $DB_HOST -d agora -u $DB_USER -p $DB_PASS --authenticationDatabase admin --collection geneslinks --jsonArray --drop --file $DATA_DIR/network.json
mongoimport -h $DB_HOST -d agora -u $DB_USER -p $DB_PASS --authenticationDatabase admin --collection geneinfo --jsonArray --drop --file $DATA_DIR/gene_info.json
mongoimport -h $DB_HOST -d agora -u $DB_USER -p $DB_PASS --authenticationDatabase admin --collection teaminfo --jsonArray --drop --file $DATA_DIR/team_info.json
mongoimport -h $DB_HOST -d agora -u $DB_USER -p $DB_PASS --authenticationDatabase admin --collection genesproteomics --jsonArray --drop --file $DATA_DIR/proteomics.json
mongoimport -h $DB_HOST -d agora -u $DB_USER -p $DB_PASS --authenticationDatabase admin --collection genesmetabolomics --jsonArray --drop --file $DATA_DIR/metabolomics.json
mongoimport -h $DB_HOST -d agora -u $DB_USER -p $DB_PASS --authenticationDatabase admin --collection genesneuropathcorr --jsonArray --drop --file $DATA_DIR/neuropath_corr.json
mongoimport -h $DB_HOST -d agora -u $DB_USER -p $DB_PASS --authenticationDatabase admin --collection geneexpvalidation --jsonArray --drop --file $DATA_DIR/target_exp_validation_harmonized.json
mongoimport -h $DB_HOST -d agora -u $DB_USER -p $DB_PASS --authenticationDatabase admin --collection genescoredistribution --jsonArray --drop --file $DATA_DIR/distribution_data.json
mongoimport -h $DB_HOST -d agora -u $DB_USER -p $DB_PASS --authenticationDatabase admin --collection genesoverallscores --jsonArray --drop --file $DATA_DIR/overall_scores.json
mongoimport -h $DB_HOST -d agora -u $DB_USER -p $DB_PASS --authenticationDatabase admin --collection rnaboxdistribution --jsonArray --drop --file $DATA_DIR/rna_distribution_data.json
mongoimport -h $DB_HOST -d agora -u $DB_USER -p $DB_PASS --authenticationDatabase admin --collection proteomicsboxdistribution --jsonArray --drop --file $DATA_DIR/proteomics_distribution_data.json
mongoimport -h $DB_HOST -d agora -u $DB_USER -p $DB_PASS --authenticationDatabase admin --collection proteomicstmt --jsonArray --drop --file $DATA_DIR/proteomics_tmt.json
mongoimport -h $DB_HOST -d agora -u $DB_USER -p $DB_PASS --authenticationDatabase admin --collection proteomicssrm --jsonArray --drop --file $DATA_DIR/proteomics_srm.json
mongoimport -h $DB_HOST -d agora -u $DB_USER -p $DB_PASS --authenticationDatabase admin --collection genesbiodomains --jsonArray --drop --file $DATA_DIR/genes_biodomains.json
mongoimport -h $DB_HOST -d agora -u $DB_USER -p $DB_PASS --authenticationDatabase admin --collection biodomaininfo --jsonArray --drop --file $DATA_DIR/biodomain_info.json

echo "Importing dataversion from ${DATAVERSION_PATH}"
mongoimport -h $DB_HOST -d agora -u $DB_USER -p $DB_PASS --authenticationDatabase admin --collection dataversion $DATAVERSION_FLAG --drop --file $DATAVERSION_PATH

mongosh --host $DB_HOST -u $DB_USER -p $DB_PASS --authenticationDatabase admin $WORKING_DIR/create-indexes.js

pushd $TEAM_IMAGES_DIR
ls -1r *.{jpg,jpeg,png} | while read x; do mongofiles -h $DB_HOST -d agora -u $DB_USER -p $DB_PASS --authenticationDatabase $DB_USER -v put $x; echo $x; done
popd
