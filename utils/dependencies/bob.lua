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
		["thorium-ore"] = value.thorium_ore
	}

	-- Items
	table.items =
	{
		["thorium-232"] = value.thorium_232,
		["plutonium-239"] = value.plutonium_239,
		["plutonium-238"] = value.plutonium_238,
	}

	-- Fuel cells
	table.fuel_cells =
	{
		"thorium-fuel-cell",
		"plutonium-fuel-cell",
		"thorium-plutonium-fuel-cell",
		"deuterium-fuel-cell",
		"deuterium-fuel-cell-2",
	}
	return table
end

return OSM_build