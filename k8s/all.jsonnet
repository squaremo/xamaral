local globals = {
  images:: import 'images.jsonnet',
  secrets:: import 'secrets.json',
  root_dns_name:: 'xamaral.com',
  k:: import './klib.libsonnet',
};

local configs = {
  static_site: (import './static-site.jsonnet'),
  ingress_controller: (import './nginx-ingress-controller.jsonnet'),
  cert_manager: (import './cert-manager.jsonnet'),
  // comments: (import './comments.jsonnet'),
  k8s_sso: (import './k8s-sso.jsonnet'),
  echo: import './echo.jsonnet',
  secretgen: (import './secretgen.jsonnet'),
  postgres: (import './postgres.jsonnet'),
  global_secret: import './sealed-secrets.json',
  sealed_secrets_controller: import './sealed-secrets-controller.jsonnet',
  hello: import './hello.jsonnet',
  flux: import './flux.jsonnet',
};

{
  [k]: globals + configs[k]
  for k in std.objectFields(configs)
}
