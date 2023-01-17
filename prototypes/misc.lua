------------------
---- data.lua ----
------------------

-- Radiation damage
local radioactive_damage =
{
	type = "damage-type",
	name = "radioactive"
}	data:extend({radioactive_damage})

-- Geiger counter sound
local geiger_sound =
{
	type = "sound",
	name = "osm-rks-geiger-sound",
	category = "alert",
	filename = "__osm-radioactivity__/sound/geiger-sound.ogg",
	volume = 0.75,
	audible_distance_modifier = 2.0,
	aggregation =
	{
		max_count = 1,
		remove = true,
		count_already_playing = true,
	}
}	data:extend({geiger_sound})
