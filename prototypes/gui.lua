------------------
---- data.lua ----
------------------

local radiation_tooltip =
{
	type = "sprite",
	name = "osm-rks-tooltip-radioactive",
	filename = "__osm-radioactivity__/graphics/gui/tooltip-radioactive.png",
	priority = "extra-high-no-scale",
	width = 40,
	height = 40,
	flags = {"gui-icon"},
	mipmap_count = 2,
	scale = 0.5
}	data:extend({radiation_tooltip})

-- Radiation alert yellow
local radioactivity_alert =
{
	type = "item",
	name = "osm-rks-nuclear-alert",
	icons =
	{
		{	-- Prevents shadowed outline
			icon="__core__/graphics/empty.png",
			icon_size = 1,
		},
		{
			icon="__osm-radioactivity__/graphics/gui/nuclear-alert.png",
			icon_size = 64
		}
	},
	subgroup = "OSM-placeholder",
	flags = {"hidden", "hide-from-bonus-gui", "hide-from-fuel-tooltip", "not-stackable"},
	stack_size = 1
}	data:extend({radioactivity_alert})

-- Radiation alert red
local radioactivity_damage =
{
	type = "item",
	name = "osm-rks-nuclear-danger",
	icons =
	{
		{	-- Prevents shadowed outline
			icon="__core__/graphics/empty.png",
			icon_size = 1,
		},
		{
			icon="__osm-radioactivity__/graphics/gui/nuclear-danger.png",
			icon_size = 64
		}
	},
	subgroup = "OSM-placeholder",
	flags = {"hidden", "hide-from-bonus-gui", "hide-from-fuel-tooltip", "not-stackable"},
	stack_size = 1
}	data:extend({radioactivity_damage})


-- Gui background
local gui_background =
{
	type="sprite",
	name="osm-rks-gui-background",
	filename = "__osm-radioactivity__/graphics/gui/background.png",
	priority = "extra-high",
	width = 500,
	height = 500,
	flags = {"linear-magnification"},
}	data:extend({gui_background})