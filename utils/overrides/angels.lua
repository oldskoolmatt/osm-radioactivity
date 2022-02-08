---------------------------
---- table-builder.lua ----
---------------------------

local OSM_override = {}

function OSM_override.override(prototype_table)
	local index_ores = {}
	local index_items = {}
	local index_fluids = {}
	
	-- Infinite ores
	for ore, radioactivity in pairs(prototype_table.ores) do
		index_ores["infinite-"..ore] = radioactivity
	end
	for ore, radioactivity in pairs(index_ores) do
		prototype_table.ores[ore] = radioactivity
	end
	
	-- Refining fluids
	for fluid, radioactivity in pairs(prototype_table.fluids) do
		index_fluids["gas-"..fluid] = radioactivity
		index_fluids["liquid-"..fluid] = radioactivity
	end
	for fluid, radioactivity in pairs(index_fluids) do
		prototype_table.fluids[fluid] = radioactivity
	end
	
	return prototype_table
end

return OSM_override