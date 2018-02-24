local noise = require("noise")
local tne = noise.to_noise_expression
--local master_scale = 5 * settings.startup["alien-biomes-terrain-scale"].value / 100 -- bigger = larger biomes
local master_scale = 4 * settings.startup["alien-biomes-terrain-scale"].value / 100 -- bigger = larger biomes

-- Note: Even though the settings can set very large range, this aonlu affects the initial noise distribution
-- the final values are still clamped to the normal range otherwise autoplace settings break
-- the reason to allow extreme settings is that you can do things like
-- 90% desert but 10% oasis by setting a normal humidity_high but a VERY low humidity_low
local temperature_low = math.min(
  settings.startup["alien-biomes-temperature-low"].value,
  settings.startup["alien-biomes-temperature-high"].value
)
local temperature_high = math.max(
  settings.startup["alien-biomes-temperature-low"].value,
  settings.startup["alien-biomes-temperature-high"].value
)
if temperature_low == temperature_high then
  temperature_low = temperature_low - 1
  temperature_high = temperature_high + 1
end

local humidity_low = math.min(
  settings.startup["alien-biomes-humidity-low"].value,
  settings.startup["alien-biomes-humidity-high"].value
) / 100
local humidity_high = math.max(
  settings.startup["alien-biomes-humidity-low"].value,
  settings.startup["alien-biomes-humidity-high"].value
) / 100
if humidity_low == humidity_high then
  humidity_low = humidity_low - 0.01
  humidity_high = humidity_high + 0.01
end

local aux_low = math.min(
  settings.startup["alien-biomes-aux-low"].value,
  settings.startup["alien-biomes-aux-high"].value
) / 100
local aux_high = math.max(
  settings.startup["alien-biomes-aux-low"].value,
  settings.startup["alien-biomes-aux-high"].value
) / 100
if aux_low == haux_high then
  aux_low = aux_low - 0.01
  aux_high = aux_high + 0.01
end

local function make_basis_noise_function(seed0,seed1,outscale0,inscale0)
  outscale0 = outscale0 or 1
  inscale0 = inscale0 or 1/outscale0
  return function(x,y,inscale,outscale)
    return tne{
      type = "function-application",
      function_name = "factorio-basis-noise",
      arguments = {
        x = tne(x),
        y = tne(y),
        seed0 = tne(seed0),
        seed1 = tne(seed1),
        input_scale = tne((inscale or 1) * inscale0),
        output_scale = tne((outscale or 1) * outscale0)
      }
    }
  end
end


-- Returns a multioctave noise function where each octave's noise is multiplied by some other noise
-- by default 'some other noise' is the basis noise at 17x lower frequency,
-- normalized around 0.5 and clamped between 0 and 1
local function make_multioctave_modulated_noise_function(params)
  local seed0 = params.seed0 or 1
  local seed1 = params.seed1 or 1
  local octave_count = params.octave_count or 1
  local octave0_output_scale = params.octave0_output_scale or 1
  local octave0_input_scale = params.octave0_input_scale or 1
  local octave_output_scale_multiplier = params.octave_output_scale_multiplier or 2
  local octave_input_scale_multiplier = params.octave_input_scale_multiplier or 1/2
  local basis_noise_function = params.basis_noise_function or make_basis_noise_function(seed0, seed1)
  local modulation_noise_function = params.modulation_noise_function or function(x,y)
    return noise.clamp(basis_noise_function(x,y)+0.5, 0, 1)
  end
  -- input scale of modulation relative to each octave's base input scale
  local mris = params.modulation_relative_input_scale or 1/17

  return function(x,y)
    local outscale = octave0_output_scale
    local inscale = octave0_input_scale
    local result = 0

    for i=1,octave_count do
      local noise = basis_noise_function(x*inscale, y*inscale)
      local modulation = modulation_noise_function(x*(inscale*mris), y*(inscale*mris))
      result = result + (outscale * noise * modulation)

      outscale = outscale * octave_output_scale_multiplier
      inscale = inscale * octave_input_scale_multiplier
    end

    return result
  end
