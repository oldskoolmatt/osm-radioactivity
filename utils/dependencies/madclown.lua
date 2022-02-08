------------------------------
---- control.lua/data.lua ----
------------------------------
local OSM_build = {}

function OSM_build.get_table(radiation_values)

	-- Mod values
	local thorium_salt = 0.0007
	local uranium_oxide = 0.002
	local uranium_depleted = 1
	local fluid_thorium_solution = 0.007
	local fluid_water_radioactive_waste = 0.4

	-- Setup local hosts
	local table = {}
	local value = radiation_values

	-- Items
	table.items =
	{
		["cobalt-60"] = value.cobalt_60,
		["polonium-210"] = value.polonium_210,
		["caesium-137"] = value.caesium_137,
		["strontium-90"] = value.strontium_90,
		["protactinium-231"] = value.protactinium_231,
		["zinc-65"] = value.zinc_65,

		["20%-uranium"] = value.uranium_235*0.2,
		["35%-uranium"] = value.uranium_235*0.35,
		["45%-uranium"] = value.uranium_235*0.45,
		["55%-uranium"] = value.uranium_235*0.55,
		["65%-uranium"] = value.uranium_235*0.65,
		["70%-uranium"] = value.uranium_235*0.7,
		["75%-uranium"] = value.uranium_235*0.75,
		["solid-uranium-oxide"] = uranium_oxide,
		["solid-uranium-tetrafluoride"] = uranium_oxide,
		["solid-uranium-hexafluoride"] = uranium_oxide,
		["processed-depleted-uranium"] = uranium_depleted*4,
		["pellet-depleted-uranium"] = uranium_depleted*3,
		["powder-depleted-uranium"] = uranium_depleted,
		["casting-powder-depleted-uranium"] = uranium_depleted,
		["clowns-plate-depleted-uranium"] = uranium_depleted,
		["thorium-salt"] = thorium_salt,
	}
	
	-- Fluids
	table.fluids =
	{
		["thorium-solution"] = fluid_thorium_solution,
		["water-radioactive-waste"] = fluid_water_radioactive_waste,
	}
	return table
end

return OSM_build