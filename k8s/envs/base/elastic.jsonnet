{
  local k = $.globals.k,
  local name = 'elastic',
  elastic: k.crds.Elasticsearch(name)
  + k.mixins.GcsPlugin,
}
