local config = {
  livefpl: import './livefpl.jsonnet',
  
  bkpr: import './kubeprod-manifest.jsonnet',
  globals:: {
    images:: import 'images.jsonnet',
    root_dns_name:: 'xamaral.com',
    k:: import 'klib.libsonnet',
    env:: std.extVar("env"),
  },
};

config + {
  local s = self, 
  [k]: config[k] + {globals:: s.globals},
  for k in std.objectFields(config)
}
