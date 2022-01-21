---------------------
---- control.lua ----
---------------------

-- Setup local hosts
local OSM_local = require("utils.lib")
local OSM_table = require("control-table")

-- Setup local settings
local geiger_sound = settings.global["osm-rad-geiger-sound"].value
script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	geiger_sound = settings.global["osm-rad-geiger-sound"].value
end)

-- Setup values host
local radioactive_ores = OSM_table.ores
local radioactive_items = OSM_table.items
local radioactive_fluids = OSM_table.fluids

-- Setup local functions
local get_player = OSM_local.get_player
local get_radiation_resistance = OSM_local.get_radiation_resistance
local total_round = OSM_local.total_round
local print_geiger_value = OSM_local.print_geiger_value

-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
local ore_divider = 0.00001
local fluid_divider = 0.001

-- Get radiation level of ore patch
local function get_resource_radioactivity(name, amount)
	
	local result = nil

	for ore, radioactivity in pairs(radioactive_ores) do
		if name == ore or name == "infinite-"..ore then
			result = amount * radioactivity * ore_divider
			if result ~= nil then
				return result
			end
		end
	end
	return 0
end

-- Get radiation level of item
local function get_item_radioactivity(name, amount)
	
	local result = nil
	
	for item, radioactivity in pairs(radioactive_items) do
		if item == name then
			result = radioactivity * amount
			if result ~= nil then
				return result
			end
		elseif item == name.."-barrel" then
			result = radioactivity * 50 * amount
			if result ~= nil then
				return result
			end
		end
	end
	return 0
end

-- Get radiation level of fluid
local function get_fluid_radioactivity(name, amount)
	
	local result = nil

	for fluid, radioactivity in pairs(radioactive_fluids) do
		if name == fluid then
			result = radioactivity * amount * fluid_divider
			if result ~= nil then
				return result
			end
		end
	end
	return 0
end

-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------

-- Set local variables
local player_half_life = {}
local player_radiation_exposure = {}
local perceived_radiation = {}

-- Set radiation exposure
local function set_radiation_exposure(player, radiation_exposure)
	if player_radiation_exposure == nil then
		player_radiation_exposure = {}
	end
	player_radiation_exposure[player.name] = radiation_exposure
end

-- Set half-life
local function set_half_life(player, half_life)
	if player_half_life == nil then
		player_half_life = {}
	end
	player_half_life[player.name] = half_life
end

-- Get radiation exposure
local function get_radiation_exposure(player)
	if player_radiation_exposure == nil then
		player_radiation_exposure = {}
	end
	result = player_radiation_exposure[player.name]
	
	if result == nil then
		return 0
	else
		return result
	end
end

-- Get half-life
local function get_half_life(player)
	if player_half_life == nil then
		player_half_life = {}
	end
	result = player_half_life[player.name]
	
	if result == nil then
		return 0
	else
		return result
	end
end

-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------

-- Calculate distance
local function calculate_distance(player_pos, entity_pos)
	local distance = math.sqrt((player_pos.x - entity_pos.x)^2 + (player_pos.y - entity_pos.y)^2)
	if distance > 0 and distance < 1 then
		return 1
	else
		return distance
	end
end

-- Calculate damage
local function calculate_damage(event)
	local player = get_player()
	local character = player.character
		
	if character then
		local half_life = {}
		local radiation_exposure = {}

		radiation_exposure = get_radiation_exposure(player)
		half_life = get_half_life(player)	
		if half_life < radiation_exposure then
			half_life = radiation_exposure
		end
		if half_life > 100 then
			half_life = 100
		end
		if half_life >= 0.1 then
			if geiger_sound == true then
				player.play_sound({path = "geiger-counter", position=character.position, volume_modifier = 0.5})
			end
			player.add_custom_alert(character, {type="virtual", name="nuclear-damage"}, {""}, false)
			character.damage(half_life, "neutral", "radioactive")
		end
		set_half_life(player, half_life)
	end
end

-- Calculate decay
local function calculate_decay(event)
	local player = get_player()

	local half_life = get_half_life(player)	
	set_half_life(player, half_life/2)
