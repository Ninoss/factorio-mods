for io=0,2 do
	for employ=0,2 do
		data:extend(
			{
				{
					-- type = "optimized-decorative",
					type = "simple-entity",
					name = "effic-map-" .. io .. employ,
					flags = {"placeable-neutral", "player-creation", "not-repairable", "placeable-off-grid"},
					render_layer = "higher-object-above",
					icon = "__EfficienSee__/graphics/on-map-icon.png",
					icon_size = 32,
					order = 'y',
					pictures =
					{
						filename = "__EfficienSee__/graphics/on-map.png",
						priority = "extra-high",
						x = 32*io,
						y = 32*employ,
						width = 32,
						height = 32,
						shift = {0,0}
					}
				}
			}
		)
	end
end

