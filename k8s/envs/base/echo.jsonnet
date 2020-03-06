{
  local name = 'echo',
  local k = $.globals.k,
  local s = self,
  local host = '%s.%s' % [name, $.globals.root_dns_name],
  svc: k.Service(name) {
    target_pod: $.deployment.spec.template,
  },

  ingress: k.Ingress(name) + k.mixins.TlsIngress {
    spec+: {
      rules: [
        {
          host: host,
          http: {
            paths: [
              {
                path:  '/',
                backend: $.svc.name_port,
              },
            ],
          },
        },
      ],
    }
  },

  deployment: k.Deployment(name) {
    spec+: {
      template+: {
        spec+: {
          containers_+: {
            default: k.Container(name) {
              image: $.globals.images.echo,
              imagePullPolicy: 'Always',
              ports: [{containerPort: 8080}],
            },
          },
        },
      },
    },
  },
}
