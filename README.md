# Overview
Tool to manage agora data

# Purpose
This project allows Agora maintainers to update the Agora database with
new versions of gene data from Synapse.  This is a, manually triggered,
self service update. 

# Execution

![alt text][db_update]

# Worflow

To deploy an updated data version to the Agora development database
1. Increment `data-version` in `data-manifest.json` on the `develop` branch.
2. Commit the change
3. The [CI system](https://travis-ci.org/Sage-Bionetworks/agora-data-manager) automatically updates the new version to the DB


To deploy an updated data version to the staging and prod database.
1. Merge data-version update to staging and prod branches.


[db_update]: diagram1.png "update diagram"
