local k = import "kube-libsonnet/kube.libsonnet";

local name = "static-web";

{
  svc: k.Service(name) {
    target_pod: $.deploy.spec.template,
    spec+: {type: "LoadBalancer"},
  },

  deploy: k.Deployment(name) {
    spec+: {
      replicas: 3,
      template+: {
        spec+: {
          containers_+: {
            nginx: k.Container("nginx") {
              image: std.extVar("static-image"),
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
