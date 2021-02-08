local yaml =  std.native('parseYaml');


{
  flux_components: yaml(importstr './flux/gotk-components.yaml'),
  flux_sync: yaml(importstr './flux/gotk-sync.yaml'),
}
