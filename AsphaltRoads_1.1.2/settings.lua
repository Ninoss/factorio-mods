data:extend({
    {
        type = "bool-setting",
        name = "AR-use-items-from-bioindustries",
        setting_type = "startup",
        default_value = true,
        order  = "a",
    },
    {
        type = "bool-setting",
        name = "AR-easy-research",
        setting_type = "startup",
        default_value = false,
        order  = "b",
    },
    {
        type = "int-setting",
        name = "AR-asphalt-stack-size",
        setting_type = "startup",
        default_value = 100,
        minimum_value = 10,
        maximum_value = 1000,
        order = "c",
    },
    {
        type = "string-setting",
        name = "AR-item-group",
        setting_type = "startup",
        default_value = "logistics",
        allowed_values = {"logistics", "dectorio", "asphalt"},
        order = "d",    
    },
    --[[ WIP
    {
        type = "bool-setting",
        name = "AR-merge-transitions-of-asphalt-tiles",
        setting_type = "startup",
        default_value = true,
    }]]
})

