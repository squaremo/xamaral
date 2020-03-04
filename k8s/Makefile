.ONESHELL:

mkfile_dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

kdir := ./envs/$(env)/

KUBECFG := kubecfg -J $(mkfile_dir)
JSONNET := jsonnet -J $(mkfile_dir)


$(kdir)sealed-secrets.json: $(kdir)secrets.jsonnet $(kdir)secrets.json
	cd $(kdir)
	$(JSONNET) -e "(import 'secrets.jsonnet').global_secret"|kubeseal --cert kubeseal-public-cert.pem -o json > sealed-secrets.json

show:
	cd $(kdir)
	$(KUBECFG) show all.jsonnet

update:
	cd $(kdir)
	$(KUBECFG) update --ignore-unknown all.jsonnet

diff:
	cd $(kdir)
	$(KUBECFG) diff --diff-strategy=subset all.jsonnet


JS_FILES := $(wildcard *.jsonnet)

fmt: $(JS_FILES:%=%-fmt)
fmttest: $(JS_FILES:%=%-fmttest)

%-fmt: %
	jsonnetfmt -i -- $<

%-fmttest: %
	jsonnetfmt --test $<

.PHONY: show update diff %-fmt %-fmttest fmt fmttest
