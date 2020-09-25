// just use the vendor distributed yaml

{
  local k = $.globals.k,

  // this gives errors - not sure why, but kubectl can apply the yaml fine as a workaround
  // cert_manager: std.native('parseYaml')(importstr './vendor/cert-manager.yaml'),

  cluster_issuer: k.crds.AcmeClusterIssuer(
    'letsencrypt-prod', 'paul@xamaral.com',  'https://acme-v02.api.letsencrypt.org/directory'
  ) 
}
