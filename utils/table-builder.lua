---------------------------
---- table-builder.lua ----
---------------------------

local OSM_build = {}

-- Generate prototype radioactivity table
function OSM_build.build_radiation_table(dependencies_index, overrides_index, OSM_local)

	-- Setup local hosts
	local ores_index = {}
	local items_index = {}
	local fluids_index = {}
	local fuel_cells_index = {}
	local prototype_table = {}
	local get_fuel_cell_value = {}
	local game_ores = {}
	local game_items = {}
	local game_fluids = {}
	
	-- Setup hosts for data stage
	if data and data.raw then get_fuel_cell_value = OSM_local.data_get_fuel_cell_value end
	if data and data.raw then game_ores = data.raw.resource end
	if data and data.raw then game_items = data.raw.item end
	if data and data.raw then game_fluids = data.raw.fluid end

	-- Setup hosts for control stage
	if RKS and RKS.mod then get_fuel_cell_value = OSM_local.control_get_fuel_cell_value end
	if RKS and RKS.mod then game_ores = resource_index end
	if RKS and RKS.mod then game_items = item_index end
	if RKS and RKS.mod then game_fluids = fluid_index end

	prototype_table.ores = {}
	prototype_table.items = {}
	prototype_table.fluids = {}
	prototype_table.fuel_cells = {}
	
	-- Generate index tables
	for _, table in pairs(dependencies_index) do
		if table.ores then
			for ore, radioactivity in pairs(table.ores) do
				ores_index[ore] = radioactivity
			end
		end
		if table.items then
			for item, radioactivity in pairs(table.items) do
				items_index[item] = radioactivity
			end
		end
		if table.fluids then
			for fluid, radioactivity in pairs(table.fluids) do
				fluids_index[fluid] = radioactivity
			end
		end
		if table.fuel_cells then
			for _, fuel_cell in pairs(table.fuel_cells) do
				fuel_cells_index[fuel_cell] = 0
			end
		end
	end

	-- Push indexed entries to table
	for ore, radioactivity in pairs(ores_index) do
		prototype_table.ores[ore] = radioactivity
		prototype_table.items[ore] = radioactivity
	end

	for item, radioactivity in pairs(items_index) do
		prototype_table.items[item] = radioactivity
	end

	for fluid, radioactivity in pairs(fluids_index) do
		prototype_table.fluids[fluid] = radioactivity
	end

	for fuel_cell, radioactivity in pairs(fuel_cells_index) do
		prototype_table.fuel_cells[fuel_cell] = radioactivity
	end

	-- Mod overrides
	for _, mod in pairs(overrides_index) do
		prototype_table = mod.override(prototype_table)
	end

	-- Make radioactive barrels
	for fluid, radioactivity in pairs(prototype_table.fluids) do
		prototype_table.items[fluid.."-barrel"] = radioactivity*50
	end

	-- Make fuel cells
	prototype_table = get_fuel_cell_value(prototype_table, OSM_local)
	prototype_table.fuel_cells = nil

	-- Deadlock's stacked items	
	if settings.startup["deadlock-stack-size"] then 
		local deadlock_index = {}
		local stack_size = settings.startup["deadlock-stack-size"].value

		for item, radioactivity in pairs(prototype_table.items) do
			deadlock_index["deadlock-stack-"..item] = radioactivity*stack_size
		end

		for item, radioactivity in pairs(deadlock_index) do
			prototype_table.items[item] = radioactivity
		end
	end

	-- Clean prototype tables
	for ore_name, _ in pairs(prototype_table.ores) do
		if not game_ores[ore_name] then
			prototype_table.ores[ore_name] = nil
		end
	end
	for item_name, _ in pairs(prototype_table.items) do
		if not game_items[item_name] then
			prototype_table.items[item_name] = nil
		end
	end
	for fluid_name, _ in pairs(prototype_table.fluids) do
		if not game_fluids[fluid_name] then
			prototype_table.fluids[fluid_name] = nil
		end
	end

	-- Log table prototypes
	for ore, radioactivity in pairs(prototype_table.ores) do
		log("ORE PATCH: ... "..ore.." ... RAD: "..radioactivity)
	end
	for item, radioactivity in pairs(prototype_table.items) do
		log("ITEM: ... "..item.." ... RAD: "..radioactivity)
	end
	for fluid, radioactivity in pairs(prototype_table.fluids) do
		log("FLUID: ... "..fluid.." ... RAD: "..radioactivity)
	end

	return prototype_table
end

return OSM_build