{
  local k = $.globals.k,
  local name = 'livefpl',
  // NB - currently this secret is manually provisioned
  local regsecret = { name: 'ghcrcred' },
  image_repository: k.crds.ImageRepository(name) + {
    spec: {
      image: 'ghcr.io/paulrudin/%s' % name,
      interval: '1m0s',
      secretRef: regsecret,
    },
  },

  image_policy: k.crds.ImagePolicy(name) + {
    spec+: {
      policy: {
        semver: {
          range: '^0.x-0',
        },
      },
    },
  },
  deploy: k.Deployment(name) + {
    spec+: {
      template+: {
        spec+: {
          imagePullSecrets: [regsecret],
          containers_+: {
            default: k.Container(name) + {
              ports_+: {
                http: { containerPort: 8000 },
              },
              image: $.globals.images.livefpl,
            },
          },
        },
      },
    },
  },  //deployment
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
  },  //ingress
}
