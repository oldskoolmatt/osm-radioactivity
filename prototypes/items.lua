------------------
---- data.lua ----
------------------

local shielded_chest =
{
	type = "item",
	name = "shielded-chest",
	icon = "__osm-radioactivity__/graphics/icons/shielded-chest.png",
	icon_size = 64,
	icon_mipmaps = 4,
	subgroup = "storage",
	order = "a[items]-d[shielded-chest]",
	place_result = "shielded-chest",
	stack_size = 50
}	data:extend({shielded_chest})

local shielded_tank =
{
	type = "item",
	name = "shielded-tank",
	icon = "__osm-radioactivity__/graphics/icons/shielded-tank.png",
	icon_size = 64,
	icon_mipmaps = 4,
	subgroup = "storage",
	order = "b[items]-e[shielded-tank]",
	place_result = "shielded-tank",
	stack_size = 50
}	data:extend({shielded_tank})

local hazmat_suit =
{
	type = "armor",
	name = "hazmat-suit",
	icon = "__osm-radioactivity__/graphics/icons/hazmat-suit.png",
	icon_size = 64,
	icon_mipmaps = 4,
	resistances =
	{
	  {
		type = "radioactive",
		decrease = 3,
		percent = 80
	  }
	},
	subgroup = "armor",
	order = "a[light-armor]",
	stack_size = 1,
	infinite = true
}	data:extend({hazmat_suit})