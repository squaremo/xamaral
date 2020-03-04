kdir := ./envs/$(env)/


$(kdir)sealed-secrets.json: $(kdir)secrets.jsonnet $(kdir)/secrets.json
	jsonnet -e "(import 'secrets.jsonnet').global_secret"|kubeseal --cert kubeseal-public-cert.pem -o json > sealed-secrets.json

show: $(kdir)sealed-secrets.json
	cd $(kdir)
	kubecfg show all.jsonnet

update: $(kdir)sealed-secrets.json
	cd $(kdir)
	kubecfg update --ignore-unknown all.jsonnet

diff:
	cd $(kdir)
	kubecfg diff --diff-strategy=subset all.jsonnet


JS_FILES := $(wildcard *.jsonnet)

fmt: $(JS_FILES:%=%-fmt)
fmttest: $(JS_FILES:%=%-fmttest)

%-fmt: %
	jsonnetfmt -i -- $<

%-fmttest: %
	jsonnetfmt --test $<

.PHONY: show update diff %-fmt %-fmttest fmt fmttest
