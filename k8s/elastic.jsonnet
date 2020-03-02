{
  local k = $.k,
  local name = 'elastic',
  elastic: k.crds.Elasticsearch(name)
  + k.mixins.GcsPlugin,
}
