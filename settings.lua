----------------------
---- settings.lua ----
----------------------

local radiation_radius =
{
	name = "osm-rks-exposure-radius",
	type = "double-setting",
	setting_type = "startup",
	default_value = 15,
	minimum_value = 10,
	maximum_value = 30,
	order = "a"
}	data:extend({radiation_radius})

local deadly_ores =
{
	name = "osm-rks-deadly-ores",
	type = "bool-setting",
	setting_type = "startup",
	default_value = false,
	order = "b"
}	data:extend({deadly_ores})

local shielded_tank =
{
	name = "osm-rks-enable-shielded-tank",
	type = "bool-setting",
	setting_type = "startup",
	default_value = true,
	order = "c"
}	data:extend({shielded_tank})

------------------------------------

local geiger_sound =
{
	name = "osm-rks-geiger-sound",
	type = "bool-setting",
	setting_type = "runtime-per-user",
	default_value = true,
	order = "a"
}	data:extend({geiger_sound})

local display_gui =
{
	name = "osm-rks-display-gui",
	type = "string-setting",
	setting_type = "runtime-per-user",
	default_value = "always-on",
	allowed_values = {"always-on", "always-off", "dynamic"},
	order = "b"
}	data:extend({display_gui})

local move_gui =
{
	name = "osm-rks-move-gui",
	type = "bool-setting",
	setting_type = "runtime-per-user",
	default_value = true,
	order = "c"
}	data:extend({move_gui})