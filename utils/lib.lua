------------------------------
---- control.lua/data.lua ----
------------------------------

-- Setup function host
local local_function = {}

-- Returns total radiation level rounded up [2 decimals]
function local_function.get_radiation_level(table)
	local sum = 0
	local power = 10^2
	for _, v in pairs(table) do
		sum = sum+v
	end
	return math.floor(sum*power)/power
end

-- Returns half-life rounded up [2 decimals]
function local_function.get_half_life(half_life)
	local half_life = half_life/2
	local power = 10^2
	return math.floor(half_life*power)/power
end

-- Print exposure and radiation levels
function local_function.print_geiger_value(radiation_level, exposure_level, player)
	
	if not radiation_level or radiation_level <= 0 then return end
	if not exposure_level or exposure_level <= 0 then exposure_level = 0 end

	local print_millibobs = settings.global["osm-rad-print-millibobs"].value

	-- Returns radiation level and exposure level on screen
	if print_millibobs == true then

		local radiation = string.format("%.2f", radiation_level)
		local exposure = string.format("%.2f", exposure_level)

		if radiation_level < 0.1 then
			radiation = "[color=#27c43c]"..radiation.."[/color]" -- green
		elseif radiation_level >= 0.1 and radiation_level <= 0.19 then
			radiation = "[color=#ffc500]"..radiation.."[/color]" -- yellow
		elseif radiation_level >= 0.2 then
			radiation = "[color=#ff392f]"..radiation.."[/color]" -- red
		end

		if exposure_level < 0.1 then
			exposure = "[color=#27c43c]"..exposure.."[/color]" -- green
		elseif exposure_level >= 0.1 and exposure_level <= 0.19 then
			exposure = "[color=#ffc500]"..exposure.."[/color]" -- yellow
		elseif exposure_level >= 0.2 then
			exposure = "[color=#ff392f]"..exposure.."[/color]" -- red
		end
		player.print({"", {"string-name.osm-rad-radiation-level"}, ": ", radiation})
		player.print({"", "[color=#e5a4e1]", {"string-name.osm-rad-exposure-level"}, ": [/color]", exposure})
	end
end

