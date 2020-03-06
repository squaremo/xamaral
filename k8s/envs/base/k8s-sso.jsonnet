{
  local sso = self,
  local k = $.globals.k,
  local name = 'k8s-sso',
  local port = 8080,
  local host = '%s.%s' % [name, $.root_dns_name],
  local auth0_url = 'https://xamaral.eu.auth0.com/',

  service: k.Service(name) {
    target_pod: $.deployment.spec.template,
  },

  creds: k.Secret(name) {
    metadata+: {
      annotations+: {
        'secret-generator.v1.mittwald.de/autogenerate': 'session_cookie_secret',
      },
    },
  },

  deployment: k.Deployment(name) {
    spec+: {
      template+: {
        spec+: {
          containers_+: {
            default: k.Container(name) {
              image: $.globals.images.k8s_sso,
              imagePullPolicy: 'Always',
              ports: [{ containerPort: 8080 }],
              env_+: {
                K8S_SSO_CLIENT_ID: {
                  secretKeyRef: {
                    name: 'global-secrets',
                    key: 'oauth_client_id',
                  },
                },
                K8S_SSO_CLIENT_SECRET: {
                  secretKeyRef: {
                    name: 'global-secrets',
                    key: 'oauth_client_secret',
                  },
                },
                K8S_SSO_SESSION_COOKIE_SECRET: {
                  secretKeyRef: {
                    name: name,
                    key: 'session_cookie_secret',
                  }
                },
                K8S_SSO_CLIENT_BASE_URL: auth0_url,
              },
            },
          },
        },
      },
    },
  },
}
