local name = 'postgres';

{
  local k = $.k,

  svc: k.Service(name) {
    target_pod: $.sset.spec.template,
  },

  creds: k.Secret(name) {
    metadata+: {
      annotations+: {
        'secret-generator.v1.mittwald.de/autogenerate': 'password',
      },
    },
  },
  sset: k.StatefulSet(name) {
    spec+: {
      replicas: 1,
      template+: {
        spec+: {
          containers_+: {
            default: k.Container(name) {
              image: $.images.postgres,
              resources: {
                requests: { cpu: '100m', memory: '100Mi' },
              },
              ports: [{ containerPort: 5432 }],
              volumeMounts_+: {
                postgres_data: {
                  mountPath: '/var/lib/postgresql/data',
                  subPath: 'db',
                },
              },
              env_+: {
                POSTGRES_PASSWORD: {
                  secretKeyRef: {
                    name: name,
                    key: 'password',
                  },
                },
              },
            },
          },
        },
      },  //template
      volumeClaimTemplates_+:: {
        postgres_data: {
          storage: '10Gi',
        },
      },
    },
  },
}
