GIT_SHA := $(shell git rev-parse --short HEAD)
show:
	kubecfg show -V git_sha=$(GIT_SHA) all.jsonnet

update:
	kubecfg update -V git_sha=$(GIT_SHA) --ignore-unknown all.jsonnet

diff:
	kubecfg diff -V git_sha=$(GIT_SHA) all.jsonnet

.PHONY: show update diff
