{
  global:: {
    docker_registry: 'eu.gcr.io/xamaral/',
    git_sha: std.extVar('git_sha'),
  },

  static_web: '%(docker_registry)sstatic-web:%(git_sha)s' % $.global,
  comments: 'registry.gitlab.com/commento/commento:v1.7.0',
  nginx_ingress_controller: "quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.24.1",
  cert_manager: "bitnami/cert-manager:0.8.0",
  secret_gen: "quay.io/mittwald/kubernetes-secret-generator:latest",
  postgres: "postgres:11.4",
  oauth2_proxy: 'quay.io/repository/pusher/oauth2_proxy:v3.2.0',
  sso_helper: '%(docker_registry)ssso-helper:latest' % $.global,
}
