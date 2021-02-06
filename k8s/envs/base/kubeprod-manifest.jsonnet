// Cluster-specific configuration
(import '../../vendor/manifests/platforms/aks.jsonnet') {
  config:: import "kubeprod-autogen.json",
  //disable es, fluent and kibana for now
  fluentd_es:: null,
  elasticsearch:: null,
  kibana:: null,
}
