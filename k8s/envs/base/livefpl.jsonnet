{
  local k = $.globals.k,
  local name = 'livefpl',
  local ui_name = 'livefpl-ui',

  // same for api and ui
  local port = 8000,
  local fs_ns_mixin = {
    metadata+: {
      namespace: 'flux-system',
    },
  },
  // NB - currently this secret is manually provisioned
  local regsecret = { name: 'ghcrcred' },

  repo:: {
    name:: error 'must set name',
    local s = self,
    def:: k.crds.ImageRepository(s.name) + fs_ns_mixin + {
      spec: {
        image: 'ghcr.io/paulrudin/%s' % s.name,
        interval: '1m0s',
      secretRef: regsecret,
      },
    },
  },

  image_repository: (self.repo + {name: name}).def,

  ui_repository: (self.repo + {name: ui_name}).def,

  policy:: {
    name:: error 'must set name',
    def:: k.crds.ImagePolicy(self.name) + fs_ns_mixin + {
      spec+: {
        policy: {
          semver: {
            range: '0.0.x',
          },
        },
      },
    },
  },
  
  image_policy: (self.policy + {name: name}).def,

  ui_image_policy: (self.policy + {name: ui_name}).def,

  deploy_template:: {
    name:: error 'must supply name',
    env:: {},
    local s = self,
    def::  k.Deployment(s.name) + {
      spec+: {
        template+: {
          spec+: {
            imagePullSecrets: [regsecret],
            containers_+: {
              default: k.Container(s.name) + {
                env_+: s.env,
                ports_+: {
                  http: { containerPort: port },
                },
                image: $.globals.images[s.name],
              },
            },
          },
        },
      },
    },  //deployment
  },
      
  deploy: (self.deploy_template + {name: name}).def,

  ui_deploy: (self.deploy_template + {
    name: ui_name,
    env: {
      API_URL: 'http://%s:%s' % [name, port],
      PORT: port,
    },
  }).def,

  ui_svc: k.Service(ui_name) + {
    target_pod: $.ui_deploy.spec.template,
  },

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
            backend: $.ui_svc.name_port,
          }],
        },
      }],
    },
  },  //ingress
}
