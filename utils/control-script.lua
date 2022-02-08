
local local_script = {}

-- Get radiation resistance
function local_script.get_radiation_resistance(player)

	local armor = player.get_inventory(defines.inventory.character_armor)[1]
	local radiation_resistance ={}
	radiation_resistance.decrease = 0
	radiation_resistance.percent = 1

	if armor.valid_for_read and armor.name then
		for resistance_type, resistance in pairs(game.item_prototypes[armor.name].resistances) do
			if resistance_type == "radioactive" and resistance.decrease then
				radiation_resistance.decrease = resistance.decrease
			end
			if resistance_type == "radioactive" and resistance.percent then
				radiation_resistance.percent = 1-resistance.percent
			end
		end
	end
	return radiation_resistance
end

-- Get radiation level of ore patch
function local_script.get_ore_radioactivity(name, amount)

	local ore_divider = 0.0001
	local result = {}

	for ore, radioactivity in pairs(global.ores) do
		if name == ore then
			result = amount * radioactivity * ore_divider
			if result ~= nil then
				return result
			end
		end
	end
	return 0
end

-- Get radiation level of item
function local_script.get_item_radioactivity(name, amount)
	
	local result = {}
	
	for item, radioactivity in pairs(global.items) do
		if item == name then
			result = radioactivity * amount
			if result ~= nil then
				return result
			end
		end
	end
	return 0
end

-- Get radiation level of fluid
function local_script.get_fluid_radioactivity(name, amount)

	local fluid_divider = 0.001
	local result = {}

	for fluid, radioactivity in pairs(global.fluids) do
		if name == fluid then
			result = radioactivity * amount * fluid_divider
			if result ~= nil then
				return result
			end
		end
	end
	return 0
end

-- Get distance
function local_script.get_distance(player_pos, entity_pos)

	local distance = math.sqrt((player_pos.x - entity_pos.x)^2 + (player_pos.y - entity_pos.y)^2)

	if distance > 0 and distance < 1 then
		return 1
	else
		return distance
	end
end

----------------------------------------------------------------------------
----------------------------------------------------------------------------

-- Calculate damage
function local_script.calculate_damage(event)
	for _, player in pairs(game.connected_players) do
		if global.player_radiation_exposure[player.name] or global.player_half_life[player.name] then
			if player and player.valid and player.character and player.character.valid then

				local character = player.character
				local radiation_resistance = OSM_script.get_radiation_resistance(player)
				local radiation_exposure = global.player_radiation_exposure[player.name]
				local half_life = global.player_half_life[player.name]

				if not half_life then half_life = 0 end
				if not radiation_exposure then radiation_exposure = 0 end
				if half_life < radiation_exposure then half_life = radiation_exposure end
				if half_life > 100 then half_life = 100 end

				local player_exposure = (half_life-radiation_resistance.decrease)*radiation_resistance.percent

				if player_exposure < 0.01 then player_exposure = 0 end
				if radiation_exposure < 0.01 then radiation_exposure = 0 end
				if half_life < 0.19 then half_life = 0 end
	
				if half_life > 0.19 or player_exposure > 0.19 then
					if settings.global["osm-rad-geiger-sound"].value == true then
						player.play_sound({path = "geiger-counter", position=character.position, volume_modifier = 0.5})
					end
					player.remove_alert{character, {type="virtual", name="nuclear-alert"}}
					player.add_custom_alert(character, {type="virtual", name="nuclear-damage"}, {""}, false)
					global.player_half_life[player.name] = half_life
					character.damage(half_life, "neutral", "radioactive")
					
				elseif (half_life <= 0.19 and half_life >= 0.01) or (player_exposure <= 0.19 and player_exposure >= 0.01) or (radiation_exposure <= 0.19 and radiation_exposure >= 0.01) then
					if settings.global["osm-rad-geiger-sound"].value == true then
						player.play_sound({path = "geiger-counter", position=character.position, volume_modifier = 0.5})
					end
					player.remove_alert{character, {type="virtual", name="nuclear-damage"}}
					player.add_custom_alert(character, {type="virtual", name="nuclear-alert"}, {""}, false)

				elseif half_life == 0 and radiation_exposure == 0 and player_exposure == 0 then
					global.player_half_life[player.name] = nil
					global.player_radiation_exposure[player.name] = nil	
					player.remove_alert{character, {type="virtual", name="nuclear-alert"}}
					player.remove_alert{character, {type="virtual", name="nuclear-damage"}}
				end
			end
		end
	end
