GIT_SHA := $(shell git rev-parse --short HEAD)

sealed-secrets.json: secrets.jsonnet secrets.json
	jsonnet -e "(import 'secrets.jsonnet').global_secret"|kubeseal --cert kubeseal-public-cert.pem -o json > sealed-secrets.json

show: sealed-secrets.json
	kubecfg show -V git_sha=$(GIT_SHA) all.jsonnet

update: sealed-secrets.json
	kubecfg update -V git_sha=$(GIT_SHA) --ignore-unknown all.jsonnet

diff:
	kubecfg diff --diff-strategy=subset -V git_sha=$(GIT_SHA) all.jsonnet


JS_FILES := $(wildcard *.jsonnet)

fmt: $(JS_FILES:%=%-fmt)
fmttest: $(JS_FILES:%=%-fmttest)

%-fmt: %
	jsonnetfmt -i -- $<

%-fmttest: %
	jsonnetfmt --test $<

.PHONY: show update diff %-fmt %-fmttest fmt fmttest
