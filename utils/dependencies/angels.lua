------------------------------
---- control.lua/data.lua ----
------------------------------

local OSM_build = {}

function OSM_build.get_table(radiation_values)

	-- Mod values
	local angels_ore = 0.00025
	
	-- Hosts
	local table = {}
	local value = radiation_values
	
	-- Ores
	table.ores =
	{
		["angels-ore3"] = angels_ore,
		["angels-ore5"] = angels_ore,
	}
	
	-- Items
	table.items =
	{
		["angels-ore3-crushed"] = angels_ore,
		["angels-ore5-crushed"] = angels_ore,
		["angels-ore3-chunk"] = angels_ore,
		["angels-ore5-chunk"] = angels_ore,
		["angels-ore3-crystal"] = angels_ore,
		["angels-ore5-crystal"] = angels_ore,
		["angels-ore3-pure"] = angels_ore,
		["angels-ore5-pure"] = angels_ore,
	}
	return table
end

return OSM_build