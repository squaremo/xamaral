local globals = {
  images:: import "images.jsonnet",
  secrets:: import "secrets.json",
  root_dns_name:: 'xamaral.com',
  k:: import './klib.libsonnet',
};

local configs = {
  static_site: (import "./static-site.jsonnet"),
  ingress_controller: (import "./nginx-ingress-controller.jsonnet"),
  cert_manager: (import "./cert-manager.jsonnet"),
  comments: (import "./comments.jsonnet"),
  sso_helper: (import "./sso-helper.jsonnet"), 
  secretgen: (import "./secretgen.jsonnet"),
  postgres: (import "./postgres.jsonnet"),
  oauth2_proxy: import "./oauth2-proxy.jsonnet",
  global_secret: import "./secrets.jsonnet",
};

{
  [k]: globals + configs[k]
  for k in std.objectFields(configs)
}
