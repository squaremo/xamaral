{
  global:: {
    docker_registry: 'eu.gcr.io/xamaral/',
    git_sha: std.extVar('git_sha'),
  },

  static_web: '%(docker_registry)sstatic-web:%(git_sha)s' % $.global,
  comments: '%(docker_registry)scomments:%(git_sha)s' % $.global,
  nginx_ingress_controller: "quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.24.1",
  cert_manager: "bitnami/cert-manager:0.8.0",
}
