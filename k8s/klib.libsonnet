(import 'kube-libsonnet/kube.libsonnet') {

  local t = self,

  mixins: {
    TlsIngress: {
      local s = self,
      metadata+: {
        annotations+: {
          "kubernetes.io/ingress.class": "nginx",
          "certmanager.k8s.io/cluster-issuer": "letsencrypt-prod",
          "certmanager.k8s.io/acme-challenge-type": "http01",
        },
      },
      spec+: {
        tls+: [
          {
            hosts: std.set([rule.host for rule in s.spec.rules]),
            secretName: '%s-tls-secret' % s.metadata.name,
          },
        ],
      },
    },

    AuthedIngress: self.TlsIngress + {
      local s = self,
      auth_endpoint:: 'https://$host/oauth2/',
      metadata+: {
        annotations+: {
          'nginx.ingress.kubernetes.io/auth-signin': '%sstart?rd=$escaped_request_uri' % s.auth_endpoint,
          'nginx.ingress.kubernetes.io/auth-url': s.auth_endpoint + 'auth',
        },
      },
    },

  },

  funcs: {
    AuthIngressFor(ing):: 
      $.Ingress(ing.metadata.name + '-oauth2') {
        spec+: {
          rules+: [{
            // we don't deal with multiple hosts
            host: ing.spec.rules[0].host,
            http+: {
              paths+: [{
                backend+: {
                  serviceName: 'oauth2-proxy',
                  servicePort: 4180,
                },
                path: '/oauth2',
              }],
            },
          }],
        },
      },
  },
}
