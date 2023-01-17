------------------
---- data.lua ----
------------------

local radiation_shield =
{
	type = "technology",
	name = "osm-rks-radiation-shield-equipment",
	icon_size = 256, icon_mipmaps = 4,
	icon = "__osm-radioactivity__/graphics/technology/radiation-shield-equipment.png",
	prerequisites = {"energy-shield-equipment", "power-armor"},
	effects =
	{
		{
			type = "unlock-recipe",
			recipe = "osm-rks-radiation-shield-equipment"
		}
	},
	unit =
	{
		count = 150,
		ingredients =
		{
			{"automation-science-pack", 1},
			{"logistic-science-pack", 1},
			{"military-science-pack", 1}
		},
		time = 15
	},
	order = "g-e-a"
}	data:extend({radiation_shield})