end

local function make_multioctave_noise_function(seed0,seed1,octaves,octave_output_scale_multiplier,octave_input_scale_multiplier,output_scale0,input_scale0)
  octave_output_scale_multiplier = octave_output_scale_multiplier or 2
  octave_input_scale_multiplier = octave_input_scale_multiplier or 1 / octave_output_scale_multiplier
  return function(x,y,inscale,outscale)
    return tne{
      type = "function-application",
      function_name = "factorio-multioctave-noise",
      arguments = {
        x = tne(x),
        y = tne(y),
        seed0 = tne(seed0),
        seed1 = tne(seed1),
        input_scale = tne((inscale or 1) * (input_scale0 or 1)),
        output_scale = tne((outscale or 1) * (output_scale0 or 1)),
        octaves = tne(octaves),
        octave_output_scale_multiplier = tne(octave_output_scale_multiplier),
        octave_input_scale_multiplier = tne(octave_input_scale_multiplier),
      }
    }
  end
end


local function make_split_multioctave_noise_function(seed0,seed1,octaveses,octave_output_scale_multiplier,octave_input_scale_multiplier,output_scale0,input_scale0)
  output_scale0 = output_scale0 or 1
  input_scale0 = input_scale0 or 1
  octave_output_scale_multiplier = octave_output_scale_multiplier or 1
  octave_input_scale_multiplier = octave_input_scale_multiplier or 1
  local funx = {}
  for i=1,#octaveses do
    funx[i] = make_multioctave_noise_function(seed0,seed1,octaveses[i],octave_output_scale_multiplier,octave_input_scale_multiplier,output_scale0,input_scale0)
    output_scale0 = output_scale0 * octave_output_scale_multiplier ^ octaveses[i]
    input_scale0  = input_scale0  * octave_input_scale_multiplier  ^ octaveses[i]
  end
  return funx
end

