local name = 'oauth2-proxy';
local host = 'auth.xamaral.com';
local port = 4180;
local auth0_url = 'https://xamaral.eu.auth0.com/';

{
  local k = $.k,

  ingress: k.Ingress(name) + k.mixins.TlsIngress + {
    spec+: {
      rules: [
        {
          host: host,
          http: {
            paths: [
              {
                backend: {
                  serviceName: name,
                  servicePort: port,
                },
                path: '/',
              },
            ],
          },
        },
      ],  //rules
    },
  },  // ingress

  service: k.Service(name) {
    target_pod: $.deployment.spec.template,
  },

  secret: k.Secret(name) {
    metadata+: {
      annotations+: {
        'secret-generator.v1.mittwald.de/autogenerate': 'cookie-secret',
      },
    },
  },

  deployment: k.Deployment(name) {
    spec+: {
      replicas: 1,
      template+: {
        spec+: {
          containers_+: {
            default: k.Container(name) {
              image: $.images.oauth2_proxy,
              resources: {
                requests: { cpu: '100m', memory: '100Mi' },
              },
              args: [
                '--provider=oidc',
                '--http-address=0.0.0.0:%s' % port,
                '--oidc-issuer-url=%s' % auth0_url,
                '--login-url=%s/authorize' % auth0_url,
                '--redeem-url=%s/oauth/token' % auth0_url,
                '--validate-url=%s/userinfo' % auth0_url,
                '--email-domain=*',
                '--cookie-domain=xamaral.com',
              ],
              ports: [{ containerPort: port }],
              env_+: {
                OAUTH2_PROXY_CLIENT_ID: {
                  secretKeyRef: {
                    name: 'global-secrets',
                    key: 'oauth_client_id',
                  },
                },
                OAUTH2_PROXY_CLIENT_SECRET: {
                  secretKeyRef: {
                    name: 'global-secrets',
                    key: 'oauth_client_secret',
                  },
                },
                OAUTH2_PROXY_COOKIE_SECRET: {
                  secretKeyRef: {
                    name: name,
                    key: 'cookie-secret',
                  },
                },
              },
            },
          },
        },
      },
    },
  },
}
