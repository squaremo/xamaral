local name = 'comments';
local host = 'comments.xamaral.com';
local port = 8080;

{
  local k = $.k,
  svc: k.Service(name) {
    target_pod: $.deployment.spec.template,
  },

  ingress: k.Ingress(name) {
    metadata+: {
      annotations+: {
        'kubernetes.io/ingress.class': 'nginx',
        'certmanager.k8s.io/cluster-issuer': 'letsencrypt-prod',
        'certmanager.k8s.io/acme-challenge-type': 'http01',
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
                  servicePort: port,
                },
              },
            ],
          },
        },
      ],  //rules
    },
  },  //ingress

  creds: k.Secret(name) {
    metadata+: {
      annotations+: {
        'secret-generator.v1.mittwald.de/autogenerate': 'password',
      },
    },
  },

  cfmap: k.ConfigMap(name) {
    data+: {
      'db_setup.sh': (importstr './db_setup.sh'),
    },
  },
  deployment: k.Deployment(name) {
    spec+: {
      replicas: 1,
      template+: {
        spec+: {
          volumes_+: {
            config: {
              configMap: {
                name: name,
                defaultMode: std.parseOctal('0744'),
              },
            },
          },
          // we need the ordering so no initContainers_
          initContainers+: [
            k.Container('db-setup') {
              image: $.images.postgres,
              command: ['/etc/config/db_setup.sh'],
              volumeMounts_+: {
                config: {
                  mountPath: '/etc/config',
                },
              },
              env_+: {
                COMMENTS_PW: {
                  secretKeyRef: {
                    name: name,
                    key: 'password',
                  },
                },
                PGHOST: 'postgres',
                PGPASSWORD: {
                  secretKeyRef: {
                    name: 'postgres',
                    key: 'password',
                  },
                },
                PGUSER: 'postgres',
              },
            },
          ],
          containers_+: {
            default: k.Container('name') {
              image: $.images.comments,
              resources: {
                requests: { cpu: '100m', memory: '100Mi' },
              },
              env_+: {
                COMMENTO_ORIGIN: 'https://%s' % host,
                COMMENTO_POSTGRES:
                  'postgres://comments:$(COMMENTS_DB_PASSWORD)@postgres:5432/comments?sslmode=disable',
              },
              // NB - since we're using this variable in another, it has to be defined first
              env: [
                {
                  name: 'COMMENTS_DB_PASSWORD',
                  valueFrom: {
                    secretKeyRef: {
                      name: name,
                      key: 'password',
                    },
                  },
                },
              ] + super.env,
              ports: [{ containerPort: port }],
            },
          },  //containers_
        },  //spec
      },  //template
    },  //spec
  },  //deployment
}
