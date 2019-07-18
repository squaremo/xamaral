{
  local k = $.k,
  local name = 'sso-helper',
  local port = 8080,
  local host = '%s.%s' % [name, $.root_dns_name],
  service: k.Service(name) {
    target_pod: $.deployment.spec.template,
  },

  
  ingress: k.Ingress(name) + k.mixins.TlsIngress + {
    spec+: {
      rules: [
        {
          host: host,
          http: {
            paths: [
              {
                path: '/',
                backend: $.service.name_port,
              },              
            ],
          },
        },
      ],
    },
  },
  deployment: k.Deployment(name) {
    spec+: {
      template+: {
        spec+: {
          containers_+: {
            default: k.Container(name) {
              image: $.images.sso_helper,
              ports: [{ containerPort: 8080 }],
              env_+: {
                SSO_HELPER_COMMENTO_SECRET: {
                  secretKeyRef: {
                    name: 'global-secrets',
                    key: 'commento_hmac',
                  }
                },
                SSO_HELPER_COMMENTO_URL: 'https://comments.xamaral.com',
              },
            }
          }
        }
      }
    }
  }
}
