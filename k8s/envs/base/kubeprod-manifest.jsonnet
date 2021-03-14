// Cluster-specific configuration
(import '../../vendor/manifests/platforms/aks.jsonnet') {
  config:: import 'kubeprod-autogen.json',
  //disable es, fluent and kibana for now
  fluentd_es:: null,
  elasticsearch:: null,
  kibana:: null,
  nginx_ingress+: {
    config+: {
      data+: {
        'use-forwarded-headers': 'true',
        'enable-real-ip': 'true',
        'proxy-add-original-uri-header': 'true',
      },
    },
  },
}
