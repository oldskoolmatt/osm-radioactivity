---------------------------
---- table-builder.lua ----
---------------------------

local RKS = {}

-- Generate prototype radioactivity table
function RKS.core()

	local get_table_length = OSM.utils.get_table_length
	local prototype_is_candidate = OSM.RKS.utils.prototype_is_candidate
	local prototype_is_allowed = OSM.RKS.utils.prototype_is_allowed
	local radiation_index = OSM.RKS.utils.get_radiation_index
	local value_can_be_edited = OSM.RKS.utils.value_can_be_edited
	local finalise_radiation_table = OSM.RKS.utils.finalise_radiation_table
	local make_description = OSM.RKS.utils.make_description

	local game_data = {}
	game_data.recipe = {}
	game_data.resource = {}
	game_data.fluid = {}
	game_data.item = {}
	game_data.entity = {}
	
	local radiation_table = {}
	radiation_table.ore = {}
	radiation_table.item = {}
	radiation_table.fluid = {}
	radiation_table.entity = {}

	local leftover_candidates = {}
	leftover_candidates.item = {}
	leftover_candidates.fluid = {}

	local candidate_index = {}

	local attempts = 0
	local old_index = 0
	local new_index = 0
	
	-- Set variables
	if OSM.data_stage then

		game_data.recipe = data.raw.recipe

		for _, fluid in pairs(data.raw.fluid) do
			
			game_data.fluid[fluid.name] = {}
			game_data.fluid[fluid.name].name = fluid.name
			game_data.fluid[fluid.name].type = "fluid"

			if prototype_is_candidate(game_data.fluid[fluid.name]) then
				candidate_index[fluid.name] = true
			end
		end
		for item_type, _ in pairs(OSM.data.item) do
			for _, item in pairs(data.raw[item_type]) do

				game_data.item[item.name] = {}
				game_data.item[item.name].name = item.name
				game_data.item[item.name].type = item.type
				if item.place_result then
					game_data.item[item.name].place_result = item.place_result
				end

				if prototype_is_candidate(game_data.item[item.name]) then
					candidate_index[item.name] = true
				end
			end
		end
		for entity_type, _ in pairs(OSM.data.entity) do
			for _, entity in pairs(data.raw[entity_type]) do
				if entity.type == "resource" then

					game_data.resource[entity.name] = {}
					game_data.resource[entity.name].name = entity.name
					game_data.resource[entity.name].type = "resource"

					if prototype_is_candidate(game_data.resource[entity.name]) then
						candidate_index[entity.name] = true
					end
				else

					game_data.entity[entity.name] = {}
					game_data.entity[entity.name].name = entity.name
					game_data.entity[entity.name].type = entity.type
			
					if entity.minable and entity.minable.result then
						game_data.entity[entity.name].mineable_products = {}
						table.insert(game_data.entity[entity.name].mineable_products, {name=entity.minable.result, amount=1})

					elseif entity.minable and entity.minable.results then
						game_data.entity[entity.name].mineable_products = entity.minable.results
					end
					
					if prototype_is_candidate(game_data.entity[entity.name]) then
						candidate_index[entity.name] = true
					end
				end
			end
		end
	end
	
	if OSM.control_stage then

		game_data.recipe = game.recipe_prototypes

		for _, fluid in pairs(game.fluid_prototypes) do
			if fluid.valid then
			
				game_data.fluid[fluid.name] = {}
				game_data.fluid[fluid.name].name = fluid.name
				game_data.fluid[fluid.name].type = "fluid" -- FUCK YOU DEVS!!!

				if prototype_is_candidate(game_data.fluid[fluid.name]) then
					candidate_index[fluid.name] = true
				end
			end
		end
		for _, item in pairs(game.item_prototypes) do
			if item.valid then
				
				game_data.item[item.name] = {}
				game_data.item[item.name].name = item.name
				game_data.item[item.name].type = item.type
				if item.place_result then
					game_data.item[item.name].place_result = item.place_result.name
				end

				if prototype_is_candidate(game_data.item[item.name]) then
					candidate_index[item.name] = true
				end
			end
		end
		for _, entity in pairs(game.entity_prototypes) do
			if entity.valid then
				if entity.type == "resource" then

					game_data.resource[entity.name] = {}
					game_data.resource[entity.name].name = entity.name
					game_data.resource[entity.name].type = "resource"

					if prototype_is_candidate(game_data.resource[entity.name]) then
						candidate_index[entity.name] = true
					end
				else

					game_data.entity[entity.name] = {}
					game_data.entity[entity.name].name = entity.name
					game_data.entity[entity.name].type = entity.type
					if entity.mineable_properties and entity.mineable_properties.products then
						game_data.entity[entity.name].mineable_products = entity.mineable_properties.products
					end	
	
					if prototype_is_candidate(game_data.entity[entity.name]) then
						candidate_index[entity.name] = true
					end
				end
			end
		end
	end

	-- Get radiation values
	OSM.RKS.values.core()
	OSM.RKS.values.addons()

	-- Push values to radiation table
	for ore, radioactivity in pairs(OSM.RKS.values.ores) do
		OSM.RKS.values.items[ore] = radioactivity
		if game_data.resource[ore] then
			radiation_table.ore[ore] = radioactivity
		end
	end
	for item, radioactivity in pairs(OSM.RKS.values.items) do
		if game_data.item[item] then
			radiation_table.item[item] = radioactivity
		end
	end
	for fluid, radioactivity in pairs(OSM.RKS.values.fluids) do
		if game_data.fluid[fluid] then
			radiation_table.fluid[fluid] = radioactivity
		end
	end
	for entity, radioactivity in pairs(OSM.RKS.values.entities) do
		if game_data.entity[entity] then
			radiation_table.entity[entity] = radioactivity
		end
	end

	-- Push values to availability index
	for _, index in pairs(radiation_table) do
		for prototype, _ in pairs(index) do
			candidate_index[prototype] = true
		end
	end

	-- Assign values to items and fluids
	local function generate_radiation_table()
		
		::retry::
		attempts = attempts+1
		
		OSM.RKS.build.addons(radiation_table, candidate_index)

		old_index = radiation_index(radiation_table)
	
		-- Scan game prototypes
		for _, recipe in pairs(game_data.recipe) do
			local recipe_difficulty = {recipe}
			local recipe_name = recipe.name
	
			if OSM.data_stage and recipe.normal then table.insert(recipe_difficulty, recipe.normal) end
			if OSM.data_stage and recipe.expensive then table.insert(recipe_difficulty, recipe.expensive) end
	
			for _, recipe in pairs(recipe_difficulty) do

				local ingredients_radioactivity = 0
				local results_radioactivity = 0

				local recipe_result = {}
				local recipe_results = {}
				local recipe_ingredients = {}
				
				if OSM.data_stage then
					recipe_result = recipe.result
					recipe_results = recipe.results
					recipe_ingredients = recipe.ingredients
				elseif OSM.control_stage then
					recipe_result = nil
					recipe_results = recipe.products
					recipe_ingredients = recipe.ingredients
				end
				
				---- GET VALUES FROM INGREDIENTS ----
				
				-- Get total radiation value from known radioactive ingredients
				if recipe_ingredients then
					for _, ingredient in pairs(recipe_ingredients) do
		
						local ingredient_name = ingredient.name or ingredient[1]
						local ingredient_amount = ingredient.amount or ingredient[2]
						
						local radioactive_ingredient = radiation_table.item[ingredient_name] or radiation_table.fluid[ingredient_name]
						
						if radioactive_ingredient then
							ingredients_radioactivity = radioactive_ingredient*ingredient_amount+ingredients_radioactivity
						end
					end
				end
		
				-- Generate single results radiation values
				if recipe_results then
					for _, result in pairs(recipe_results) do
							
						local result_name = result.name or result[1]
						local result_amount = result.amount or result[2]
						local result_probability = result.probability or 1
						
						if result.amount_max and result.amount_min then
							result_amount = (result.amount_max+result.amount_min)/2
						end
						
						result_amount = result_amount*result_probability
						
						local result_type = result.type or "item"
						local radioactivity = ingredients_radioactivity/result_amount
						
						if radiation_table.item[result_name] and radiation_table.item[result_name] >= radioactivity then goto skip_1 end
						if radiation_table.fluid[result_name] and radiation_table.fluid[result_name] >= radioactivity then goto skip_1 end
						
						if candidate_index[result_name] and value_can_be_edited(result_name) and radioactivity > 0 then
							
							-- Single radioactive product among results
							if get_table_length(recipe_results) >= 1 then
		
								local count = 0
								local known_radioactivity = 0
								
								for _, prototype in pairs(recipe_results) do
		
									local prototype_name = prototype.name or prototype[1]
		
									if candidate_index[prototype_name] then
										if not radiation_table.item[prototype_name] and not radiation_table.fluid[prototype_name] then
											count = count+1
										end
										if get_table_length(recipe_results) == 1 then count = 1 end
									end
								end
								
								if count == 1 then
									if result_type == "item" and prototype_is_allowed(game_data.item[result_name]) then
										radiation_table.item[result_name] = radioactivity
										if game_data.item[result_name].place_result then
											
											local entity_name = game_data.item[result_name].place_result
											
											if prototype_is_allowed(game_data.entity[entity_name]) then
												radiation_table.entity[entity_name] = radioactivity
											end
										end
									elseif result_type == "fluid" and prototype_is_allowed(game_data.fluid[result_name]) then
										radiation_table.fluid[result_name] = radioactivity
									end
								end					
							end	
						end
						
						-- Look for missing items/fluids
						if candidate_index[result_name] and value_can_be_edited(result_name) then 
							if not radiation_table.item[result_name] and not radiation_table.fluid[result_name] then
								leftover_candidates[result_type][result_name] = true
							end
						end
					end
		
				elseif recipe_result then
		
					local result_name = recipe.result
					local result_amount = recipe.result_count or 1
					
					local radioactivity = ingredients_radioactivity/result_amount
					
					if radiation_table.item[result_name] and radiation_table.item[result_name] >= radioactivity then goto skip_1 end
					if radiation_table.fluid[result_name] and radiation_table.fluid[result_name] >= radioactivity then goto skip_1 end
					
					if candidate_index[result_name] and value_can_be_edited(result_name) and radioactivity > 0 then
						radiation_table.item[result_name] = radioactivity
						if game_data.item[result_name].place_result then
		
							local entity_name = game_data.item[result_name].place_result
		
							radiation_table.entity[entity_name] = radioactivity
						end
					end
		
					-- Look for missing items/fluids
					if candidate_index[result_name] and value_can_be_edited(result_name) then 
						if not radiation_table.item[result_name] and not radiation_table.fluid[result_name] then
							leftover_candidates.item[result_name] = true
						end
					end
				end

				::skip_1::
				
				new_index = radiation_index(radiation_table)
		
				if old_index ~= new_index then goto skip_2 end

				---- GET VALUES FROM RESULTS ----
				
				-- Get total radiation value from known radioactive results
				if recipe_results then
					for _, result in pairs(recipe_results) do
		
						local result_name = result.name or result[1]
						local result_amount = result.amount or result[2]
						local result_probability = result.probability or 1
						
						if result.amount_max and result.amount_min then
							result_amount = (result.amount_max+result.amount_min)/2
						end
						
						result_amount = result_amount*result_probability
						
						local radioactive_result = radiation_table.item[result_name] or radiation_table.fluid[result_name]
						
						if radioactive_result then
							results_radioactivity = radioactive_result*result_amount+results_radioactivity
						end
					end
				end

				-- Generate single ingredients radiation values
				if recipe_ingredients then
					for _, ingredient in pairs(recipe_ingredients) do
							
						local ingredient_name = ingredient.name or ingredient[1]
		
						local ingredient_amount = ingredient.amount or ingredient[2]
						local ingredient_type = ingredient.type or "item"
						local radioactivity = results_radioactivity/ingredient_amount
						
						if radiation_table.item[ingredient_name] then goto skip_2 end
						if radiation_table.fluid[ingredient_name] then goto skip_2 end
						
						if candidate_index[ingredient_name] and value_can_be_edited(ingredient_name) and radioactivity > 0 then
							
							-- Single radioactive ingredient among ingredients
							if get_table_length(recipe_ingredients) >= 1 then
		
								local count = 0
								local known_radioactivity = 0
								
								for _, prototype in pairs(recipe_ingredients) do
		
									local prototype_name = prototype.name or prototype[1]
		
									if candidate_index[prototype_name] then
										if not radiation_table.item[prototype_name] and not radiation_table.fluid[prototype_name] then
											count = count+1
										end
										if get_table_length(recipe_ingredients) == 1 then count = 1 end
									end
								end
								
								if count == 1 then
									if ingredient_type == "item" and prototype_is_allowed(game_data.item[ingredient_name]) then
										radiation_table.item[ingredient_name] = radioactivity
										if game_data.item[ingredient_name].place_result then
											
											local entity_name = game_data.item[ingredient_name].place_result
											
											if prototype_is_allowed(game_data.entity[entity_name]) then
												radiation_table.entity[entity_name] = radioactivity
											end
										end
									elseif ingredient_type == "fluid" and prototype_is_allowed(game_data.fluid[ingredient_name]) then
										radiation_table.fluid[ingredient_name] = radioactivity
									end
								end
							end	
						end
						
						-- Look for missing items/fluids
						if candidate_index[ingredient_name] and value_can_be_edited(ingredient_name) then 
							if not radiation_table.item[ingredient_name] and not radiation_table.fluid[ingredient_name] then
								leftover_candidates[ingredient_type][ingredient_name] = true
							end
						end
					end
				end
				
				::skip_2::
				
				-- Append mod extensions
				OSM.RKS.build.fixes(radiation_table, candidate_index)
				
				for i, index in pairs(leftover_candidates) do
					for prototype, _ in pairs(index) do
						if radiation_table[i][prototype] then leftover_candidates[i][prototype] = nil end
					end
				end
			end
		end

		new_index = radiation_index(radiation_table)

		if old_index ~= new_index then goto retry end

		-- Make missing entities
		for _, entity in pairs(game_data.entity) do
			if entity.mineable_products then

				local products_radioactivity = 0

				for _, product in pairs(entity.mineable_products) do

					local product_name = product.name or product[1]
					local product_amount = product.amount_max or product.amount or product[2]
					local product_probability = product.probability or 1

					local radioactive_product = radiation_table.item[product_name] or radiation_table.fluid[product_name]
					
					if radioactive_product then
						products_radioactivity = radioactive_product*product_amount*product_probability+products_radioactivity
					end
				end
				
				if products_radioactivity > 0 then
					radiation_table.entity[entity.name] = products_radioactivity
				end
			end
		end

		finalise_radiation_table(radiation_table, game_data)
	end

	-- Build radiation table

	generate_radiation_table()

	-- Finalise
	for ore_name, radioactivity in pairs(radiation_table.ore) do
		if game_data.resource[ore_name] and radioactivity > 0 then 
			if OSM.data_stage then
				make_description(OSM.lib.get_resource_prototype(ore_name))

			elseif OSM.control_stage then
				global.radioactive_ores[ore_name] = {}
				global.radioactive_ores[ore_name].radioactivity = radioactivity
				global.radioactive_ores[ore_name].name = ore_name
				global.radioactive_ores[ore_name].type = game_data.resource[ore_name].type
			end
		end
	end

	for item_name, radioactivity in pairs(radiation_table.item) do
		if game_data.item[item_name] and radioactivity > 0 then
			if OSM.data_stage then
				make_description(OSM.lib.get_item_prototype(item_name))

			elseif OSM.control_stage then
				global.radioactive_items[item_name] = {}
				global.radioactive_items[item_name].radioactivity = radioactivity
				global.radioactive_items[item_name].name = item_name
				global.radioactive_items[item_name].type = game_data.item[item_name].type
			end
		end
	end
	
	for fluid_name, radioactivity in pairs(radiation_table.fluid) do
		if game_data.fluid[fluid_name] and radioactivity > 0 then
			if OSM.data_stage then
				make_description(OSM.lib.get_fluid_prototype(fluid_name))

			elseif OSM.control_stage then
				global.radioactive_fluids[fluid_name] = {}
				global.radioactive_fluids[fluid_name].radioactivity = radioactivity
				global.radioactive_fluids[fluid_name].name = fluid_name
				global.radioactive_fluids[fluid_name].type = game_data.fluid[fluid_name].type
			end
		end
	end
	
	for entity_name, radioactivity in pairs(radiation_table.entity) do
		if game_data.entity[entity_name] and radioactivity > 0 then
			if OSM.data_stage then 
				make_description(OSM.lib.get_entity_prototype(entity_name))

			elseif OSM.control_stage then
				global.radioactive_entities[entity_name] = {}
				global.radioactive_entities[entity_name].radioactivity = radioactivity 
				global.radioactive_entities[entity_name].name = entity_name 
				global.radioactive_entities[entity_name].type = game_data.entity[entity_name].type 
			end
		end
	end

	-- Output log
	if OSM.control_stage then
	
		global.radioactive_ores_size = get_table_length(global.radioactive_ores) or 0
		global.radioactive_items_size = get_table_length(global.radioactive_items) or 0
		global.radioactive_fluids_size = get_table_length(global.radioactive_fluids) or 0
		global.radioactive_entities_size = get_table_length(global.radioactive_entities) or 0
		
		
		local total = global.radioactive_ores_size+global.radioactive_items_size+global.radioactive_fluids_size+global.radioactive_entities_size
	
		log("----------------------------------------------------------------------")
		log("--- Generated: "..total.." radiation values...")
		log("--- In: "..attempts.. " script cycles!")
		log("----------------------------------------------------------------------")
		for i, index in pairs(radiation_table) do
			for prototype, radioactivity in pairs(index) do
				log("Info: "..i..": "..'"'..prototype..'"'.." radioactivity level: "..radioactivity)
			end
		end

		log("----------------------------------------------------------------------")
		log("--- Looking for leftovers...")
		log("--- The following prototypes are NOT radioactive!")
		log("----------------------------------------------------------------------")
		if get_table_length(leftover_candidates) > 0 then
			for i, index in pairs(leftover_candidates) do
				for prototype, _ in pairs(index) do
					log("Info: "..i..": "..'"'..prototype..'"'.." does not seem to be radioactive!")
				end
			end
		end
		
		if OSM.debug_mode then
			log("----------------------------------------------------------------------")
			log("--- Complete list of radioactive candidates...")
			log("--- DEBUG MODE")
			log("----------------------------------------------------------------------")
			for candidate, _ in pairs(candidate_index) do
				log("Info: "..'"'..candidate..'"'.." is candidate")
			end
		end
	end
