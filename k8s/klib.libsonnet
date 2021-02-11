(import 'kube-libsonnet/kube.libsonnet') {

  local t = self,

  crds: {
    ImageRepository(name): $._Object(
      'image.toolkit.fluxcd.io/v1alpha1', 'ImageRepository', name
    ),

    ImagePolicy(name): $._Object(
      'image.toolkit.fluxcd.io/v1alpha1', 'ImagePolicy', name
    ) + {
      spec+: {
        imageRepositoryRef: { name: name },
        policy: error 'policy required',
      },
    },

    Elasticsearch(name): $._Object(
      'elasticsearch.k8s.elastic.co/v1', 'Elasticsearch', name,
    ) + {
      spec: {
        version: '7.6.0',
        nodeSets: [{
          name: 'default',
          count: 1,
          config: {
            node: {
              master: true,
              data: true,
              ingest: true,
              store: { allow_mmap: false },
            },
          },
        }],
      },
    },  // elastic
    Kibana(name): $._Object(
      'kibana.k8s.elastic.co/v1', 'Kibana', name
    ) + {
      spec+: {
        // TODO - consist versioning elastic, kibana and relevant CRDs
        version: '7.6.1',
        count: 1,
        http: {

          /* note that we're doing tls through the ingress controller, so we
           don't really need another layer of tls here, be careful if your
           setup is different - you could end up with an way to avoid https
           altogether */
          tls: { selfSignedCertificate: { disabled: true } },
        },

        elasticsearchRef: {

          // TODO - refactor so that the name of the elasticsearch instances
          // and this reference are in sync

          name: 'elastic',
        },
      },
    },
    AcmeClusterIssuer(name, email, server): $._Object(
      'cert-manager.io/v1', 'ClusterIssuer', name
    ) + {
      spec+: {
        acme: {
          email: email,
          server: server,
          privateKeySecretRef: {
            name: name + '-clusterissuer-account-key',
          },
          solvers: [{ http01: { ingress: { class: 'nginx' } } }],
        },
      },
    },
  },  // crds

  mixins: {

    GcsPlugin: {
      // adds an init container for installing the gcs plugin to pods of an Elastic object
      local podTemplateMixin = {
        podTemplate+: {
          spec+: {
            initContainers+: [{
              name: 'install-gcs-plugin',
              command: ['sh', '-c', 'bin/elasticsearch-plugin install --batch repository-gcs'],
            }],
          },
        },
      },

      spec+: {
        nodeSets: [
          n + podTemplateMixin
          for n in super.nodeSets
        ],
      },
    },  // GcsPlugin

    TlsIngress: {
      local s = self,
      metadata+: {
        annotations+: {
          'kubernetes.io/ingress.class': 'nginx',
          'cert-manager.io/cluster-issuer': 'letsencrypt-prod',
          'cert-manager.io/acme-challenge-type': 'http01',
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

    AuthedIngress: self.TlsIngress {
      local s = self,
      auth_endpoint:: 'https://$host/oauth2/',
      metadata+: {
        annotations+: {
          'nginx.ingress.kubernetes.io/auth-signin': '%sstart?rd=$escaped_request_uri' % s.auth_endpoint,
          'nginx.ingress.kubernetes.io/auth-url': 'http://k8s-sso.default.svc.cluster.local:8080/oauth2/auth',
          'nginx.ingress.kubernetes.io/auth-response-headers': 'X-Auth-ID',
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
                  serviceName: 'k8s-sso',
                  servicePort: 8080,
                },
                path: '/oauth2',
              }],
            },
          }],
        },
      },
  },
}
