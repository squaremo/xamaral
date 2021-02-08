// invoke with: jsonnet -m . tf.jsonnet

local project = 'xamaral';
local disk_size_mixin = {
  # 30 is the minimum permitted
  os_disk_size_gb: 30,
};

local tags = {
  tags+: {
    managed_by: 'terraform',
  },
};

{
  'backend.tf.json': {
    terraform+: {
      backend: {
        remote: {
          organization: 'xamaral',
          workspaces: {
            name: 'xamaral'
          },
        },
      },
    },
  },

  'main.tf.json': {
    terraform+: {
      required_providers+: {
        azurerm: {
          source: 'hashicorp/azurerm',
          version: '=2.46.0',
        },
      },
    },
    
    provider+: {
      azurerm: {
        // seems to be necessary
        features: {},
      },
    },

    
    resource+: {

      azurerm_resource_group: {
        [project]: {
          name: project,
          location: 'West Europe',
        },
      },

      local rg = {
        resource_group_name: '${azurerm_resource_group.%s.name}' % project,
        location: '${azurerm_resource_group.%s.location}' % project,
      },

      // default mixin for all resources
      local m = tags + rg,
      
      azurerm_kubernetes_cluster+: {
        [project]: m + {
          name: project,
          dns_prefix: project,
          identity: {
            type: 'SystemAssigned',
          },
          // we're required to have a default node pool.
          // we add a pool for spot VMs below.
          default_node_pool: disk_size_mixin + {
            name: 'default',
            vm_size: 'standard_b2s',
            node_count: 2,

          },
        },
      },

      azurerm_kubernetes_cluster_node_pool+: {
        spot: tags + disk_size_mixin + {
          name: 'spot',
          kubernetes_cluster_id: '${azurerm_kubernetes_cluster.%s.id}' % project,
          vm_size: 'standard_a2_v2',
          priority: 'Spot',
          eviction_policy: 'Delete',
          spot_max_price: -1,
          enable_auto_scaling: true,
          min_count: 0,
          max_count: 5,
          lifecycle: {
            ignore_changes: ['node_count'],
          },
        },
      },
    },
  },
}
