/* this is only used to generate sealed secrets for applying
   it is not apply as part of the general kubecfg update
 */


local k = import 'kube-libsonnet/kube.libsonnet';
local secrets = import './secrets.json';
{
  global_secret: k.Secret('global-secrets') {
    data_+: secrets,
  },
}
