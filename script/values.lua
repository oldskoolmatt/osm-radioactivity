local RKS = {}

function RKS.core()
	
	-- Ores
	OSM.RKS.values.ores =
	{
		["uranium-ore"] = 0.002,
		["thorium-ore"] = 0.001,
	}
	
	-- Items
	OSM.RKS.values.items =
	{
		["radium-226"] = 50,
		["radium-228"] = 50,
		["thorium-232"] = 0.01,
		["uranium-233"] = 20,
		["uranium-234"] = 10,
		["uranium-235"] = 10,
		["uranium-236"] = 15,
		["uranium-238"] = 0.02,
		["plutonium-238"] = 20,
		["plutonium-239"] = 20,
		["plutonium-241"] = 30,
		["americium-241"] = 40,
		["neptunium-237"] = 40,
		["neptunium-239"] = 25,
		["protactinium-231"] = 40,
		["polonium-210"] = 50,
		["caesium-137"] = 40,
		["iodine-131"] = 40,
		["strontium-90"] = 40,
		["zinc-65"] = 40,
		["cobalt-60"] = 40,
		["technetium-99"] = 0.02,
		["californium-252"] = 70,
		["tritium"] = 1,
	}
	
	-- Fluids
	OSM.RKS.values.fluids =
	{
		["tritium"] = 0.001,
	}
	
	-- Entities
	OSM.RKS.values.entities = {}
end

function RKS.addons()
	
	local get_table_length = OSM.utils.get_table_length
	local mod_installed = OSM.utils.mod_installed
	
	if mod_installed("osm-nucular-power") then
		OSM.RKS.values.fluids["uranium-hexafluoride"] = 0.001
		OSM.RKS.values.items["depleted-uranium"] = OSM.RKS.values.items["uranium-238"]
	end
	
	-- Madclown's nuclear compatibility
	if mod_installed("Clowns-Nuclear") then
		OSM.RKS.values.fluids["water-radioactive-waste"] = 0.4
		OSM.RKS.values.items["clowns-235"] = OSM.RKS.values.items["uranium-235"]
		OSM.RKS.values.items["uranium-235"] = OSM.RKS.values.items["uranium-235"]*0.8
	end

	-- Amator Phasma's Nuclear compatibility
	if mod_installed("apm_nuclear_ldinc") then
		OSM.RKS.values.items["apm_oxide_pellet_th232"] = OSM.RKS.values.items["thorium-232"]
		OSM.RKS.values.items["apm_oxide_pellet_u235"] = OSM.RKS.values.items["uranium-235"]
		OSM.RKS.values.items["apm_oxide_pellet_u238"] = OSM.RKS.values.items["uranium-238"]
		OSM.RKS.values.items["apm_oxide_pellet_np237"] = OSM.RKS.values.items["neptunium-237"]
		OSM.RKS.values.items["apm_oxide_pellet_pu239"] = OSM.RKS.values.items["plutonium-239"]
		OSM.RKS.values.items["apm_fuel_rod_container_worn"] =  0.2
		OSM.RKS.values.items["apm_breeder_container_worn"] =  0.2
		OSM.RKS.values.fluids["apm_radioactive_wastewater"] = 0.4
	end
	
	-- Bob's compatibility
	if mod_installed("bobplates") then
		OSM.RKS.values.items["fusion-catalyst"] = OSM.RKS.values.items["tritium"]
	end

	-- True Nukes compatibility
	if mod_installed("True-Nukes") then
		OSM.RKS.values.items["californium"] = OSM.RKS.values.items["californium-252"]
	end
end

return RKS