-- Inputs to multi-octave noise to replicate 0.15 terrain
-- (ignoring that it won't match due to shifting having changed)
-- Roughness scale=0.125000, seed=9, amplitude=0.325000
-- Elevation scale=0.500000, seed=8, amplitude=6000.000000

-- TODO: Use actual noise layer indexes for seeds instead of hard-coding

data:extend({
  {
    type = "noise-expression",
    name = "default-aux",
    expression = noise.define_noise_function( function(x,y,tile,map)
      x = x * map.segmentation_multiplier + 20000 -- Move the point where 'fractal similarity' is obvious off into the boonies
      y = y * map.segmentation_multiplier
      --(seed0,seed1,octaves,octave_output_scale_multiplier,octave_input_scale_multiplier,output_scale0,input_scale0)
      --return noise.clamp(make_multioctave_noise_function(map.seed, 7, 6, 0.5, 3, 1, 1)(x,y,1/2048,1/2), 0, 1)
      -- normal range is 0-11
      --return noise.clamp(0.5 + make_multioctave_noise_function(map.seed, 7, 8, 0.5, 3, 1, 3)(x,y,1/4096/2/master_scale,0.25), 0, 1)
      return noise.clamp( noise.clamp( aux_low + (aux_high - aux_low) * (0.5 + make_multioctave_noise_function(map.seed, 7, 8, 0.45, 3, 1, 3)(x,y,1/4096/2/master_scale,0.25)), aux_low, aux_high), 0, 1)
    end)
  },
  {
    type = "noise-expression",
    name = "default-water",
    expression = noise.define_noise_function( function(x,y,tile,map)
      x = x * map.segmentation_multiplier + 80000 -- Move the point where 'fractal similarity' is obvious off into the boonies
      y = y * map.segmentation_multiplier + 20000
      --(seed0,seed1,octaves,octave_output_scale_multiplier,octave_input_scale_multiplier,output_scale0,input_scale0)
      --return noise.clamp(make_multioctave_noise_function(map.seed, 7, 6, 0.5, 3, 1, 1)(x,y,1/2048,1/2), 0, 1)
      --return noise.clamp(0.5 + make_multioctave_noise_function(map.seed, 6, 8, 0.5, 3, 1, 3)(x,y,1/4096/1/master_scale,0.25), 0, 1)
      return noise.clamp( noise.clamp( humidity_low + (humidity_high - humidity_low) * (0.5 + make_multioctave_noise_function(map.seed, 6, 8, 0.5, 3, 1, 3)(x,y,1/4096/1/master_scale,0.25)), humidity_low, humidity_high ), 0, 1)
    end)
  },
  {
    type = "noise-expression",
    name = "default-moisture",
    expression = noise.define_noise_function( function(x,y,tile,map)
      x = x * map.segmentation_multiplier + 80000-- Move the point where 'fractal similarity' is obvious off into the boonies
      y = y * map.segmentation_multiplier + 20000
      --(seed0,seed1,octaves,octave_output_scale_multiplier,octave_input_scale_multiplier,output_scale0,input_scale0)
      --return noise.clamp(make_multioctave_noise_function(map.seed, 7, 6, 0.5, 3, 1, 1)(x,y,1/2048,1/2), 0, 1)
      --return noise.clamp(0.5 + make_multioctave_noise_function(map.seed, 6, 8, 0.5, 3, 1, 3)(x,y,1/4096/1/master_scale,0.25), 0, 1)
      return noise.clamp( noise.clamp( humidity_low + (humidity_high - humidity_low) * (0.5 + make_multioctave_noise_function(map.seed, 6, 8, 0.5, 3, 1, 3)(x,y,1/4096/1/master_scale,0.25)), humidity_low, humidity_high ), 0, 1)
    end)
  },
  {
    type = "noise-expression",
    name = "default-temperature",
    expression = noise.define_noise_function( function(x,y,tile,map)
      x = x * map.segmentation_multiplier + 40000 -- Move the point where 'fractal similarity' is obvious off into the boonies
      y = y * map.segmentation_multiplier + 20000
      --(seed0,seed1,octaves,octave_output_scale_multiplier,octave_input_scale_multiplier,output_scale0,input_scale0)
      --return noise.clamp(make_multioctave_noise_function(map.seed, 7, 6, 0.5, 3, 1, 1)(x,y,1/2048,1/2), 0, 1)
      -- default is -50 to 150
      --[[
      local base = noise.clamp((make_multioctave_noise_function(map.seed, 5, 9, 0.5, 3, 1, 3)(x,y,1/4096/2/master_scale,0.25) * 200 + 40)*0.8, -50, 110) -- capped at 110
      local volcanic_area = noise.clamp(base - 100, 0, 10)
      local volcanic_hotspots = (0.5 + make_multioctave_noise_function(map.seed, 5, 7, 0.5, 3, 1, 3)(x,y,1/256,0.25)) * volcanic_area * 4 -- 0 - 40
      base = base + volcanic_hotspots -- 100 to 150
      return noise.clamp(base, -50, 150)
      ]]--
      local base = (make_multioctave_noise_function(map.seed, 5, 9, 0.5, 3, 1, 3)(x,y,1/4096/2/master_scale,0.25) * 200 + 40)*0.8
      base = (base + 50) / 200 -- convert to 0-1 range
      base = temperature_low + (temperature_high - temperature_low) * base -- shift back to settings range
      base = noise.clamp( base, -50, 110) -- clamp wihtin max extents (lava zone extends beyond to ensure volcanic hotspots)
      local volcanic_area = noise.clamp(base - 100, 0, 10)
      local volcanic_hotspots = (0.5 + make_multioctave_noise_function(map.seed, 5, 7, 0.5, 3, 1, 3)(x,y,1/256,0.25)) * volcanic_area * 4 -- 0 - 40
      base = base + volcanic_hotspots -- 100 to 150
      return noise.clamp(noise.clamp(base, temperature_low, temperature_high), -50, 150)
    end)
  },
})
