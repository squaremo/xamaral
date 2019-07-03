local k = import "kube-libsonnet/kube.libsonnet";

local name = "comments";
local host = "comments.xamaral.com";

{
  comments_svc: k.Service(name) {
    target_pod: $.comments_sset.spec.template,
  },

  comments_ingress: k.Ingress(name) {
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
      ], //rules
    },
  }, //ingress

  comments_sset: k.StatefulSet(name) {
    spec+: {
      replicas: 1,
      template+: {
        spec+: {
          containers_+: {
            default: {
              image: $.images.comments,
              resources: {
                requests: {cpu: "100m", memory: "100Mi"},
              },
              ports: [{containerPort: 80}],
              volumeMounts_+:: {
                comments_data: {
                  mountPath: "/var/lib/isso/",
                },
              },
            },
          },
        },
      },
      volumeClaimTemplates_+:: {
        comments_data: {
          storage:: "5Gi",
        },
      },
    },
  },
}
