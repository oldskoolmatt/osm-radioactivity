----------------------------
---- runtime-script.lua ----
----------------------------

local RKS = {}

-- Get radiation shield
function RKS.get_radiation_shield(player)

	local armor = player.get_inventory(defines.inventory.character_armor)[1]

	if armor.valid_for_read and armor.grid and armor.grid.equipment then

		local capacity = armor.grid.battery_capacity or 0
		local shield_level = armor.grid.available_in_batteries or 0
		local rad_shield_count = armor.grid.count("osm-rks-radiation-shield-equipment")

		-- Check shield power (minimum shield power: >=1% or >=1MJ)
		if rad_shield_count >= 1 and (shield_level > capacity/100 or shield_level >= 10^6) then return true end
	end
end

-- Get ordinary shields
function RKS.get_shields(player, radiation_shield)

	local energy_shields = false
	local armor = player.get_inventory(defines.inventory.character_armor)[1]

	if armor.valid_for_read and armor.grid and armor.grid.equipment then

		if radiation_shield then return false end

		for i, equipment in pairs(armor.grid.equipment) do
			if equipment.type == "energy-shield-equipment" and equipment.name ~= "osm-rks-radiation-shield-equipment" then

				if not energy_shields then energy_shields = {} end
				if not energy_shields.total then energy_shields.total = 0 end
				
				energy_shields[i] = equipment.shield
				energy_shields.total = energy_shields.total+equipment.shield
			end
		end
	end

	
	return energy_shields
end

-- Get radiation exposure
function RKS.get_player_exposure(player)

	local resistance_decrease = 0
	local resistance_percent = 1
	local player_exposure = 0
	local player_half_life = global.player_half_life[player.name] or 0
	local radiation_level = global.player_radiation_exposure[player.name] or 0
	local armor = player.get_inventory(defines.inventory.character_armor)[1]

	if player_half_life < radiation_level then
	
		if armor.valid_for_read then
			for resistance_type, resistance in pairs(game.item_prototypes[armor.name].resistances) do
				if resistance_type == "radioactive" and resistance.decrease then
					resistance_decrease = resistance.decrease
				end
				if resistance_type == "radioactive" and resistance.percent then
					resistance_percent = 1-resistance.percent
				end
			end
		end

		player_half_life = radiation_level
		player_exposure = (player_half_life-resistance_decrease)*resistance_percent

	else
		player_exposure = player_half_life
	end
	
	if player_exposure < 0 then player_exposure = 0 end
	
	return player_exposure
end

-- Get radiation level
function RKS.get_radiation_level(type, name, amount, position)

	local distance = 1
	local radiation_level = 0
	local ore_divider = 0.000125
	local fluid_divider = 0.001
	
	if settings.startup["osm-rks-deadly-ores"].value == true then ore_divider = ore_divider*10^2 end

	-- Get distance between player and radioactive source
	if position then

		local character = position[1]
		local source = position[2]
	
		distance = math.sqrt((character.x-source.x)^2 + (character.y-source.y)^2)
		if distance <= 1 then distance = 1 end
	end

	-- Get radiation level
	if type == "resource" then
		if global.radioactive_ores[name] then
			radiation_level = global.radioactive_ores[name].radioactivity
			radiation_level = amount*radiation_level*ore_divider/distance
		end

	elseif type == "item" then
		if global.radioactive_items[name] then
			radiation_level = global.radioactive_items[name].radioactivity
			radiation_level = amount*radiation_level/distance
		end

	elseif type == "fluid" then
		if global.radioactive_fluids[name] then
			radiation_level = global.radioactive_fluids[name].radioactivity
			radiation_level = amount*radiation_level*fluid_divider/distance
		end

	elseif type == "entity" then
		if global.radioactive_entities[name] then
			radiation_level = global.radioactive_entities[name].radioactivity
			radiation_level = amount*radiation_level/distance
		end
	end

	return radiation_level
end