-- Generate fuel cell values [data.lua]
function local_function.data_get_fuel_cell_value(prototype_table, OSM_local)

	local index = {}

	for _, recipe in pairs(data.raw.recipe) do

		local recipe_name = recipe.name
		local ingredients_index = {}
		local result_index = {}
		local fuel_cell_radioactivity = {}
		local ingredient_amount = {}
		local result_name = {}
		local result_count = {}
		local ingredients_index = {}
		local fuel_cell_radioactivity = {}
		local ingredient_name = {}

		-- Get recipe difficulty
		if recipe.normal then recipe = recipe.normal end
		if recipe.expensive then recipe = recipe.expensive end
		
		-- look for fuel cells
		if recipe.result then
			for fuel_cell, _ in pairs(prototype_table.fuel_cells) do
				if recipe.result == fuel_cell then

					local result_count = recipe.result_count or 1
	
					for _, ingredient in pairs(recipe.ingredients) do
						for radioactive_item, radioactivity in pairs (prototype_table.items) do
							if ingredient.name == radioactive_item or ingredient[1] == radioactive_item then
								
								local ingredient_amount = {}
								
								if ingredient.amount then ingredient_amount = ingredient.amount elseif ingredient[2] then ingredient_amount = ingredient[2] end
								ingredients_index[radioactive_item] = radioactivity*ingredient_amount/result_count
							end
						end
						for radioactive_fluid, radioactivity in pairs (prototype_table.fluids) do
							if ingredient.name == radioactive_fluid or ingredient[1] == radioactive_fluid then
								
								local ingredient_amount = {}
								
								if ingredient.amount then ingredient_amount = ingredient.amount elseif ingredient[2] then ingredient_amount = ingredient[2] end
								ingredients_index[radioactive_fluid] = radioactivity*ingredient_amount/result_count
							end
						end
					end
	
					fuel_cell_radioactivity = OSM_local.get_radiation_level(ingredients_index)

					if not index[fuel_cell] then
						index[fuel_cell] = fuel_cell_radioactivity
					elseif index[fuel_cell] <= fuel_cell_radioactivity then
						index[fuel_cell] = fuel_cell_radioactivity
					end
				end
			end

		elseif recipe.results then
			for _, result in pairs(recipe.results) do
				
				if result.name then
					result_name = result.name
				elseif result[1] then
					result_name = result[1]
				end
				if result.amount then
					result_count = result.amount
				elseif result[2] then
					result_count = result[2]
				end
				for fuel_cell, _ in pairs(prototype_table.fuel_cells) do
					if result_name == fuel_cell then
						for _, ingredient in pairs(recipe.ingredients) do
							for radioactive_item, radioactivity in pairs (prototype_table.items) do
								if ingredient.name == radioactive_item or ingredient[1] == radioactive_item then

									local ingredient_amount = {}

									if ingredient.amount then ingredient_amount = ingredient.amount elseif ingredient[2] then ingredient_amount = ingredient[2] end
									ingredients_index[radioactive_item] = radioactivity*ingredient_amount/result_count
								end
							end
							for radioactive_fluid, radioactivity in pairs (prototype_table.fluids) do
								if ingredient.name == radioactive_fluid or ingredient[1] == radioactive_fluid then
								
									local ingredient_amount = {}
								
									if ingredient.amount then ingredient_amount = ingredient.amount elseif ingredient[2] then ingredient_amount = ingredient[2] end
									ingredients_index[radioactive_fluid] = radioactivity*ingredient_amount/result_count
								end
							end
						end
						
						fuel_cell_radioactivity = OSM_local.get_radiation_level(ingredients_index)
		
						if not index[fuel_cell] then
							index[fuel_cell] = fuel_cell_radioactivity
						elseif index[fuel_cell] <= fuel_cell_radioactivity then
							index[fuel_cell] = fuel_cell_radioactivity
						end
					end
				end
			end
		end

		-- look for spent fuel cells
		for _, ingredient in pairs(recipe.ingredients) do
			for fuel_cell, _ in pairs(prototype_table.fuel_cells) do

				if ingredient.name then ingredient_name = ingredient.name elseif ingredient[1] then ingredient_name = ingredient[1] end
				if ingredient.amount then ingredient_amount = ingredient.amount elseif ingredient[2] then ingredient_amount = ingredient[2] end

				if ingredient_name == "used-up-"..fuel_cell then
					
					fuel_cell = "used-up-"..fuel_cell

					if recipe.result then

						local result_count = recipe.result_count or 1

						for radioactive_item, radioactivity in pairs (prototype_table.items) do
							if result == radioactive_item then
								result_index[radioactive_item] = radioactivity*result_count/ingredient_amount
							end
						end
		
						fuel_cell_radioactivity = OSM_local.get_radiation_level(result_index)

						if not index[fuel_cell] then
							index[fuel_cell] = fuel_cell_radioactivity
						elseif index[fuel_cell] <= fuel_cell_radioactivity then
							index[fuel_cell] = fuel_cell_radioactivity
						end

					elseif recipe.results then
						for _, result in pairs(recipe.results) do
							
							if result.name then
								result_name = result.name
							elseif result[1] then
								result_name = result[1]
							end
							if result.amount then
								result_count = result.amount
							elseif result[2] then
								result_count = result[2]
							end

							for radioactive_item, radioactivity in pairs (prototype_table.items) do
								if result_name == radioactive_item then
									result_index[radioactive_item] = radioactivity*result_count/ingredient_amount
								end
							end
							for radioactive_fluid, radioactivity in pairs (prototype_table.fluids) do
								if result_name == radioactive_fluid then
									result_index[radioactive_fluid] = radioactivity*result_count/ingredient_amount
								end
							end

							fuel_cell_radioactivity = OSM_local.get_radiation_level(result_index)
								
							if not index[fuel_cell] then
								index[fuel_cell] = fuel_cell_radioactivity
							elseif index[fuel_cell] <= fuel_cell_radioactivity then
								index[fuel_cell] = fuel_cell_radioactivity
							end
						end
					end
				end
			end
		end
	end
	for fuel_cell, radioactivity in pairs(index) do
		prototype_table.items[fuel_cell] = radioactivity
	end
	return prototype_table
