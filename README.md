# Overview
Agora Data Manager is a tool that loads the JSON files into Agora's document database instances in our AWS environments.

# Purpose
This project allows Agora maintainers to update the Agora database with
new versions of gene data from Synapse.  This is a manually triggered,
self-service update. 

# Execution

![alt text][db_update]

# Worflow

To deploy an updated data version to the Agora development database
1. Increment `data-version` in `data-manifest.json` on the `develop` branch.
2. Commit the change
3. The [CI system](https://travis-ci.org/Sage-Bionetworks/agora-data-manager) automatically updates the dev DB


To deploy an updated data version to the Agora staging database:
1. Merge the data-version update from the dev branch to the staging branch.
2. The [CI system](https://travis-ci.org/Sage-Bionetworks/agora-data-manager) automatically updates the staging DB

To deploy an updated data version to the Agora production database:
1. Merge the data-version update from the staging branch to the production branch.
2. The [CI system](https://travis-ci.org/Sage-Bionetworks/agora-data-manager) automatically updates the production DB


# Setup

The following environment variables need to be setup for the scripts to deploy database updates:

| Variable             | Description                       | Example                                                                   |
|----------------------|-----------------------------------|---------------------------------------------------------------------------|
| BASTIAN_HOST_develop | The bastian host                  | ec2-10-11-12-13.compute-1.amazonaws.com                                   |
| DB_HOST_develop      | The database host                 | dbcluster-mr0a782pfjnk.cluster-ctcayu3de2lt.us-east-1.docdb.amazonaws.com |
| DB_USER_develop      | The database user                 | dbuser                                                                    |
| DB_PASS_develop      | The database password             | supersecret                                                               |
| SYNAPSE_USERNAME     | The Synapse service user          | syn-service-user                                                          |
| SYNAPSE_PASSWORD     | The Synapse service user password | supersecret                                                               |

__Note__: The variables containing `_develop` postfix corresponds to the branch.
To deploy to a prod environment a prod branch is require along with a variable
containing a `_prod` prefix (i.e. BASTIAN_HOST_prod)


[db_update]: diagram1.png "update diagram"
