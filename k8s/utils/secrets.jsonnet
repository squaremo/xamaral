/* this is only used to generate sealed secrets for applying
   it is not apply as part of the general kubecfg update
 */


local k = import 'klib.libsonnet';

function(secrets, secret_name)
   k.Secret(secret_name) + {
    data_+: secrets,
   }
