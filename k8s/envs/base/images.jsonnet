{
  global:: {
    docker_registry: 'eu.gcr.io/xamaral/',
  },

  static_web: '%(docker_registry)sstatic-web:latest' % $.global,
  // comments: 'registry.gitlab.com/commento/commento:v1.7.0',
  nginx_ingress_controller: 'quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.24.1',
  cert_manager: 'bitnami/cert-manager:0.8.0',
  secret_gen: 'quay.io/mittwald/kubernetes-secret-generator:latest',
  // postgres: 'postgres:11.4',
  k8s_sso: 'xamaral/k8s-sso:latest',
  flux: 'xamaral/fluxkcfg:f80cb87',
  flux_memcached: 'memcached:1.5.15',
}
