local base = import '../base/all.jsonnet';

local dev_tls_mixin = import './tls/dev_tls_mixin.jsonnet';

// use the microk8s provisioned controller - seems to play nice with dns lookups
local disable_ic_mixin = {
  ingress_controller:: null,
};

// we don't want to pull the static web image, as we import it to the microk8s registry

local do_not_pull_mixin = {
  static_site+: {deploy+: {spec+: {template+: {spec+: {containers_+: {nginx+: {imagePullPolicy: "Never"}}}}}}}
};


// base eck has the gcs plugin. TODO: refactor it out to a separate prod env.


local no_gcs = {
  mixins+: {
    GcsPlugin: {},
  }
};

base + no_gcs + do_not_pull_mixin + disable_ic_mixin + dev_tls_mixin
