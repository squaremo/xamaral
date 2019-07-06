local images = {images:: (import "images.jsonnet")};

local configs = {
  static_site: (import "./static-site.jsonnet"),
  ingress_controller: (import "./nginx-ingress-controller.jsonnet"),
  cert_manager: (import "./cert-manager.jsonnet"),
  comments: (import "./comments.jsonnet"),
  secretgen: (import "./secretgen.jsonnet"),
  postgres: (import "./postgres.jsonnet"),
};

{
  [k]: images + configs[k]
  for k in std.objectFields(configs)
}
