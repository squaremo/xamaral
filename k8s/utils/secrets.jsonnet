/* this is only used to generate sealed secrets for applying
   it is not apply as part of the general kubecfg update

 note that for image pull secrets you can make an approprate string for the .dockerconfigjson field using e.g

kubectl create secret docker-registry gcr-secret   --namespace="default"   --docker-server=eu.gcr.io   --docker-username=_json_key   --docker-password="$(cat /tmp/imagepullsecrets.json )" --dry-run -o yaml

 */


local k = import 'klib.libsonnet';

function(secrets) (
  /* secrets must contain a name fields, type is optional and defaults to
   'Opaque'.  Either supply a data field, in which case it'll be base64 encoded
   for you, or a raw_data field, in which case the values should already be
   base64 encoded */
 
  local s = {type: 'Opaque'} + secrets;
  k.Secret(s.name) + {
    [if "data" in s then "data_+"]: s.data,
    [if "raw_data" in s then "data"]: s.raw_data,
    type: s.type,
  }
)
