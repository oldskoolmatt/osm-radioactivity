------------------
---- data.lua ----
------------------

local radiation_shield_equipment =
{
	type = "energy-shield-equipment",
	name = "osm-rks-radiation-shield-equipment",
	sprite =
	{
		filename = "__osm-radioactivity__/graphics/equipment/radiation-shield-equipment.png",
		width = 64,
		height = 64,
		priority = "medium",
		hr_version =
		{
			filename = "__osm-radioactivity__/graphics/equipment/hr-radiation-shield-equipment.png",
			width = 128,
			height = 128,
			priority = "medium",
			scale = 0.5
		}
	},
	shape =
	{
		width = 2,
		height = 2,
		type = "full"
	},
	max_shield_value = 30,
	energy_source =
	{
		type = "electric",
		buffer_capacity = "120kJ",
		input_flow_limit = "240kW",
		usage_priority = "primary-input"
	},
	energy_per_shield = "20kJ",
	categories = {"armor"}
}	data:extend({radiation_shield_equipment})