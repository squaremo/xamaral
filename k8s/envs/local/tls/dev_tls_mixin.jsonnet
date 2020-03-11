local secretname = 'ca-key-pair';

/* We can't use let's encrypt for dev machines so create an self-signing issuer. 
 See: https://docs.cert-manager.io/en/release-0.8/tasks/issuers/setup-ca.html
 */


{
  globals+: {
    root_dns_name: 'xamaral.test',
    k+: {
      mixins+: {
        TlsIngress+: {
          metadata+: {
            annotations+: {
              "certmanager.io/cluster-issuer": "ca-issuer",
              "certmanager.io/acme-challenge-type":: null,
            },
          },
        },
      },
    },
  },

  local k = $.globals.k,
  
  cert_manager+: {
    cert_manager+: [
      /* We use the name "secrets.json", because the git-crypt is configured to encrypt such files
       */
      local tls_secret_data = (import './secrets.json');
      
      k.Secret(secretname) + {
        type: "kubernetes.io/tls",
        data: {
          "tls.crt": tls_secret_data.cert,
          "tls.key": tls_secret_data.key,
        },
      },
      
      k._Object("certmanager.k8s.io/v1alpha2" ,"ClusterIssuer","ca-issuer") + {
        spec+: {ca: {secretName: secretname}}
      },
      
      k._Object('certmanager.k8s.io/v1alpha2' ,'Certificate', 'xamaral-test') + {
        spec+: {
          secretName: secretname,
          issuerRef: {
            name: 'ca-issuer',
            kind: 'ClusterIssuer',
          },
          commonName: '*.xamaral.test',
          organization: ['xamaral.test'],
          dnsNames: ['*.xamaral.test'],
        },
      },
    ],
  },
}
