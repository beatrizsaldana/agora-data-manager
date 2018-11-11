# Update agora db from a build machine by running an import script
# on a bastian host
#!/bin/bash
set -e

# double interpolate vars from travis
eval export "DB_HOST=\$DB_HOST_$TRAVIS_BRANCH"
eval export "DB_USER=\$DB_USER_$TRAVIS_BRANCH"
eval export "DB_PASS=\$DB_PASS_$TRAVIS_BRANCH"

ssh -i ~/.ssh/toptal_org-sagebase-scicomp.pem ec2-user@$BASTIAN_HOST "rm -rf /tmp/work"

ssh -i ~/.ssh/toptal_org-sagebase-scicomp.pem ec2-user@$BASTIAN_HOST "mkdir -p /tmp/work/data/team_images"

scp -i ~/.ssh/toptal_org-sagebase-scicomp.pem import-data.sh ec2-user@$BASTIAN_HOST:/tmp/work/.

# Escape chars in vars
q_mid=\'\\\'\'
SYNAPSE_USERNAME_ESC="'${SYNAPSE_USERNAME//\'/$q_mid}'"
SYNAPSE_PASSWORD_ESC="'${SYNAPSE_PASSWORD//\'/$q_mid}'"
DB_USER_ESC="'${DB_USER//\'/$q_mid}'"
DB_PASS_ESC="'${DB_PASS//\'/$q_mid}'"

# run import on bastian
ssh -i ~/.ssh/toptal_org-sagebase-scicomp.pem ec2-user@$BASTIAN_HOST "bash /tmp/work/import-data.sh $TRAVIS_BRANCH $SYNAPSE_USERNAME_ESC $SYNAPSE_PASSWORD_ESC $DB_HOST $DB_USER_ESC $DB_PASS_ESC"
