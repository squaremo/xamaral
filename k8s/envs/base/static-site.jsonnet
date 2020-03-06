local name = 'static-web';

{
  local k = $.globals.k,

  svc: k.Service(name) {
    target_pod: $.deploy.spec.template,
  },

  ingress: k.Ingress(name) + k.mixins.TlsIngress + {
    spec+: {
      rules: [
        {
          host: $.globals.root_dns_name,
          http: {
            paths: [
              {
                path: '/',
                backend: {
                  serviceName: name,
                  servicePort: 80,
                },
              },
            ],
          },
        },
      ],
    },
  },
  deploy: k.Deployment(name) {
    spec+: {
      replicas: 1,
      template+: {
        spec+: {
          containers_+: {
            nginx: k.Container('nginx') {
              image: $.globals.images.static_web,
              resources: {
                requests: { cpu: '100m', memory: '100Mi' },
              },
              ports: [{ containerPort: 80 }],
            },
          },
        },
      },
    },
  },
}
