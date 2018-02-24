

data:extend(
	{
		--------------------------------------------------------------------------------------
		{
			type = "font",
			name = "font-effic",
			from = "default",
			border = false,
			size = 14 
		},
		{
			type = "font",
			name = "font-bold-effic",
			from = "default-bold",
			border = false,
			size = 15
		},
		--------------------------------------------------------------------------------------
		{
			type = "sprite",
			name = "sprite_main_effic",
			filename = "__EfficienSee__/graphics/but-main.png",
			width = 30,
			height = 30,
		},
		{
			type = "sprite",
			name = "sprite_main_ena_effic",
			filename = "__EfficienSee__/graphics/but-main-ena.png",
			width = 26,
			height = 26,
		},
		{
			type = "sprite",
			name = "sprite_main_dis_effic",
			filename = "__EfficienSee__/graphics/but-main-dis.png",
			width = 26,
			height = 26,
		},
		{
			type = "sprite",
			name = "sprite_prev_effic",
			filename = "__EfficienSee__/graphics/but-histo-prev.png",
			width = 26,
			height = 26,
		},
		{
			type = "sprite",
			name = "sprite_next_effic",
			filename = "__EfficienSee__/graphics/but-histo-next.png",
			width = 26,
			height = 26,
		},
		{
			type = "sprite",
			name = "sprite_res_ok_effic",
			filename = "__EfficienSee__/graphics/but-res-ok.png",
			width = 26,
			height = 26,
		},
		{
			type = "sprite",
			name = "sprite_res_no_effic",
			filename = "__EfficienSee__/graphics/but-res-no.png",
			width = 26,
			height = 26,
		},
		{
			type = "sprite",
			name = "sprite_map_toggle_effic",
			filename = "__EfficienSee__/graphics/but-map-toggle.png",
			width = 26,
			height = 26,
		},
		{
			type = "sprite",
			name = "sprite_map_toggle_off_effic",
			filename = "__EfficienSee__/graphics/but-map-toggle-off.png",
			width = 26,
			height = 26,
		},
		{
			type = "sprite",
			name = "sprite_map_toggle_on_effic",
			filename = "__EfficienSee__/graphics/but-map-toggle-on.png",
			width = 26,
			height = 26,
		},
		--------------------------------------------------------------------------------------
		{
			type = "sprite",
			name = "sprite_clock_effic",
			filename = "__EfficienSee__/graphics/ico-clock.png",
			width = 32,
			height = 32,
		},	
		{
			type = "sprite",
			name = "sprite_base_effic",
			filename = "__EfficienSee__/graphics/ico-techno-base.png",
			width = 32,
			height = 32,
		},	
		{
			type = "sprite",
			name = "sprite_ingr_effic",
			filename = "__EfficienSee__/graphics/ico-ingr.png",
			width = 20,
			height = 32,
		},
		{
			type = "sprite",
			name = "sprite_prod_effic",
			filename = "__EfficienSee__/graphics/ico-prod.png",
			width = 20,
			height = 32,
		},
		{
			type = "sprite",
			name = "sprite_ass_effic",
			filename = "__EfficienSee__/graphics/ico-assemblers.png",
			width = 32,
			height = 32,
		},
		{
			type = "sprite",
			name = "sprite_furn_effic",
			filename = "__EfficienSee__/graphics/ico-furnaces.png",
			width = 32,
			height = 32,
		},
	}
)


--------------------------------------------------------------------------------------
local default_gui = data.raw["gui-style"].default

default_gui.frame_effic_style = 
{
	type="frame_style",
	parent="frame",
	top_padding = 2,
	right_padding = 2,
	bottom_padding = 2,
	left_padding = 2,
	resize_row_to_width = true,
	-- resize_row_to_width = false,
	resize_to_row_height = false,
	-- max_on_row = 1,
	graphical_set =
	{
		type = "composition",
		filename = "__core__/graphics/gui.png",
		priority = "extra-high-no-scale",
		corner_size = {3, 3},
		position = {0, 0}
	},
}