end

-- Generate fuel cell values [control.lua]
function local_function.control_get_fuel_cell_value(prototype_table, OSM_local)

	local index = {}

	for _, recipe in pairs(recipe_index) do

		local recipe_name = recipe.name
		local ingredients_index = {}
		local result_index = {}
		local fuel_cell_radioactivity = {}
		local ingredient_amount = {}
		local result_name = {}
		local result_count = {}
		local ingredients_index = {}
		local fuel_cell_radioactivity = {}
		local ingredient_name = {}
		
		-- look for fuel cells
		if recipe.products then
			for _, result in pairs(recipe.products) do

				if result.name then
					result_name = result.name
				elseif result[1] then
					result_name = result[1]
				end
				if result.amount then
					result_count = result.amount
				elseif result[2] then
					result_count = result[2]
				end
				for fuel_cell, _ in pairs(prototype_table.fuel_cells) do
					if result_name == fuel_cell then
						if not index[fuel_cell] then index[fuel_cell] = 0 end
						for _, ingredient in pairs(recipe.ingredients) do
							for radioactive_item, radioactivity in pairs (prototype_table.items) do
								if ingredient.name == radioactive_item or ingredient[1] == radioactive_item then

									local ingredient_amount = {}

									if ingredient.amount then ingredient_amount = ingredient.amount elseif ingredient[2] then ingredient_amount = ingredient[2] end
									ingredients_index[radioactive_item] = radioactivity*ingredient_amount/result_count
								end
							end
							for radioactive_fluid, radioactivity in pairs (prototype_table.fluids) do
								if ingredient.name == radioactive_fluid or ingredient[1] == radioactive_fluid then
								
									local ingredient_amount = {}
								
									if ingredient.amount then ingredient_amount = ingredient.amount elseif ingredient[2] then ingredient_amount = ingredient[2] end
									ingredients_index[radioactive_fluid] = radioactivity*ingredient_amount/result_count
								end
							end
						end
	
						fuel_cell_radioactivity = OSM_local.get_radiation_level(ingredients_index)
	
						if not index[fuel_cell] then
							index[fuel_cell] = fuel_cell_radioactivity
						elseif index[fuel_cell] <= fuel_cell_radioactivity then
							index[fuel_cell] = fuel_cell_radioactivity
						end
					end
				end
			end
		end

		-- look for spent fuel cells
		if recipe.ingredients then
			for _, ingredient in pairs(recipe.ingredients) do
				for fuel_cell, _ in pairs(prototype_table.fuel_cells) do
	
					if ingredient.name then ingredient_name = ingredient.name elseif ingredient[1] then ingredient_name = ingredient[1] end
					if ingredient.amount then ingredient_amount = ingredient.amount elseif ingredient[2] then ingredient_amount = ingredient[2] end
					if ingredient_name == "used-up-"..fuel_cell then
						
						fuel_cell = "used-up-"..fuel_cell
	
						if recipe.products then
							for _, result in pairs(recipe.products) do
								
								if result.name then
									result_name = result.name
								elseif result[1] then
									result_name = result[1]
								end
								if result.amount then
									result_count = result.amount
								elseif result[2] then
									result_count = result[2]
								end

								for radioactive_item, radioactivity in pairs (prototype_table.items) do
									if result_name == radioactive_item then
										result_index[radioactive_item] = radioactivity*result_count/ingredient_amount
									end
								end
								for radioactive_fluid, radioactivity in pairs (prototype_table.fluids) do
									if result_name == radioactive_fluid then
										result_index[radioactive_fluid] = radioactivity*result_count/ingredient_amount
									end
								end
	
								fuel_cell_radioactivity = OSM_local.get_radiation_level(result_index)
									
								if not index[fuel_cell] then
									index[fuel_cell] = fuel_cell_radioactivity
								elseif index[fuel_cell] <= fuel_cell_radioactivity then
									index[fuel_cell] = fuel_cell_radioactivity
								end
							end
						end
					end
				end
			end
		end
	end

	for fuel_cell, radioactivity in pairs(index) do
		prototype_table.items[fuel_cell] = radioactivity
	end
	return prototype_table
end
	
return local_function