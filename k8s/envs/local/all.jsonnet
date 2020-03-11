local base = import '../base/all.jsonnet';

local dev_tls_mixin = import './tls/dev_tls_mixin.jsonnet';

// use the microk8s provisioned controller - seems to play nice with dns lookups
local disable_ic_mixin = {
  ingress_controller:: null,
};

base + disable_ic_mixin + dev_tls_mixin
