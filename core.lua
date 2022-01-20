------------------
---- data.lua ----
------------------

local damage_type = data.raw["damage-type"]

-- Radiation damage
if not damage_type["radioactive"] then
	local damage =
	{
		type = "damage-type",
		name = "radioactive"
	}	data:extend({damage})
end

-- Radiation alert yellow
local radioactivity_alert =
{
	type = "virtual-signal",
	name = "nuclear-alert",
	icon = "__osm-radioactivity__/graphics/alerts/nuclear-alert.png",
	icon_size = 64
}	data:extend({radioactivity_alert})

-- Radiation alert red
local radioactivity_damage =
{
	type = "virtual-signal",
	name = "nuclear-damage",
	icon = "__osm-radioactivity__/graphics/alerts/nuclear-damage.png",
	icon_size = 64
}	data:extend({radioactivity_damage})

-- Geiger counter sound
local geiger_counter =
{
	type = "sound",
	name = "geiger-counter",
	category = "alert",
	filename = "__osm-radioactivity__/sound/geiger-counter.ogg",
	volume = 0.75,
	audible_distance_modifier = 2.0,
	aggregation =
	{
		max_count = 1,
		remove = true,
		count_already_playing = true,
	}
}	data:extend({geiger_counter})