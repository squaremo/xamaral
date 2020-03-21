{
  local k = $.globals.k,
  local name = 'elastic',
  elastic: k.crds.Elasticsearch(name) + k.mixins.GcsPlugin,
  kibana: {
    local name = 'kibana',
    kibana: k.crds.Kibana(name),
    ingress: k.Ingress(name)  + k.mixins.TlsIngress + {
      spec+: {
        rules: [{
          host: name + '.' + $.globals.root_dns_name,
          http: {
            paths: [{
              path: '/',
              backend: {
                serviceName: name + '-kb-http',
                servicePort: 5601,
              },
            }]
          },
        }],
      },
    },
  },
}
