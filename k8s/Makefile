.ONESHELL:

mkfile_dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

kdir := ./envs/$(env)/
gendir := ./gen/$(env)/
JS_FILES := $(wildcard *.jsonnet)


$(gendir)all.yaml: $(JS_FILES)
	$(KUBECFG) show $(kdir)all.jsonnet > $@


KUBECFG := kubecfg -V "env=$(env)" -J $(mkfile_dir) --context $(env)
JSONNET := jsonnet -J $(mkfile_dir)

%secrets.sealed.json: %secrets.json
	$(JSONNET) --tla-code-file 'secrets=$<' utils/secrets.jsonnet|kubeseal --cert $(@D)/kubeseal-public-cert.pem -o json > $@

show:
	cd $(kdir)
	$(KUBECFG) show all.jsonnet

update:
	cd $(kdir)
	$(KUBECFG)  update  --ignore-unknown --validate=false all.jsonnet

diff:
	cd $(kdir)
	$(KUBECFG) diff --diff-strategy=subset all.jsonnet

delete:
	cd $(kdir)
	$(KUBECFG) delete all.jsonnet

fmt: $(JS_FILES:%=%-fmt)
fmttest: $(JS_FILES:%=%-fmttest)

%-fmt: %
	jsonnetfmt -i -- $<

%-fmttest: %
	jsonnetfmt --test $<

.PHONY: show update diff %-fmt %-fmttest fmt fmttest