default_gui.frame_in_effic_style = 
{
	type="frame_style",
	parent="frame_effic_style",
	resize_row_to_width = true,
	max_on_row = 1,
}

default_gui.flow_main_effic_style = 
{
	type = "vertical_flow_style",
	
	top_padding = 0,
	bottom_padding = 0,
	left_padding = 0,
	right_padding = 0,
	
	horizontal_spacing = 0,
	vertical_spacing = 0,
	resize_row_to_width = true,
	resize_to_row_height = false,
	max_on_row = 1,
	
	graphical_set = { type = "none" },
}

default_gui.flow_effic_style = 
{
	type = "vertical_flow_style",
	parent="flow_main_effic_style",
	
	horizontal_spacing = 3,
	vertical_spacing = 3,
	resize_row_to_width = true,
	resize_to_row_height = false,
	max_on_row = 1,
	
	graphical_set = { type = "none" },
}

default_gui.flow_line_effic_style = 
{
	type = "horizontal_flow_style",
	
	top_padding = 0,
	bottom_padding = 0,
	left_padding = 0,
	right_padding = 0,
	
	horizontal_spacing = 3,
	vertical_spacing = 0,
	resize_to_row_height = false,
	resize_to_row_height = false,
	max_on_row = 1,
	align = "center",

	graphical_set = { type = "none" },
}

default_gui.scroll_pane_effic_style =
{
	type = "scroll_pane_style",
	parent="scroll_pane",
	-- flow_style =
	-- {
		-- parent = "flow"
	-- },
	resize_row_to_width = true,
	resize_to_row_height = false,
	max_on_row = 1,
}

default_gui.table_effic_style =
{
	type = "table_style",
	parent = "table"
}

default_gui.table_effic_list_style =
{
	type = "table_style",
	horizontal_spacing = 3,
	vertical_spacing = 3,
	-- resize_row_to_width = true,
	resize_row_to_width = false,
	resize_to_row_height = false,
	-- max_on_row = 1,
}

--------------------------------------------------------------------------------------
default_gui.label_effic_style =
{
	type="label_style",
	parent="label",
	font="font-effic",
	align = "left",
	font_color={r=1, g=1, b=1},
	top_padding = 1,
	right_padding = 3,
	bottom_padding = 0,
	left_padding = 1,
}

default_gui.label_numw_effic_style =
{
	type="label_style",
	parent="label_effic_style",
	font="font-effic",
	minimal_width = 60,
	font_color={r=1, g=1, b=1},
}

default_gui.label_numg_effic_style =
{
	type="label_style",
	parent="label_numw_effic_style",
	font_color={r=0.7, g=0.7, b=0.7},
}

default_gui.label_bold_effic_style =
{
	type="label_style",
	parent="label_effic_style",
	font="font-bold-effic",
}

default_gui.textfield_effic_style =
{
    type = "textfield_style",
	font="font-effic",
	align = "left",
    font_color = {},
	default_font_color={r=1, g=1, b=1},
	hovered_font_color={r=1, g=1, b=1},
    selection_background_color= {r=0.66, g=0.7, b=0.83},
	top_padding = 0,
	bottom_padding = 0,
	left_padding = 1,
	right_padding = 1,
	minimal_width = 50,
	maximal_width = 200,
	graphical_set =
	{
		type = "composition",
		filename = "__core__/graphics/gui.png",
		priority = "extra-high-no-scale",
		corner_size = {3, 3},
		position = {16, 0}
	},
}    

default_gui.button_effic_style = 
{
	type="button_style",
	parent="button",
	font="font-bold-effic",
	align = "center",
	default_font_color={r=1, g=1, b=1},
	hovered_font_color={r=1, g=1, b=1},
	top_padding = 0,
	right_padding = 0,
	bottom_padding = 0,
	left_padding = 0,
	minimal_heigth = 32,
	heigth = 32,
	scalable = false,
	left_click_sound =
	{
		{
		  filename = "__core__/sound/gui-click.ogg",
		  volume = 1
		}
	},
}

