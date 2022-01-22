--------------------------
---- data-updates.lua ----
--------------------------

-- Setup local hosts
local OSM_local = require("utils.lib")
local OSM_table = require("control-table")
local make_description = OSM_local.make_description
local radioactive_prototypes =
{
	OSM_table.ores,
	OSM_table.items,
	OSM_table.fluids
}
local prototypes =
{
	data.raw.resource,
	data.raw.item,
	data.raw.fluid
}

-- Assign radiation values to item/entity descriptions [only for to direct sources]
for _, radioactive_prototype in pairs(radioactive_prototypes) do
	for prototype_name, radioactivity in pairs(radioactive_prototype) do
		for _, prototype in pairs(prototypes) do
			for _, type in pairs(prototype) do
				if type and type.name then	
					make_description(type, prototype, prototype_name, radioactivity)
				end
			end
		end
	end
end