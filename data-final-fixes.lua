------------------------------
---- data-final-fixes.lua ----
------------------------------

-- Setup local host
local OSM_local = require("utils.lib")
local radiation_values = require("utils.dependencies.isotope-values")
local build_radiation_table = require("utils.table-builder").build_radiation_table

-- Load dependencies
local dependencies_index =
{
	require("utils.dependencies.base").get_table(radiation_values),
	require("utils.dependencies.bob").get_table(radiation_values),
	require("utils.dependencies.angels").get_table(radiation_values),
	require("utils.dependencies.madclown").get_table(radiation_values),
	require("utils.dependencies.krastorio").get_table(radiation_values),
}

-- Setup override dependencies
local overrides_index =
{
	require("utils.overrides.angels")
}

-- Build prototypes table and assign radiation values to entity/item/fluid descriptions [only for direct sources]
local radiation_table = build_radiation_table(dependencies_index, overrides_index, OSM_local)

for ore_name, radioactivity in pairs(radiation_table.ores) do
	for _, game_ore in pairs(data.raw.resource) do
		if game_ore.name == ore_name  then
			local localised_description = {"", "[font=default-semibold][color=#ffe6c0]", {"string-name.osm-rad-tooltip"}, ": [/color][/font] ", radioactivity, " MilliBobs"}
			data.raw.resource[ore_name].localised_description = localised_description
		end
	end
end

for item_name, radioactivity in pairs(radiation_table.items) do
	for _, game_item in pairs(data.raw.item) do
		if game_item.name == item_name  then
			local localised_description = {"", "[font=default-semibold][color=#ffe6c0]", {"string-name.osm-rad-tooltip"}, ": [/color][/font] ", radioactivity, " MilliBobs"}
			data.raw.item[item_name].localised_description = localised_description
		end
	end
end

for fluid_name, radioactivity in pairs(radiation_table.fluids) do
	for _, game_fluid in pairs(data.raw.fluid) do
		if game_fluid.name == fluid_name  then
			local localised_description = {"", "[font=default-semibold][color=#ffe6c0]", {"string-name.osm-rad-tooltip"}, ": [/color][/font] ", radioactivity, " MilliBobs"}
			data.raw.fluid[fluid_name].localised_description = localised_description
		end
	end
end