end

function RKS.addons(radiation_table, candidate_index)

	local get_table_length = OSM.utils.get_table_length
	local mod_installed = OSM.utils.mod_installed
	
	-- Base
	candidate_index["nuclear-reactor"] = false

	-- Madclown's nuclear compatibility
	if mod_installed("Clowns-Nuclear") then
		radiation_table.item["20%-uranium"] = OSM.RKS.values.items["clowns-235"]*0.2
		radiation_table.item["35%-uranium"] = OSM.RKS.values.items["clowns-235"]*0.35
		radiation_table.item["45%-uranium"] = OSM.RKS.values.items["clowns-235"]*0.45
		radiation_table.item["55%-uranium"] = OSM.RKS.values.items["clowns-235"]*0.55
		radiation_table.item["65%-uranium"] = OSM.RKS.values.items["clowns-235"]*0.65
		radiation_table.item["70%-uranium"] = OSM.RKS.values.items["clowns-235"]*0.7
		radiation_table.item["75%-uranium"] = OSM.RKS.values.items["clowns-235"]*0.75
	end

	-- Amator Phasma's Nuclear compatibility
	if mod_installed("apm_nuclear_ldinc") then

		local function get_hex_value(previous)
			if radiation_table.fluid["apm_nuclear_hexafluoride_0"..previous] then
				return radiation_table.fluid["apm_nuclear_hexafluoride_0"..previous]*50/100
			else
				return 0
			end
		end

		radiation_table.fluid["apm_nuclear_hexafluoride_042"] = get_hex_value(47)
		radiation_table.fluid["apm_nuclear_hexafluoride_037"] = get_hex_value(42)
		radiation_table.fluid["apm_nuclear_hexafluoride_032"] = get_hex_value(37)
		radiation_table.fluid["apm_nuclear_hexafluoride_027"] = get_hex_value(32)
		radiation_table.fluid["apm_nuclear_hexafluoride_022"] = get_hex_value(27)
		radiation_table.fluid["apm_nuclear_hexafluoride_017"] = get_hex_value(22)
		radiation_table.fluid["apm_nuclear_hexafluoride_012"] = get_hex_value(17)
		radiation_table.fluid["apm_nuclear_hexafluoride_007"] = get_hex_value(12)

		candidate_index["apm_shielded_nuclear_fuel_cell"] = false
		candidate_index["apm_shielded_nuclear_fuel_cell_used"] = false
		
		if OSM.data_stage then
			data.raw.item["uranium-fuel-cell"].localised_description = nil
		end
	end

	-- Bob's compatibility
	if mod_installed("bobplates") then
		candidate_index["empty-nuclear-fuel-cell"] = false
		candidate_index["zinc-ore"] = false
		candidate_index["zinc-plate"] = false
	end

	-- True Nukes compatibility
	if mod_installed("True-Nukes") then
		for candidate, _ in pairs(candidate_index) do
			if string.find(candidate, "detonation-atomic", 1, true) then candidate_index[candidate] = false end
			if string.find(candidate, "capsule-atomic", 1, true) then candidate_index[candidate] = false end
		end
	end
end

function RKS.fixes(radiation_table, candidate_index)

	local get_table_length = OSM.utils.get_table_length
	local mod_installed = OSM.utils.mod_installed

	-- Deadlock's stacked items compatibility
	if settings.startup["deadlock-stack-size"] then
		local stack_size = settings.startup["deadlock-stack-size"].value

		for item, radioactivity in pairs(radiation_table.item) do
			if not string.find(item, "deadlock-stack-", 1, true) then
				radiation_table.item["deadlock-stack-"..item] = radioactivity*stack_size
			end
		end
	end
	
	return radiation_table
end

return RKS