-- Calculate damage
function RKS.calculate_damage(player)

	if not OSM.RKS.utils.player_check(player) then return end

	local character = player.character
	local armor = player.get_inventory(defines.inventory.character_armor)[1]
	local player_exposure = OSM.RKS.runtime.get_player_exposure(player)
	local radiation_shield = OSM.RKS.runtime.get_radiation_shield(player)
	local energy_shields = OSM.RKS.runtime.get_shields(player, radiation_shield)
	local player_damage = 0

	-- Set player_damage maximum value
	if radiation_shield then
		if player_exposure > 400 then
			player_damage = 400
		else
			player_damage = player_exposure
		end
	else
		if player_exposure > 100 then
			player_damage = 100
		else
			player_damage = player_exposure
		end
	end

	-- Damage player
	if character.destructible then
		if player_exposure >= 0.2 and radiation_shield then

			local radiation_energy = player_damage*10^3 -- player_exposure*1kJ

			-- Get shield energy
			for _, equipment in pairs(armor.grid.equipment) do
				if equipment.type == "battery-equipment" then
				
					local battery = equipment

					if battery.energy == 0 then goto skip end

					if battery.energy-radiation_energy > 0 then
						battery.energy = battery.energy-radiation_energy
						if radiation_energy-battery.energy > 0 then
							radiation_energy = radiation_energy-battery.energy
						else
							radiation_energy = 0
						end
					else
						battery.energy = 0
					end
				end
				::skip::
			end

			local capacity = armor.grid.battery_capacity or 0
			local shield_level = armor.grid.available_in_batteries or 0

			if radiation_energy == 0 or (shield_level > capacity/100 and capacity > 0) then
				player_half_life = 0.01
				player_exposure = 0
			end

		elseif player_exposure >= 0.2 and energy_shields then

			character.damage(energy_shields.total, "neutral")
			character.damage(player_damage, "neutral", "radioactive")
			
			energy_shields.total = nil
	
			if OSM.RKS.utils.player_check(player) then
				for i, shield in pairs(energy_shields) do
					armor.grid.equipment[i].shield = shield
				end
			end

		elseif player_exposure >= 0.2 then
			character.damage(player_damage, "neutral", "radioactive")
		end
	end
	
	-- Set player half life
	if OSM.RKS.utils.player_check(player) then

		OSM.RKS.gui.display_gui(player, player_exposure, radiation_shield)
		OSM.RKS.gui.display_alerts(player, player_exposure)

		global.player_half_life[player.name] = player_exposure
	else
		global.player_half_life[player.name] = nil
	end
end

