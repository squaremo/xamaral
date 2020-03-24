# xamaral

This repo contains terraform and k8s manifests for provisioning and deploying
to a GKE k8s structure. 

For the time being it's just an experimental personal project, and contains
things that I want to experiment with from time to time.

## Terraform

The terraform config is fairly minimal and does little more than provision a
GKE k8s cluster.

## K8S

The bulk of the code is jsonnet to generate k8s manifests.


## Secrets handling.

One of the challenges for publicly accessible code bases is dealing with
secrets. Even when code is not publicly accessible it's best practice
not to commit raw secrets to your version control. I'd welcome any observations
about problems with the setup described below.

Every necessary to recreate the complete system is contained in this repo, and
this includes secrets.

Raw secrets use [git-crypt](https://github.com/AGWA/git-crypt) to ensure that
secrets are only accessible as I intend to permit. To this end 
