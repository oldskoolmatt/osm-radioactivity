------------------------------
---- control.lua/data.lua ----
------------------------------
local OSM_build = {}

function OSM_build.get_table(radiation_values)

	-- Mod values
	local tritium = 2

	-- Setup local hosts
	local table = {}
	local value = radiation_values

	-- Items
	table.items =
	{
		["tritium"] = tritium,
	}
	return table
end

return OSM_build