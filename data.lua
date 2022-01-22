------------------
---- data.lua ----
------------------

-- Setup local hosts
local OSM_local = require("utils.lib")
local OSM_table = require("control-table")

-- Load mod core
require("core")

-- Load prototypes
require("prototypes.entities")
require("prototypes.recipes")
require("prototypes.items")


-- Assign radiation values to item/entity descriptions [only for to direct sources]
local radioactive_ores = OSM_table.ores
local radioactive_items = OSM_table.items
local radioactive_fluids = OSM_table.fluids

-- Make descriptions for ore patches
for ore_name, radioactivity in pairs(radioactive_ores) do
	for _, resource in pairs(data.raw.resource) do
		if resource and resource.name then
			if resource.name == ore_name  then
				data.raw.resource[ore_name].localised_description = {"", "[font=default-semibold][color=#ffe6c0]Radioactivity:[/color][/font] "..radioactivity.." MilliBobs"}
			elseif resource.name == "infinite-"..ore_name then
				data.raw.resource["infinite-"..ore_name].localised_description = {"", "[font=default-semibold][color=#ffe6c0]Radioactivity:[/color][/font] "..radioactivity.." MilliBobs"}
			end
		end
	end
end

-- Make descriptions for items
for item_name, radioactivity in pairs(radioactive_items) do
	for _, item in pairs(data.raw.item) do
		if item and item.name then
			if item.name == item_name  then
				data.raw.item[item_name].localised_description = {"", "[font=default-semibold][color=#ffe6c0]Radioactivity:[/color][/font] "..radioactivity.." MilliBobs"}
			end
		end
	end
end

-- Make descriptions for fluids
for fluid_name, radioactivity in pairs(radioactive_fluids) do
	for _, fluid in pairs(data.raw.fluid) do
		if fluid and fluid.name then
			if fluid.name == fluid_name  then
				data.raw.fluid[fluid_name].localised_description = {"", "[font=default-semibold][color=#ffe6c0]Radioactivity:[/color][/font] "..radioactivity.." MilliBobs"}
			end
		end
	end
end

