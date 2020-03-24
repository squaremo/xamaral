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
secrets are only accessible as I intend to permit. Every file matching the
pattern *secrets.json is encrypted via git-crypt. This is fine in contexts
where it's safe to unlock the repo, such as developer machines. However suppose
we have a key that an application we're deploying to k8s needs to access an
external service. Here we can make use of [sealed
secrets](https://github.com/bitnami-labs/sealed-secrets) to generate secret
data that can be committed raw to git, because they are generated using a public
key for the sealed secrets controller, and hence can only be decrypted by the
sealed secrets controller.

Note the different roles played by git-crypt and sealed secrets. git-crypt is
used to encrypt secrets and those encrypted secrets are the authoritative of
their data. Tooling (see e.g. [this Makefile](./k8s/Makefile)) generates sealed
secrets from the raw secrets, these can be committed so that other consumers
have access to the secret data. In this case we're using
[flux](https://github.com/fluxcd/flux) to keep the running k8s config
consistent with the manifests defined by the code. Given this setup flux has no
need to be able to decrypt the git-crypt encrypted data, because flux just
applies the sealed secret data.


### Generated secrets.

Sometimes credentials are needed for secure communication between services
running within a k8s cluster, but are never needed outside of the cluster.
