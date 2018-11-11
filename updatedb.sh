# This script gets data from synapse then imports the data to an agora DB.
# This script needs to be run from an agora bastian machine, it assumes that
# the bastian is already setup with mongoimport and mongofiles tools
#!/bin/bash
set -ex

# double interpolate vars from travis
eval export "DB_HOST=\$DB_HOST_$TRAVIS_BRANCH"
eval export "DB_USER=\$DB_USER_$TRAVIS_BRANCH"
eval export "DB_PASS=\$DB_PASS_$TRAVIS_BRANCH"

ssh -i ~/.ssh/toptal_org-sagebase-scicomp.pem ec2-user@$BASTIAN_HOST rm -rf /tmp/work
ssh -i ~/.ssh/toptal_org-sagebase-scicomp.pem ec2-user@$BASTIAN_HOST mkdir -p /tmp/work/data/team_images

scp -i ~/.ssh/toptal_org-sagebase-scicomp.pem import-data.sh ec2-user@$BASTIAN_HOST:/tmp/work/.

ssh -i ~/.ssh/toptal_org-sagebase-scicomp.pem ec2-user@$BASTIAN_HOST bash /tmp/work/import-data.sh $TRAVIS_BRANCH $SYNAPSE_USERNAME $SYNAPSE_PASSWORD $DB_HOST $DB_USER $DB_PASS
