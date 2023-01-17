------------------
---- data.lua ----
------------------

local shielded_chest =
{
	type = "recipe",
	name = "osm-rks-shielded-chest",
	enabled = false,
	ingredients =
	{
		{"steel-plate", 15},
		{"concrete", 15}
	},
	result = "osm-rks-shielded-chest"
}	data:extend({shielded_chest})

local shielded_tank =
{
	type = "recipe",
	name = "osm-rks-shielded-tank",
	enabled = false,
	ingredients =
	{
		{"iron-plate", 20},
		{"steel-plate", 20},
		{"concrete", 20}
	},
	result = "osm-rks-shielded-tank"
}	data:extend({shielded_tank})

local hazmat_suit =
{
	type = "recipe",
	name = "osm-rks-hazmat-suit",
	enabled = false,
	ingredients =
	{
		{"plastic-bar", 35},
		{"iron-plate", 5}
	},
	result = "osm-rks-hazmat-suit"
}	data:extend({hazmat_suit})

local radiation_shield =
{
	type = "recipe",
	name = "osm-rks-radiation-shield-equipment",
	enabled = false,
	ingredients =
	{
		{"processing-unit", 5},
		{"plastic-bar", 5},
		{"steel-plate", 5},
		{"energy-shield-equipment", 1},
	},
	result = "osm-rks-radiation-shield-equipment"
}	data:extend({radiation_shield})