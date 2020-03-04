// for testing
{
  local name = 'hello',
  local k = $.k,
  local s = self,
  local host = '%s.%s' % [name, $.root_dns_name],
  svc: k.Service(name) {
    target_pod: $.deployment.spec.template,
  },

  ingress: k.Ingress(name) + k.mixins.AuthedIngress {
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

  auth_ingress: k.funcs.AuthIngressFor(s.ingress),

  deployment: k.Deployment(name) {
    spec+: {
      template+: {
        spec+: {
          containers_+: {
            default: k.Container(name) {
              image: 'jmalloc/echo-server',
              imagePullPolicy: 'Always',
              ports: [{containerPort: 8080}],
            },
          },
        },
      },
    },
  },
}
