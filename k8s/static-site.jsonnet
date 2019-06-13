local k = import "kube-libsonnet/kube.libsonnet";

local name = "static-web";
local host = "xamaral.com";

{
  svc: k.Service(name) {
    target_pod: $.deploy.spec.template,
  },

  ingress: k.Ingress(name) {
    metadata+: {
      annotations+: {
        "kubernetes.io/ingress.class": "nginx",
        "certmanager.k8s.io/cluster-issuer": "letsencrypt-prod",
        "certmanager.k8s.io/acme-challenge-type": "http01",
      },
    },
    spec+: {
      tls: [
        {
          hosts: [host],
          secretName: '%s-tls-secret' % name,
        },
      ],
      rules: [
        {
          host: host,
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
      replicas: 2,
      template+: {
        spec+: {
          containers_+: {
            nginx: k.Container("nginx") {
              image: $.images.static_web,
              resources: {
                requests: {cpu: "100m", memory: "100Mi"},
              },
              ports: [{containerPort: 80}],
            },
          },
        },
      },
    },
  },
}
