local base = import '../base/all.jsonnet';

local dev_tls_mixin = import './tls/dev_tls_mixin.jsonnet';

// use the microk8s provisioned controller - seems to play nice with dns lookups
local disable_ic_mixin = {
  ingress_controller:: null,
};

// we don't want to pull the static web image, as we import it to the microk8s registry

local do_not_pull_mixin = {
  static_site+: {deploy+: {spec+: {template+: {spec+: {containers_+: {nginx+: {imagePullPolicy: "Never"}
  }}}}}}
};


// base eck has the gcs plugin. TODO: refactor it out to a separate prod env.


local no_gcs = {
  globals +:{
    k+: {
      mixins+: {
        GcsPlugin: {},
      },
    },
  },
};

/* in gks we can already pull from gcr, but we need to use image pull secrets
to enable this in other clusters, it actually doesn't hurt to add the secret to
things that don't need it, and it's easier than figuring out exactly which do
 */

local gcr_secret = import 'imagepullsecrets.sealed.json';

local ipr_mixin = {
  // mixin for a deployment or similar
  spec+: {
    template+: {
      spec+: {
        imagePullSecrets+: [{
          name: gcr_secret.metadata.name,
        }],
      },
    },
  },
};


local k8s_obj(o) = std.isObject(o) && 'kind' in o;

local target_dep(o) = 
  k8s_obj(o) && o.kind == 'Deployment';

local walk_objs(o) = (
  if target_dep(o) then
    o + ipr_mixin
  else if k8s_obj(o) then o
  else if std.isObject(o) then {
    [k]: walk_objs(o[k])
    for k in std.objectFields(o)
  }
  else if std.isArray(o) then [
    walk_objs(e) for e in o
  ]
  else o
);

local config = (
  base + no_gcs +
  //do_not_pull_mixin +
  disable_ic_mixin + dev_tls_mixin
);

walk_objs(config)
+ {gcr_secret: gcr_secret, global_secret: import 'globalsecrets.sealed.json'}