end

-- Calculate decay
function local_script.calculate_decay(event)
	for _, player in pairs(game.connected_players) do
		if global.player_half_life[player.name] then
			if player and player.valid and player.character and player.character.valid then

				local get_half_life = OSM_local.get_half_life
				local half_life = global.player_half_life[player.name]
				
				if half_life >= 0.19 then
					global.player_half_life[player.name] = get_half_life(half_life)
				else
					global.player_half_life[player.name] = nil
				end
			end
		end
	end
end

-- calculate radiation
function local_script.calculate_radiation(event, player)
	for _, player in pairs(game.connected_players) do
		if player and player.valid and player.character and player.character.valid then

			local character = player.character
			local radius = settings.startup["osm-rad-exposure-radius"].value
			local get_radiation_level = OSM_local.get_radiation_level
			local print_geiger_value = OSM_local.print_geiger_value

			local get_distance = OSM_script.get_distance
			local get_ore_radioactivity = OSM_script.get_ore_radioactivity
			local get_item_radioactivity = OSM_script.get_item_radioactivity
			local get_fluid_radioactivity = OSM_script.get_fluid_radioactivity

			local radioactive_area = {left_top = {character.position.x -radius, character.position.y -radius}, right_bottom = {character.position.x +radius, character.position.y +radius}}
			local radiation_data = {}
			local radiation_level = {}
			local radiation_resistance = OSM_script.get_radiation_resistance(player)

			-- Inventory
			for name, amount in pairs(character.get_inventory(1).get_contents()) do

				radiation_level = get_item_radioactivity(name, amount)

				if radiation_level > 0.001 then
					table.insert(radiation_data, radiation_level)
				end
				radiation_level = 0
			end

			-- Trash inventory
			local trash = character.get_inventory(defines.inventory.character_trash)
			if trash and trash.valid and not trash.is_empty() then
				for name, amount in pairs(trash.get_contents()) do

					radiation_level = get_item_radioactivity(name, amount)

					if radiation_level > 0.001 then
						table.insert(radiation_data, radiation_level)
					end
				end
				radiation_level = 0
			end

			-- Cursor
			local cursor_stack = player.cursor_stack
			if cursor_stack and cursor_stack.valid_for_read and cursor_stack.name then

				radiation_level = get_item_radioactivity(player.cursor_stack.name, player.cursor_stack.count)

				if radiation_level > 0.001 then
					table.insert(radiation_data, radiation_level)
				end
				radiation_level = 0
			end	

			-- Resource
			local count = player.surface.count_entities_filtered{area=radioactive_area, type="resource"}
			if count >=  1 then
				for _, entity in pairs(player.surface.find_entities_filtered{area=radioactive_area, type="resource"}) do
		
					local distance = get_distance(character.position, entity.position)
					local name = entity.name
					local amount = entity.amount

					radiation_level = (get_ore_radioactivity(name, amount) / distance)

					if radiation_level > 0.001 then
						table.insert(radiation_data, radiation_level)
					end
				end
				radiation_level = 0
			end

			-- Item on transport belt
			local count = player.surface.count_entities_filtered{area=radioactive_area, type="transport-belt"}
			if count >=  1 then
				for _, entity in pairs(player.surface.find_entities_filtered{area=radioactive_area, type="transport-belt"}) do

					for content, amount in pairs(entity.get_transport_line(1).get_contents()) do

						local distance = get_distance(character.position, entity.position)
						radiation_level = (get_item_radioactivity(content, amount) / distance)

						if radiation_level > 0.001 then
							table.insert(radiation_data, radiation_level)
						end
					end

					for content, amount in pairs(entity.get_transport_line(2).get_contents()) do

						local distance = get_distance(character.position, entity.position)
						radiation_level = (get_item_radioactivity(content, amount) / distance)

						if radiation_level > 0.001 then
							table.insert(radiation_data, radiation_level)
						end
					end
				end
				radiation_level = 0
			end

			-- Item on ground
			local count = player.surface.count_entities_filtered{area=radioactive_area, name="item-on-ground"}
			if count >=  1 then
				for _, entity in pairs(player.surface.find_entities_filtered{area=radioactive_area, name="item-on-ground"}) do

					local distance = get_distance(character.position, entity.position)
					local name = entity.stack.name
					local amount = entity.stack.count

					radiation_level = (get_item_radioactivity(name, amount) / distance)
					if radiation_level > 0.001 then
						table.insert(radiation_data, radiation_level)
					end
				end
				radiation_level = 0
			end

			-- Item in container
			local count = player.surface.count_entities_filtered{area=radioactive_area, type="container"}
			if count >=  1 then
				for _, entity in pairs(player.surface.find_entities_filtered{area=radioactive_area, type="container"}) do
					if entity.name ~= "shielded-chest" then

						local distance = get_distance(character.position, entity.position)

						for content, amount in pairs(entity.get_inventory(1).get_contents()) do
							radiation_level = (get_item_radioactivity(content, amount) / distance)
							if radiation_level > 0.001 then
								table.insert(radiation_data, radiation_level)
							end
						end
					end
				end
				radiation_level = 0
			end

			-- Item in corpse
			local count = player.surface.count_entities_filtered{area=radioactive_area, type="character-corpse"}
			if count >=  1 then
				for _, entity in pairs(player.surface.find_entities_filtered{area=radioactive_area, type="character-corpse"}) do

					local distance = get_distance(character.position, entity.position)

					for content, amount in pairs(entity.get_inventory(1).get_contents()) do
						radiation_level = (get_item_radioactivity(content, amount))
						if radiation_level > 0.001 then
							table.insert(radiation_data, radiation_level)
						end
					end
				end
				radiation_level = 0
			end

			-- Item/fluid in assembling machine
			local count = player.surface.count_entities_filtered{area=radioactive_area, type="assembling-machine"}
			if count >=  1 then
				for _, entity in pairs(player.surface.find_entities_filtered{area=radioactive_area, type="assembling-machine"}) do

					local distance = get_distance(character.position, entity.position)

					if entity.fluidbox then
						for content, amount in pairs(entity.get_fluid_contents()) do
							radiation_level = (get_fluid_radioactivity(content, amount) / distance)
							if radiation_level > 0.001 then
								table.insert(radiation_data, radiation_level)
							end
						end
					end

					for content, amount in pairs(entity.get_inventory(defines.inventory.assembling_machine_output).get_contents()) do
						radiation_level = (get_item_radioactivity(content, amount) / distance)
						if radiation_level > 0.001 then
							table.insert(radiation_data, radiation_level)
						end
					end

					for content, amount in pairs(entity.get_inventory(defines.inventory.assembling_machine_input).get_contents()) do
						radiation_level = (get_item_radioactivity(content, amount) / distance)
						if radiation_level > 0.001 then
							table.insert(radiation_data, radiation_level)
						end
					end
				end
				radiation_level = 0
			end

			-- Fluid in pipe
			local count = player.surface.count_entities_filtered{area=radioactive_area, type="pipe"}
			if count >=  1 then
				for _, entity in pairs(player.surface.find_entities_filtered{area=radioactive_area, type="pipe"}) do

					local distance = get_distance(character.position, entity.position)

					for content, amount in pairs(entity.get_fluid_contents()) do
						radiation_level = (get_fluid_radioactivity(content, amount) / distance)
						if radiation_level > 0.001 then
							table.insert(radiation_data, radiation_level)
						end
					end
				end
				radiation_level = 0
			end

			-- Fluid in storage tank
			local count = player.surface.count_entities_filtered{area=radioactive_area, type="storage-tank"}
			if count >=  1 then
				for _, entity in pairs(player.surface.find_entities_filtered{area=radioactive_area, type="storage-tank"}) do
					if entity.name ~= "shielded-tank" then

						local distance = get_distance(character.position, entity.position)

						for content, amount in pairs(entity.get_fluid_contents()) do
							radiation_level = (get_fluid_radioactivity(content, amount) / distance)
							if radiation_level > 0.001 then
								table.insert(radiation_data, radiation_level)
							end
						end
					end
				end
				radiation_level = 0
			end

			-- Get radiation level
			if radiation_data[#radiation_data] ~= nil then
				radiation_level = get_radiation_level(radiation_data)
			else
				radiation_level = 0
			end

			-- Give cancer to player
			if radiation_level >= 0.001 then
				radiation_exposure = (radiation_level-radiation_resistance.decrease)*radiation_resistance.percent
				if radiation_level >= 0.01 then
					print_geiger_value(radiation_level, radiation_exposure, player)
				end
				global.player_radiation_exposure[player.name] = radiation_level
			else
				global.player_radiation_exposure[player.name] = nil
			end
		end
	end
end

return local_script