end

-- calculate radiation
local function calculate_radiation(event) 

	local player = get_player()

	if player and player.valid and player.character and player.character.valid then
		local character = player.character
		local radioactive_area = {left_top = {character.position.x -10, character.position.y -10}, right_bottom = {character.position.x +10, character.position.y +10}}
		local radiation_resistance = get_radiation_resistance(player)
		local radiation_data = {}
		local radiation_exposure = 0
		local radiation_level = 0

		-- Inventory
		for name, amount in pairs(character.get_inventory(1).get_contents()) do
	
			radiation_level = get_item_radioactivity(name, amount)
	
			if radiation_level > 0.001 then
				table.insert(radiation_data, radiation_level)
				radiation_level = 0
			end
		end

		-- Trash inventory
		local trash = character.get_inventory(defines.inventory.character_trash)
		if trash and trash.valid and not trash.is_empty() then
			for name, amount in pairs(trash.get_contents()) do
	
				radiation_level = get_item_radioactivity(name, amount)
	
				if radiation_level > 0.001 then
					table.insert(radiation_data, radiation_level)
					radiation_level = 0
				end
			end
		end

		-- Cursor
		local cursor_stack = player.cursor_stack
		if cursor_stack and cursor_stack.valid_for_read and cursor_stack.name then
	
			radiation_level = get_item_radioactivity(player.cursor_stack.name, player.cursor_stack.count)
	
			if radiation_level > 0.001 then
				table.insert(radiation_data, radiation_level)
				radiation_level = 0
			end
		end	

		-- Resource
		local count = player.surface.count_entities_filtered{area=radioactive_area, type="resource"}
		if count >=  1 then
			for _, entity in pairs(player.surface.find_entities_filtered{area=radioactive_area, type="resource"}) do
	
				local distance = calculate_distance(character.position, entity.position)
				local name = entity.name
				local amount = entity.amount
				radiation_level = (get_resource_radioactivity(name, amount) / distance)
	
				if radiation_level > 0.001 then
					table.insert(radiation_data, radiation_level)
					radiation_level = 0
				end
			end
		end

		-- Item on transport belt
		local count = player.surface.count_entities_filtered{area=radioactive_area, type="transport-belt"}
		if count >=  1 then
			for _, entity in pairs(player.surface.find_entities_filtered{area=radioactive_area, type="transport-belt"}) do
	
				for content, amount in pairs(entity.get_transport_line(1).get_contents()) do
	
					local distance = calculate_distance(character.position, entity.position)
					radiation_level = (get_item_radioactivity(content, amount) / distance)
	
					if radiation_level > 0.001 then
						table.insert(radiation_data, radiation_level)
						radiation_level = 0
					end
				end
				for content, amount in pairs(entity.get_transport_line(2).get_contents()) do
	
					local distance = calculate_distance(character.position, entity.position)
					radiation_level = (get_item_radioactivity(content, amount) / distance)
	
					if radiation_level > 0.001 then
						table.insert(radiation_data, radiation_level)
						radiation_level = 0
					end
				end
			end
		end

		-- Item on ground
		local count = player.surface.count_entities_filtered{area=radioactive_area, name="item-on-ground"}
		if count >=  1 then
			for _, entity in pairs(player.surface.find_entities_filtered{area=radioactive_area, name="item-on-ground"}) do
	
				local distance = calculate_distance(character.position, entity.position)
				local name = entity.stack.name
				local amount = entity.stack.count
				radiation_level = (get_item_radioactivity(name, amount) / distance)
	
				if radiation_level > 0.001 then
					table.insert(radiation_data, radiation_level)
					radiation_level = 0
				end
			end
		end

		-- Item in container
		local count = player.surface.count_entities_filtered{area=radioactive_area, type="container"}
		if count >=  1 then
			for _, entity in pairs(player.surface.find_entities_filtered{area=radioactive_area, type="container"}) do
				if entity.name ~= "shielded-chest" then
	
					local distance = calculate_distance(character.position, entity.position)
	
					for content, amount in pairs(entity.get_inventory(1).get_contents()) do
						radiation_level = (get_item_radioactivity(content, amount) / distance)
					end
	
					if radiation_level > 0.001 then
						table.insert(radiation_data, radiation_level)
						radiation_level = 0
					end
				end
			end
		end

		-- Item/fluid in assembling machine
		local count = player.surface.count_entities_filtered{area=radioactive_area, type="assembling-machine"}
		if count >=  1 then
			for _, entity in pairs(player.surface.find_entities_filtered{area=radioactive_area, type="assembling-machine"}) do
				
				local distance = calculate_distance(character.position, entity.position)
				local item_output = 0
				local item_input = 0
				local fluid = 0
				
				if entity.fluidbox then
					for content, amount in pairs(entity.get_fluid_contents()) do
						fluid = (get_fluid_radioactivity(content, amount) / distance)
					end
				end

				for content, amount in pairs(entity.get_inventory(defines.inventory.assembling_machine_output).get_contents()) do
					item_output = (get_item_radioactivity(content, amount) / distance)
				end
				
				for content, amount in pairs(entity.get_inventory(defines.inventory.assembling_machine_input).get_contents()) do
					item_input = (get_item_radioactivity(content, amount) / distance)
				end

				radiation_level = item_output + item_input + fluid

				if radiation_level > 0.001 then
					table.insert(radiation_data, radiation_level)
					radiation_level = 0
				end
			end
		end

		-- Fluid in pipe
		local count = player.surface.count_entities_filtered{area=radioactive_area, type="pipe"}
		if count >=  1 then
			for _, entity in pairs(player.surface.find_entities_filtered{area=radioactive_area, type="pipe"}) do
	
				local distance = calculate_distance(character.position, entity.position)
	
				for content, amount in pairs(entity.get_fluid_contents()) do
					radiation_level = (get_fluid_radioactivity(content, amount) / distance)
				end
	
				if radiation_level > 0.001 then
					table.insert(radiation_data, radiation_level)
					radiation_level = 0
				end
			end
		end

		-- Fluid in storage tank
		local count = player.surface.count_entities_filtered{area=radioactive_area, type="storage-tank"}
		if count >=  1 then
			for _, entity in pairs(player.surface.find_entities_filtered{area=radioactive_area, type="storage-tank"}) do
				if entity.name ~= "shielded-tank" then
	
					local distance = calculate_distance(character.position, entity.position)
	
					for content, amount in pairs(entity.get_fluid_contents()) do
						radiation_level = (get_fluid_radioactivity(content, amount) / distance)
					end
							
					if radiation_level > 0.001 then
						table.insert(radiation_data, radiation_level)
						radiation_level = 0
					end
				end
			end
		end

		-- Do some math
		if radiation_data[#radiation_data] ~= nil then
			radiation_level = total_round(radiation_data, 2)
		else
			radiation_level = 0
		end

		-- Give cancer to player
		if radiation_level >= 0.001 then
			
			radiation_warning = true
			perceived_radiation = radiation_level*radiation_resistance
			print_geiger_value(radiation_level, perceived_radiation, player)
			radiation_exposure = perceived_radiation
		else
			radiation_warning = false
		end
		set_radiation_exposure(player, radiation_exposure/2)
	else
		set_radiation_exposure(player, nil)
		set_half_life(player, nil)
	end
end

-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------

-- Initialise event handler
script.on_event({defines.events.on_tick}, function(event)
	if event.tick % 30 == 0 then
		if radiation_warning == true then
			local player = get_player()
			if player and player.valid and player.character and player.character.valid then
				local character = player.character
				player.add_custom_alert(character, {type="virtual", name="nuclear-alert"}, {""}, false)
				if geiger_sound == true then
					player.play_sound({path = "geiger-counter", position=character.position, volume_modifier = 0.5})
				end
			end
		end
	end
	if event.tick % 60 == 0 then
		calculate_damage{event}
	end
	if event.tick % 90 == 0 then
		calculate_radiation(event)
	end
	if event.tick % 180 == 0 then
		calculate_decay(event)
	end
end)