default_gui.checkbox_effic_style =
{
	type = "checkbox_style",
	parent="checkbox",
	font = "font-effic",
	font_color = {r=1, g=1, b=1},
}

default_gui.sprite_obj_effic_style = 
{
	type="button_style",
	parent="button",
	top_padding = 0,
	right_padding = 0,
	bottom_padding = 0,
	left_padding = 0,
	height = 32,
	width = 32,
	scalable = false,
	default_graphical_set = extract_monolith("__EfficienSee__/graphics/gui.png", 0, 0, 32, 32),
	hovered_graphical_set = extract_monolith("__EfficienSee__/graphics/gui.png", 32, 0, 32, 32),
	clicked_graphical_set = extract_monolith("__EfficienSee__/graphics/gui.png", 64, 0, 32, 32),
	disabled_graphical_set = extract_monolith("__EfficienSee__/graphics/gui.png", 0, 0, 32, 32),
}

default_gui.sprite_tec_effic_style = 
{
	type="button_style",
	parent="button",
	top_padding = 0,
	right_padding = 0,
	bottom_padding = 0,
	left_padding = 0,
	height = 32,
	width = 32,
	scalable = false,
	default_graphical_set = extract_monolith("__EfficienSee__/graphics/gui.png", 0, 32, 32, 32),
	hovered_graphical_set = extract_monolith("__EfficienSee__/graphics/gui.png", 32, 32, 32, 32),
	clicked_graphical_set = extract_monolith("__EfficienSee__/graphics/gui.png", 64, 32, 32, 32),
	disabled_graphical_set = extract_monolith("__EfficienSee__/graphics/gui.png", 0, 32, 32, 32),
}

default_gui.sprite_group_effic_style = 
{
	type="button_style",
	parent="button",
	top_padding = 0,
	right_padding = 0,
	bottom_padding = 0,
	left_padding = 0,
	width = 64,
	height = 64,
	scalable = false,
	default_graphical_set = extract_monolith("__EfficienSee__/graphics/gui.png", 0, 0, 32, 32),
	hovered_graphical_set = extract_monolith("__EfficienSee__/graphics/gui.png", 0, 0, 32, 32),
	clicked_graphical_set = extract_monolith("__EfficienSee__/graphics/gui.png", 0, 0, 32, 32),
	disabled_graphical_set = extract_monolith("__EfficienSee__/graphics/gui.png", 0, 0, 32, 32),
}

default_gui.sprite_icon_effic_style = 
{
	type="button_style",
	parent="button",
	top_padding = 0,
	right_padding = 0,
	bottom_padding = 0,
	left_padding = 0,
	width = 32,
	height = 32,
	scalable = false,
	default_graphical_set = extract_monolith("__EfficienSee__/graphics/gui.png", 0, 0, 32, 32),
	hovered_graphical_set = extract_monolith("__EfficienSee__/graphics/gui.png", 0, 0, 32, 32),
	clicked_graphical_set = extract_monolith("__EfficienSee__/graphics/gui.png", 0, 0, 32, 32),
	disabled_graphical_set = extract_monolith("__EfficienSee__/graphics/gui.png", 0, 0, 32, 32),
}

default_gui.sprite_ingr_effic_style = 
{
	type="button_style",
	parent="button",
	top_padding = 0,
	right_padding = 0,
	bottom_padding = 0,
	left_padding = 0,
	width = 20,
	height = 32,
	scalable = false,
	default_graphical_set = { type = "none" },
	hovered_graphical_set = { type = "none" },
	clicked_graphical_set = { type = "none" },
	disabled_graphical_set = { type = "none" },
}

default_gui.sprite_main_effic_style = 
{
	type="button_style",
	parent="button",
	top_padding = 0,
	right_padding = 0,
	bottom_padding = 0,
	left_padding = 0,
	height = 36,
	width = 36,
	scalable = false,
}

default_gui.sprite_act_effic_style = 
{
	type="button_style",
	parent="button",
	top_padding = 0,
	right_padding = 0,
	bottom_padding = 0,
	left_padding = 0,
	height = 32,
	width = 32,
	scalable = false,
}

