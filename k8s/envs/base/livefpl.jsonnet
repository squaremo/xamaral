{
  local k = $.globals.k,
  local name = 'livefpl',

  deploy: k.Deployment(name) + {
    spec+: {
      template+: {
        spec+: {
          imagePullSecrets: [{
            // NB - currently this secret is manually provisioned
            name: 'ghcrcred',
          }],
          containers_+: {
            default: k.Container(name) + {
              ports_+: {
                http: { containerPort: 8080 },
              },
              image: $.globals.images.livefpl,
            },
          },
        },
      },
    },
  }, //deployment
  svc: k.Service(name) + {
    target_pod: $.deploy.spec.template,
  },
  ingress: k.Ingress(name) + k.mixins.TlsIngress + {
    spec+: {
      rules+: [{
        host: 'livefpl.xamaral.com',
        http: {
          paths: [{
            path: '/',
            backend: $.svc.name_port,
          }],
        },
      }],
    },
  }, //ingress
}
