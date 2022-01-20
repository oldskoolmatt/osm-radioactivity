------------------
---- data.lua ----
------------------

local shielded_chest =
{
	type = "recipe",
	name = "shielded-chest",
	enabled = false,
	ingredients =
	{
		{"steel-plate", 16},
		{"concrete", 16}
	},
	result = "shielded-chest"
}	data:extend({shielded_chest})

local shielded_tank =
{
	type = "recipe",
	name = "shielded-tank",
	enabled = false,
	ingredients =
	{
		{"iron-plate", 20},
		{"steel-plate", 20},
		{"concrete", 20}
	},
	result = "shielded-tank"
}	data:extend({shielded_tank})

local hazmat_suit =
{
	type = "recipe",
	name = "hazmat-suit",
	enabled = false,
	ingredients =
	{
		{"plastic", 35},
		{"iron-plate", 5}
	},
	result = "hazmat-suit"
}	data:extend({shielded_tank})


OSM.lib.technology.add_unlock("shielded-chest", "uranium-processing")
OSM.lib.technology.add_unlock("shielded-tank", "uranium-processing")
OSM.lib.technology.add_unlock("hazmat-suit", "uranium-processing")