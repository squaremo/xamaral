local images = {images:: (import "images.json")};

local configs = {
  static_site: (import "./static-site.jsonnet"),
  ingress_controller: (import "./nginx-ingress-controller.jsonnet"),
  cert_manager: (import "./cert-manager.jsonnet"),
};

{
  [k]: images + configs[k]
  for k in std.objectFields(configs)
}
