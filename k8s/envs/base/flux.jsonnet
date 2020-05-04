{
  /* see the flux repo on github for some example plain yamls
   https://github.com/fluxcd/flux/blob/master/deploy/
   */
  local k = $.globals.k,


  _config:: {

    # seems that this has to be the name. not sure why
    secret_name: 'flux-git-deploy',

    name: 'flux',
    env: $.globals.env,
    image: $.globals.images.flux,
    namespace: 'flux',
    git_label: 'flux-sync',
    branch: 'master',
  },

  local nsmix = {
    metadata+: {
      namespace: $._config.namespace,
    },
  },

  local name = $._config.name,
  local kgdir = '/var/fluxd/keygen',  
  ns: k.Namespace(name),

  deployment: k.Deployment(name) + nsmix + {
    spec+: {
      template+: {
        spec+: {
          serviceAccountName: name,
          containers_+: {
            default: k.Container(name) + {
              image: $._config.image,
              volumeMounts_+: {
                git_key: {
                  mountPath: '/etc/fluxd/ssh',
                  readOnly: true,
                },
                git_keygen: {
                  mountPath: kgdir,
                },
              },
            
              args: [
                '--memcached-service=',
                '--ssh-keygen-dir=%s' % kgdir,
                '--git-url=git@github.com:PaulRudin/xamaral',
                '--git-path=k8s/%s' % $._config.env,
                '--git-branch=%s' % $._config.branch,
                '--git-label=%s' % $._config.git_label,
                '--git-email=paul+flux@rudin.co.uk',
                '--manifest-generation=true',
              ],
              env_: {
                ENV: $._config.env,
              },
            },
          },
          volumes_+: {
            git_key: {
              secret: {
                secretName: $._config.secret_name,
                defaultMode: std.parseOctal('0400'),
              },
            },
            // for generated ssh key
            git_keygen: {
              emptyDir: {
                medium: 'Memory',
              },
            },
          },
        },
      },
    },
  }, //deployment

  secret: k.Secret($._config.secret_name) + nsmix,

  sa: k.ServiceAccount(name) + nsmix,

  cr: k.ClusterRole(name) {
    rules: [
      {
        apiGroups: ['*'],
        resources: ['*'],
        verbs: ['*'],
      },
      {
        nonResourceURLs: ['*'],
        verbs: ['*'],
      },
    ],
  }, // ClusterRole

  crb: k.ClusterRoleBinding(name) {
    roleRef: {
      apiGroup: 'rbac.authorization.k8s.io',
      kind: 'ClusterRole',
      name: name,
    },
    subjects: [
      {
        kind: 'ServiceAccount',
        name: name,
        namespace: name,
      },
    ],
  }, // crb

  memcached: k.Deployment('memcached') + nsmix + {
    spec+: {
      template+: {
        spec+: {
          containers_+: {
            default: k.Container('memcached') {
              image: $.globals.images.flux_memcached,
              args: [
                '-m 512',
                '-I 5m',
                '-p 11211',
              ],
              ports: [
                {
                  name: 'clients',
                  containerPort: 11211,
                },
              ],
              securityContext: {
                runAsUser: 11211,
                runAsGroup: 11211,
                allowPrivilegeEscalation: false,
              },
            },
          },
        },
      },
    },
  }, // memcached deployment

  memcached_svc: k.Service('memcached') + nsmix + {
    target_pod: $.memcached.spec.template,
  },
}
