local k = import 'kube-libsonnet/kube.libsonnet';
{
  global_secret: k.Secret("global-secrets") {
    data_+: $.secrets,
  }
}
