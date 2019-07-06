local k = import "kube-libsonnet/kube.libsonnet";

local name = "secretgen";
local namespace = 'kube-system';
{
  deployment: k.Deployment(name) {
    metadata+: {
      namespace: namespace,
    },
    spec+: {
      replicas: 1,
      template+: {
        spec+: {
          serviceAccountName: name,
          containers_: {
            secretgen: {
              image: $.images.secret_gen,
              command: ["/kubernetes-secret-generator"],
              args: ["-logtostderr", "-all-namespaces", "-regenerate-insecure"]
            },
          },
        },
      },
    },
  },

  clusterRole: k.ClusterRole(name) {
    rules: [
      {
        apiGroups: [''],
        resources: ['secrets'],
        verbs: ['get', 'watch', 'list', 'update'],
      },
    ],
  },
  
  crb: k.ClusterRoleBinding(name) {
    roleRef: {
      kind: 'ClusterRole',
      name: name,
      apiGroup: 'rbac.authorization.k8s.io',
    },
    subjects: [
      {
        kind: 'ServiceAccount',
        name: name,
        namespace: namespace,
      },
    ],
  },

  sa: k.ServiceAccount(name) {
    metadata+: {
      namespace: namespace,
    }
  },
}
