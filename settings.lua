----------------------
---- settings.lua ----
----------------------

local print_millibobs =
{
	name = "osm-rad-print-millibobs",
	type = "bool-setting",
	setting_type = "runtime-global",
	default_value = false,
	order = "a"
}	data:extend({print_millibobs})

local print_exposure =
{
	name = "osm-rad-print-exposure",
	type = "bool-setting",
	setting_type = "runtime-global",
	default_value = false,
	order = "b"
}	data:extend({print_exposure})

local geiger_sound =
{
	name = "osm-rad-geiger-sound",
	type = "bool-setting",
	setting_type = "runtime-global",
	default_value = true,
	order = "c"
}	data:extend({geiger_sound})
