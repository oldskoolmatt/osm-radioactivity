------------------------------
---- control.lua/data.lua ----
------------------------------

local OSM_build = {}

function OSM_build.get_table(radiation_values)

	-- Setup local hosts
	local table = {}
	local value = radiation_values

	-- Ores
	table.ores =
	{
		["uranium-ore"] = value.uranium_ore
	}

	-- Items
	table.items =
	{
		["uranium-238"] = value.uranium_238,
		["uranium-235"] = value.uranium_235
	}

	-- Fuel cells
	table.fuel_cells =
	{
		"uranium-fuel-cell"
	}
	return table
end

return OSM_build