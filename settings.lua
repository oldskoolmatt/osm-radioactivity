----------------------
---- settings.lua ----
----------------------

local radiation_radius =
{
	name = "osm-rad-exposure-radius",
	type = "double-setting",
	setting_type = "startup",
	default_value = 15,
	minimum_value = 10,
	maximum_value = 30,
	order = "a"
}	data:extend({radiation_radius})

local print_millibobs =
{
	name = "osm-rad-print-millibobs",
	type = "bool-setting",
	setting_type = "runtime-global",
	default_value = true,
	order = "a"
}	data:extend({print_millibobs})

local geiger_sound =
{
	name = "osm-rad-geiger-sound",
	type = "bool-setting",
	setting_type = "runtime-global",
	default_value = true,
	order = "b"
}	data:extend({geiger_sound})
