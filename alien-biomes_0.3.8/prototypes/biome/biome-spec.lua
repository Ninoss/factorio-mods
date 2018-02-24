
-- multiply axes by variants
-- note: equal influence, higher ranges overlapping other optimal point range wins.
return {
  mineral = { -- and sand
    dimensions = { distribution_temperature = {0.25, 0.75} },
    axes = {
      purple     = { dimensions = {mineral_a = {0.6, 1.0}, mineral_b = {0.9, 1.0}} },
      violet     = { dimensions = {mineral_a = {0.6, 1.0}, mineral_b = {0.8, 0.9}} },
      red        = { dimensions = {mineral_a = {0.6, 1.0}, mineral_b = {0.6, 0.8}} },
      brown      = { dimensions = {mineral_a = {0.6, 1.0}, mineral_b = {0.3, 0.6}} },
      tan        = { dimensions = {mineral_a = {0.6, 1.0}, mineral_b = {0.0, 0.3}} },
      aubergine  = { dimensions = {mineral_a = {0.3, 0.6}, mineral_b = {0.8, 1.0}} },
      dustyrose  = { dimensions = {mineral_a = {0.3, 0.6}, mineral_b = {0.6, 0.8}} },
      beige      = { dimensions = {mineral_a = {0.3, 0.6}, mineral_b = {0.3, 0.6}} },
      cream      = { dimensions = {mineral_a = {0.3, 0.6}, mineral_b = {0.0, 0.3}} },
      black      = { dimensions = {mineral_a = {0.0, 0.3}, mineral_b = {0.7, 1.0}} },
      grey       = { dimensions = {mineral_a = {0.0, 0.3}, mineral_b = {0.3, 0.7}} },
      white      = { dimensions = {mineral_a = {0.0, 0.3}, mineral_b = {0.0, 0.3}} },
    },
    variants = {
      ["dirt-1"]   = { transition = "beach", group = "dirt", dimensions = {distribution_moisture = {0.4, 0.6}} },
      ["dirt-2"]   = { transition = "cliff", group = "dirt", dimensions = {distribution_moisture = {0.4, 0.6}} },
      ["dirt-3"]   = { transition = "cliff", group = "dirt", dimensions = {distribution_moisture = {0.4, 0.6}} },
      ["dirt-4"]   = { transition = "cliff", group = "dirt", dimensions = {distribution_moisture = {0.4, 0.6}} },
      ["dirt-5"]   = { transition = "cliff", group = "dirt", dimensions = {distribution_moisture = {0.4, 0.6}} },
      ["dirt-6"]   = { transition = "cliff", group = "dirt", dimensions = {distribution_moisture = {0.4, 0.6}} },
      ["sand-1"]   = { transition = "beach", group = "sand", dimensions = {distribution_moisture = {0.0, 0.4}} },
      ["sand-2"]   = { transition = "beach", group = "sand", dimensions = {distribution_moisture = {0.0, 0.4}} },
      ["sand-3"]   = { transition = "beach", group = "sand", dimensions = {distribution_moisture = {0.0, 0.4}} },
    }
  },
  vegetation = {
    dimensions = { distribution_temperature = {0.25, 0.75}, distribution_moisture = {0.6, 1.0} },
    axes = {
      turquoise = { dimensions = {vegetation_a = {0.0, 0.2}, vegetation_b = {0.0, 0.7}} },
      green     = { dimensions = {vegetation_a = {0.2, 0.5}, vegetation_b = {0.0, 0.7}} },
      olive     = { dimensions = {vegetation_a = {0.5, 0.65}, vegetation_b = {0.0, 0.7}} },
      yellow    = { dimensions = {vegetation_a = {0.65, 0.8}, vegetation_b = {0.0, 0.7}} },
      orange    = { dimensions = {vegetation_a = {0.8, 1.0}, vegetation_b = {0.0, 0.7}} },
      red       = { dimensions = {vegetation_a = {0.8, 1.0}, vegetation_b = {0.7, 1.0}} },
      violet    = { dimensions = {vegetation_a = {0.6, 0.8}, vegetation_b = {0.7, 1.0}} },
      purple    = { dimensions = {vegetation_a = {0.4, 0.6}, vegetation_b = {0.7, 1.0}} },
      mauve     = { dimensions = {vegetation_a = {0.2, 0.4}, vegetation_b = {0.7, 1.0}} },
      blue      = { dimensions = {vegetation_a = {0.0, 0.2}, vegetation_b = {0.7, 1.0}} },
    },
    variants = {
      ["grass-1"]   = { transition = "beach", group = "grass" },
      ["grass-2"]   = { transition = "cliff", group = "grass" },
      ["grass-3"]   = { transition = "cliff", group = "grass", limit_axes = {"green"} },
      ["grass-4"]   = { transition = "cliff", group = "grass", limit_axes = {"green"} },
    }
  },
  volcanic = {
    dimensions = { distribution_temperature = {0.75, 1.0}},
    axes = {
      orange     = { dimensions = {volcanic_b = {0.0, 0.7}} },
      green      = { dimensions = {volcanic_b = {0.7, 0.8}} },
      blue       = { dimensions = {volcanic_b = {0.8, 0.9}}},
      purple     = { dimensions = {volcanic_b = {0.9, 1.0}} },
    },
    variants = {
      ["heat-1"]     = { transition = "cliff", group = "volcanic", dimensions = {volcanic_a = {0.0, 0.4}}, no_noise = true },
      ["heat-2"]     = { transition = "cliff", group = "volcanic", dimensions = {volcanic_a = {0.4, 0.7}}, no_noise = true },
      ["heat-3"]     = { transition = "cliff", group = "volcanic", dimensions = {volcanic_a = {0.7, 0.9}}, no_noise = true },
      ["heat-4"]     = { transition = "beach", group = "volcanic", dimensions = {volcanic_a = {0.9, 1.0}}, no_noise = true },
    }
  },
  frozen = {
    dimensions = { distribution_temperature = {0.0, 0.25}},
    variants = {
      ["snow-0"]   = { transition = "beach", group = "frozen", tags={"snow"} },
      ["snow-1"]   = { transition = "beach", group = "frozen", tags={"snow"} },
      ["snow-2"]   = { transition = "beach", group = "frozen", tags={"snow"} },
      ["snow-3"]   = { transition = "beach", group = "frozen", tags={"snow"} },
      ["snow-4"]   = { transition = "beach", group = "frozen", tags={"snow"}  },
      ["snow-5"]   = { transition = "cliff", group = "frozen", tags={"ice"} },
      ["snow-6"]   = { transition = "cliff", group = "frozen", tags={"ice"} },
      ["snow-7"]   = { transition = "cliff", group = "frozen", tags={"ice"} },
      ["snow-8"]   = { transition = "cliff", group = "frozen", tags={"ice"} },
      ["snow-9"]   = { transition = "cliff", group = "frozen", tags={"ice"} },
    }
  }
}