-- calculate radiation
function RKS.calculate_radiation(player)

	if not OSM.RKS.utils.player_check(player) then return end

	local character = player.character
	local radius = settings.startup["osm-rks-exposure-radius"].value
	local prototype_is_allowed = OSM.RKS.utils.prototype_is_allowed
	local get_radiation_level = OSM.RKS.runtime.get_radiation_level
	local radioactive_area = {left_top = {character.position.x-radius, character.position.y-radius}, right_bottom = {character.position.x+radius, character.position.y+radius}}
	local radiation_data = {}
	local count = 0
	local radiation_level = 0
	local entity_types =
	{
		-- Production
		"furnace",
		"assembling-machine",

		-- Fluid network
		"pipe",
		"pipe-to-ground",
		"storage-tank",
		"pump",
		"fluid-wagon",

		-- Logistics
		"transport-belt",
		"underground-belt",
		"linked-belt",
		"splitter",
		"loader",
		"loader-1x1",
		"inserter",
		"cargo-wagon",

		-- Containers
		"container",
		"logistic-container",
		"linked-container",
		"corpse",

		-- Players
		"character",

		-- Vehicles
		"car",
		"spider-vehicle",
		"locomotive",

		-- Item on ground
		"item-entity",

		-- Resources
		"resource"
	}

	-- Entities with special needs	
	for _, entity_type in pairs(entity_types) do
		count = player.surface.count_entities_filtered{area=radioactive_area, type=entity_type}
		if count >= 1 then
			for _, entity in pairs(player.surface.find_entities_filtered{area=radioactive_area, type=entity_type}) do
				
				if string.find(entity.name, "osm-rks-shielded", 1, true) then goto skip end
	
				local position = {character.position, entity.position}

				local fuel = false
				local input = false
				local output = false
				local fluidbox = false
				local inventory_index = false
				local inventory_size = false
				local held_stacks_index = false
				local transport_line = false

				-- Production
				if entity.type == "furnace" or entity.type == "assembling-machine" or entity.type == "lab" then
					if entity.type == "furnace" then
						fuel = entity.get_inventory(defines.inventory.fuel)
						input = entity.get_inventory(defines.inventory.furnace_source)
						output = entity.get_inventory(defines.inventory.furnace_result)

					elseif entity.type == "assembling-machine" then
						if entity.fluidbox then fluidbox = entity.fluidbox end
						input = entity.get_inventory(defines.inventory.assembling_machine_input)
						output = entity.get_inventory(defines.inventory.assembling_machine_output)

					elseif entity.type == "lab" then
						input = entity.get_inventory(defines.inventory.lab_input)
					end
				end

				-- Fluid network
				if entity.type == "pipe" or entity.type == "pipe-to-ground" or entity.type == "storage-tank" or entity.type == "pump" or entity.type == "fluid-wagon" then
					if entity.fluidbox then fluidbox = entity.fluidbox end
				end

				-- Containers
				if entity.type == "container" or entity.type == "logistic-container" or entity.type == "linked-container" or entity.type == "corpse" or entity.type == "cargo-wagon" then

					if not inventory_index then inventory_index = {} end
					if not inventory_size then inventory_size = 0 end

					local main_inventory = false
					
					if entity.type == "cargo-wagon" then
						main_inventory = entity.get_inventory(defines.inventory.cargo_wagon)
					else
						main_inventory = entity.get_inventory(1)
					end

					if main_inventory then
						table.insert(inventory_index, main_inventory)
						main_inventory = #main_inventory
						inventory_size = inventory_size+main_inventory
					end
				end

				-- Logistics
				if entity.type == "transport-belt" or entity.type == "underground-belt" or entity.type == "linked-belt" or entity.type == "splitter" or entity.type == "loader" or entity.type == "loader-1x1" then
					transport_line = entity.get_max_transport_line_index() or 0
				end

				-- Players
				if entity.type == "character" then

					if not inventory_index then inventory_index = {} end

					local player_inventory = entity.get_inventory(1)
					local player_trash = entity.get_inventory(defines.inventory.character_trash)
					
					if player_inventory then table.insert(inventory_index, player_inventory) end
					if player_trash then table.insert(inventory_index, player_trash) end

					player_inventory = #player_inventory or 0
					player_trash = #player_trash or 0
					inventory_size = player_inventory+player_trash
					
					if entity.player then
						if not held_stacks_index then held_stacks_index = {} end
						table.insert(held_stacks_index, entity.player.cursor_stack)
					end
				end

				-- Vehicles
				if entity.type == "car" or entity.type == "spider-vehicle" or entity.type == "locomotive" then

					if not inventory_index then inventory_index = {} end
					if not inventory_size then inventory_size = 0 end

					local vehicle_inventory = false
					local vehicle_trash = false

					-- Vehicles	
					if entity.type == "car" then
						vehicle_inventory = entity.get_inventory(defines.inventory.car_trunk)

						if vehicle_inventory then table.insert(inventory_index, vehicle_inventory) end

					elseif entity.type == "spider-vehicle" then
						vehicle_inventory = entity.get_inventory(defines.inventory.spider_trunk)
						vehicle_trash = entity.get_inventory(defines.inventory.spider_trash)

						if vehicle_inventory then table.insert(inventory_index, vehicle_inventory) end
						if vehicle_trash then table.insert(inventory_index, vehicle_trash) end
					end
					
					if vehicle_inventory then vehicle_inventory = #vehicle_inventory else vehicle_inventory = 0 end
					if vehicle_trash then vehicle_trash = #vehicle_trash else vehicle_trash = 0 end

					inventory_size = inventory_size+vehicle_inventory+vehicle_trash

					-- Driver
					if entity.get_driver() then
						local driver = entity.get_driver()
						local main_inventory = driver.get_inventory(1)
						local trash_inventory = driver.get_inventory(defines.inventory.character_trash)
					
						if main_inventory then table.insert(inventory_index, main_inventory) end
						if trash_inventory then table.insert(inventory_index, trash_inventory) end

						main_inventory = #main_inventory or 0
						trash_inventory = #trash_inventory or 0
						inventory_size = inventory_size+main_inventory+trash_inventory
						
						if driver.player then
							if not held_stacks_index then held_stacks_index = {} end
							table.insert(held_stacks_index, driver.player.cursor_stack)
						end
					end

					-- Passenger
					if entity.type == "car" or entity.type == "spider-vehicle" then
						if entity.get_passenger() then
	
							local passenger = entity.get_passenger()
							local main_inventory = passenger.get_inventory(1)
							local trash_inventory = passenger.get_inventory(defines.inventory.character_trash)
						
							if main_inventory then table.insert(inventory_index, main_inventory) end
							if trash_inventory then table.insert(inventory_index, trash_inventory) end
							
							main_inventory = #main_inventory or 0
							trash_inventory = #trash_inventory or 0
							inventory_size = inventory_size+main_inventory+trash_inventory
							
							if passenger.player then
								if not held_stacks_index then held_stacks_index = {} end
								table.insert(held_stacks_index, passenger.player.cursor_stack)
							end
						end
					end
				end

				-- Inserters
				if entity.type == "inserter" then
					if entity.held_stack then
						if not held_stacks_index then held_stacks_index = {} end
						table.insert(held_stacks_index, entity.held_stack)
					end
				end

				-----------------------------------------------------------
				-----------------------------------------------------------

				-- Fuel slot
				if fuel then
					if fuel.valid and not input.is_empty() then
						for name, amount in pairs(fuel.get_contents()) do
							radiation_level = get_radiation_level("item", name, amount, position)
							if radiation_level > 0.001 then
								table.insert(radiation_data, radiation_level)
							end
						end
					end
				end
	
				-- Ingredient slot
				if input then
					if input.valid and not input.is_empty() then
						for name, amount in pairs(input.get_contents()) do
							radiation_level = get_radiation_level("item", name, amount, position)
							if radiation_level > 0.001 then
								table.insert(radiation_data, radiation_level)
							end
						end
					end
				end
	
				-- Result slot
				if output then
					if output.valid and not output.is_empty() then
						for name, amount in pairs(output.get_contents()) do
							radiation_level = get_radiation_level("item", name, amount, position)
							if radiation_level > 0.001 then
								table.insert(radiation_data, radiation_level)
							end
						end
					end
				end
				
				-- Inventory slot
				if inventory_index then
					for _, inventory in pairs(inventory_index) do
						if inventory.valid and not inventory.is_empty() then
							if inventory_size > global.radioactive_items_size then
								for name, _ in pairs(global.radioactive_items) do
									if inventory.get_contents()[name] then
										local amount = inventory.get_contents()[name]
										
										radiation_level = get_radiation_level("item", name, amount, position)
										if radiation_level > 0.001 then
											table.insert(radiation_data, radiation_level)
										end
									end
								end
							else
								for name, amount in pairs(inventory.get_contents()) do
									radiation_level = get_radiation_level("item", name, amount, position)
									if radiation_level > 0.001 then
										table.insert(radiation_data, radiation_level)
									end
								end
							end
						end
					end
				end

				-- Item stack
				if held_stacks_index then
					for _, held_stack in pairs(held_stacks_index) do
						if held_stack.valid and held_stack.valid_for_read then
			
							local name = held_stack.name
							local amount = held_stack.count
		
							radiation_level = get_radiation_level("item", name, amount, position)
		
							if radiation_level > 0.001 then
								table.insert(radiation_data, radiation_level)
							end
						end
					end
				end

				-- Fluid slot
				if fluidbox then
					if fluidbox.valid and global.radioactive_fluids_size >= 1 then
						for name, amount in pairs(entity.get_fluid_contents()) do
							radiation_level = get_radiation_level("fluid", name, amount, position)
							if radiation_level > 0.001 then
								table.insert(radiation_data, radiation_level)
							end
						end
					end
				end

				-- Transport line
				if transport_line then
			
					::next_line::

					count = entity.get_transport_line(transport_line).get_item_count()
					if count >= 1 then
						for name, amount in pairs(entity.get_transport_line(transport_line).get_contents()) do
			
							radiation_level = get_radiation_level("item", name, amount, position)
			
							if radiation_level > 0.001 then
								table.insert(radiation_data, radiation_level)
							end
						end
					end
					
					transport_line = transport_line-1
		
					if transport_line > 0 then goto next_line end
				end

				-- Common
				if entity.type == "resource" then
					radiation_level = get_radiation_level("resource", entity.name, entity.amount, position)

				elseif entity.type == "item-entity" then
					radiation_level = get_radiation_level("item", entity.stack.name, entity.stack.count, position)

				else
					radiation_level = get_radiation_level("entity", entity.name, 1, position)
				end

				if radiation_level > 0.001 then
					table.insert(radiation_data, radiation_level)
				end

				radiation_level = 0
				::skip::
			end
		end
	end

	-- All other known basic radioactive entities
	for _, entity in pairs(global.radioactive_entities) do
	
		if entity_types[entity.type] or not prototype_is_allowed(entity) then goto skip end
	
		count = player.surface.count_entities_filtered{area=radioactive_area, name=entity.name, type=entity.type}
		if count >=  1 then
			for _, placed_entity in pairs(player.surface.find_entities_filtered{area=radioactive_area, name=entity.name, type=entity.type}) do

				local position = {character.position, placed_entity.position}
		
				radiation_level = get_radiation_level("entity", placed_entity.name, 1, position)
				game.print(radiation_level)

				if radiation_level > 0.001 then
					table.insert(radiation_data, radiation_level)
				end
				radiation_level = 0
			end
		end
		::skip::
	end	

	-- Get radiation level
	if #radiation_data > 0 then

		local power = 10^3

		for _, radiation_amount in pairs(radiation_data) do
			radiation_level = radiation_level+radiation_amount
		end

		radiation_level = (radiation_level*power)/power
	end

	-- Give cancer to player
	if radiation_level >= 0.01 then
		global.player_radiation_exposure[player.name] = radiation_level
	else
		global.player_radiation_exposure[player.name] = nil
	end
end

-- Calculate decay
function RKS.calculate_decay(player)

	local power = 10^2
	local player_half_life = global.player_half_life[player.name] or 0

	if player_half_life >= 0.01 then
		global.player_half_life[player.name] = math.floor(player_half_life/2*power)/power
	else
		global.player_half_life[player.name] = nil
	end
end

-- Reset radiation values on player death
function RKS.death_solves_all_problems(event)

	local player = game.get_player(event.player_index)

	if player and player.name then
		global.player_radiation_exposure[player.name] = nil
		global.player_half_life[player.name] = nil
	end

	if player and player.valid then
		if player.gui.screen["radiation-gui"] then player.gui.screen["radiation-gui"].visible = false end
		player.remove_alert{entity=character, type=defines.alert_type.custom, icon={type="item", name="osm-rks-nuclear-alert"}, message="string-name.osm-nuclear-alert"}
		player.remove_alert{entity=character, type=defines.alert_type.custom, icon={type="item", name="osm-rks-nuclear-danger"}, message="string-name.osm-nuclear-danger"}
	end
end

return RKS