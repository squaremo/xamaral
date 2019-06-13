
STATIC_IMAGE := eu.gcr.io/xamaral/static-web:$(shell git rev-parse --short HEAD)

show:
	kubecfg show -V static-image=$(STATIC_IMAGE) all.jsonnet

update:
	kubecfg update -V static-image=$(STATIC_IMAGE) --ignore-unknown all.jsonnet

diff:
	kubecfg diff -V static-image=$(STATIC_IMAGE) all.jsonnet

.PHONY: show update diff
