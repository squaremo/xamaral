local secretname = 'ca-key-pair';

/* We can't use let's encrypt for dev machines so create an self-signing issuer. 

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

/*

local no_tls_mixin = {
  metadata+: {
    annotations+: {
      'nginx.ingress.kubernetes.io/ssl-redirect': 'false'
    },
  },
};

local isK8s(o) = std.objectHas(o, "kind");

local remove_tls_from_ingress(o) = (
  if isK8s(o) && o.kind == "Ingress" then o + no_tls_mixin else o
);

local remove_all_ingress_tls(objs) = (
  if std.isObject(objs) then if isK8s(objs) then remove_tls_from_ingress(objs) else {
    [k]: remove_all_ingress_tls(objs[k]) for k in std.objectFields(objs)
  } else if std.isArray(objs) then [remove_all_ingress_tls(o) for o in objs]
  else objs
);

remove_all_ingress_tls(config)
*/
