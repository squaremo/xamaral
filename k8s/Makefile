.ONESHELL:

mkfile_dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

# Since the environment potentially import from others, any one potentially
# depends on all jsonnet files
JSFILES := $(shell find . -type f -iname "*.jsonnet")

GENDIR := gen

ENVFILES := $(shell find . -type f -iname "all.jsonnet")

prod: gen/prod/all.yaml

gen/prod/all.yaml: envs/prod/all.jsonnet $(JSFILES)
	kubecfg -V "env=prod" -J $(mkfile_dir) show $< --context prod > $@
	sed -i -f sed.txt $@


fmttest: $(JS_FILES:%=%-fmttest)

%-fmt: %
	jsonnetfmt -i -- $<

%-fmttest: %
	jsonnetfmt --test $<

.PHONY: prod %-fmt %-fmttest fmt fmttest
