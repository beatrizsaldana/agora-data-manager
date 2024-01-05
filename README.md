# Overview
Agora Data Manager is a tool that loads the JSON files into Agora's document database
instances in our AWS environments.

# Purpose
This project allows Agora maintainers to update the Agora database with
new versions of gene data from Synapse.  This is a manually triggered,
self-service update.

# Execution

![alt text][db_update]

# Workflow

To deploy an updated data version to the Agora development database
1. Increment `data-version` in `data-manifest.json` on the `develop` branch.
2. Commit the change
3. The Github action CI system automatically updates the dev DB


To deploy an updated data version to the Agora staging database:
1. Merge the data-version update from the dev branch to the staging branch.
2. The Github action CI system automatically updates the dev DB

To deploy an updated data version to the Agora production database:
1. Merge the data-version update from the staging branch to the production branch.
2. The Github action CI system automatically updates the dev DB


# Setup

## Secrets

The following secrets need to be setup in Github for the scripts to deploy database updates:

Global secrets:

| Variable             | Description                       | Example                     |
|----------------------|-----------------------------------|-----------------------------|
| SYNAPSE_USERNAME     | The Synapse service user          | syn-service-user            |
| SYNAPSE_PASSWORD     | The Synapse service user password | supersecret                 |


Context specific secrets for each environment that corresponds to a git branch (develop/staging/prod):

| Variable  | Description                 | Example                                                                   |
|-----------|-----------------------------|---------------------------------------------------------------------------|
| DB_HOST   | The database host           | dbcluster-mr0a782pfjnk.cluster-ctcayu3de2lt.us-east-1.docdb.amazonaws.com |
| DB_USER   | The database user           | dbuser                                                                    |
| DB_PASS   | The database password       | supersecret                                                               |


![alt text][github_secrets]


## Self hosted runners

[agora2-infra] repository deploys a bastian host in AWS for each environment which have access to
the databases.  We manually configure a [Github self-hosted runner] for each bastian host,
a label is applied to each runner to match the corresponding deployment branch name (develop/staging/prod).
Each runner corresponds to an environment which corresponds to a git branch. The update is
executed from these runners.  When a push happens on a branch (i.e. develop), the update
is executed on the `agora-bastian-develop` runner which in turn updates the development database.


![alt text][self_hosted_runners]


[db_update]: agora-db-update.drawio.png "update diagram"
[github_secrets]: github_secrets.png "github secrets screen"
[self_hosted_runners]: self-hosted-runners.png "self hosted runners"
[agora2-infra]: https://github.com/Sage-Bionetworks/agora2-infra "agora2-infra repository"
[Github self-hosted runners]: https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/about-self-hosted-runners#about-self-hosted-runners
