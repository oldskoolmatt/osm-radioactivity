------------------
---- data.lua ----
------------------

local shielded_chest =
{
	type = "item",
	name = "osm-rks-shielded-chest",
	icon = "__osm-radioactivity__/graphics/icons/shielded-chest.png",
	icon_size = 64,
	icon_mipmaps = 4,
	subgroup = "storage",
	order = "a[items]-d[shielded-chest]",
	place_result = "osm-rks-shielded-chest",
	stack_size = 50
}	data:extend({shielded_chest})

local hazmat_suit =
{
	type = "armor",
	name = "osm-rks-hazmat-suit",
	icon = "__osm-radioactivity__/graphics/icons/hazmat-suit.png",
	icon_size = 64,
	icon_mipmaps = 4,
	resistances =
	{
	  {
		type = "radioactive",
		decrease = 0.5,
		percent = 80
	  }
	},
	subgroup = "armor",
	order = "a[light-armor]",
	stack_size = 1,
	infinite = true
}	data:extend({hazmat_suit})

local radiation_shield =
{
	type = "item",
	name = "osm-rks-radiation-shield-equipment",
	icon = "__osm-radioactivity__/graphics/icons/radiation-shield-equipment.png",
	icon_size = 64, 
	icon_mipmaps = 4,
	placed_as_equipment_result = "osm-rks-radiation-shield-equipment",
	subgroup = "military-equipment",
	order = "a[shield]-aA[radiation-shield-equipment]",
	default_request_amount = 5,
	stack_size = 10
}	data:extend({radiation_shield})

local shielded_tank =
{
	type = "item",
	name = "osm-rks-shielded-tank",
	icon = "__osm-radioactivity__/graphics/icons/shielded-tank.png",
	icon_size = 64,
	icon_mipmaps = 4,
	subgroup = "storage",
	order = "b[items]-e[shielded-tank]",
	place_result = "osm-rks-shielded-tank",
	stack_size = 50
}	data:extend({shielded_tank})