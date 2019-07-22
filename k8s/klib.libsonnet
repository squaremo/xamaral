(import 'kube-libsonnet/kube.libsonnet') {

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

    AuthIngress: {
      local s = self,
      //host:: s.spec.rules[0].host, // beware, we don't cope properly with multiple hosts here.
      auth_endpoint:: 'https://auth.xamaral.com/oauth2/',
      metadata+: {
        annotations+: {
          'nginx.ingress.kubernetes.io/auth-signin': '%sstart?rd=$request_uri' % s.auth_endpoint,
          'nginx.ingress.kubernetes.io/auth-url': s.auth_endpoint + 'auth',
        },
      },
    },
  },
}
