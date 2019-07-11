local k = import 'kube-libsonnet/kube.libsonnet';
local name = 'oauth2-proxy';
local host = 'oauth.xamaral.com';
local port = 4180;
local auth0_url = 'https://xamaral.eu.auth0.com/';

{
  
  ingress: k.Ingress(name) {
    spec: {
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
      ], //rules
      tls: [
        {
          hosts: [host],
          secretName: '%s-tls-secret' % name,
        },
      ],
    },
  }, // ingress

  service: k.Service(name) {
    target_pod: $.deployment.spec.template,

  },
    
  deployment: k.Deployment(name) {
    spec+: {
      replicas: 1,
      template+: {
        spec+: {
          containers_+: {
            default: k.Container(name) {
              image: $.images.oauth_proxy,
              resources: {
                requests: {cpu: '100m', memory: '100Mi'},
              },
              args: [
                '--provider=oidc',
                '--http-address=0.0.0.0%s' % port,
                '--oidc-issuer-url=%s' % auth0_url,
                '--login-url=%s/authorize' % auth0_url,
                '--redeem-url=%s/oauth/token' % auth0_url,
                '--validate-url=%s/userinfo' % auth0_url,
              ],
              ports: [{containerPort: port}]
              env_+: {
                OAUTH2_PROXY_CLIENT_ID: $.secrets.oauth_client_id,
                OAUTH2_PROXY_CLIENT_SECRET: $.secrets.oauth_client_secret,
              },  
            },
          },
        },
      },
    },
  },
}
