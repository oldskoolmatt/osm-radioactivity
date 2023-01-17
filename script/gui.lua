local RKS = {}

-- GUI init
function RKS.init_gui(player)

	-- Set the environment
	local location = {x=848, y=492}
	local display_HUD = player.mod_settings["osm-rks-display-gui"].value
	local move_HUD = player.mod_settings["osm-rks-move-gui"].value

	-- Initialise
	if player.gui.screen["radiation-gui"] then

		-- GUI visibility
		if display_HUD == "always-off" then
			display_HUD = false
		else
			display_HUD = true
		end
		
		-- Check if player is in editor
		if player.controller_type == defines.controllers.editor then
			display_HUD = false
		end
		
		-- Remember GUI position
		location = player.gui.screen["radiation-gui"].location

		-- Destroy GUI
		player.gui.screen["radiation-gui"].destroy()
	end

	-- Make frame
	local gui = player.gui.screen.add{type="frame", name="radiation-gui", direction="vertical"}
	gui.style.top_padding = 0
	gui.style.right_padding = 0
	gui.style.bottom_padding = 0
	gui.style.left_padding = 0
	gui.style.size = {225, 96}
	gui.visible = display_HUD
	gui.location = location
	
	local background = gui.add{type="sprite", name="background", sprite="osm-rks-gui-background", direction="vertical"}
	background.style.horizontal_align = "center"
	background.style.vertical_align = "center"
	background.style.left_padding = 0
	background.style.width = 215
	background.style.height = 78
	background.style.stretch_image_to_widget_size = true
	
	local dragger = gui.add{type="empty-widget", name="dragger", style="draggable_space"}
	dragger.style.size = {200, 5}
	dragger.style.horizontal_align = "center"
	dragger.style.vertical_align = "center"
	dragger.drag_target = gui
	dragger.visible = move_HUD

	local flow_1 = background.add{type="flow", name="line-1"}
	flow_1.add{type="label", name="radiation-level"}
	flow_1["radiation-level"].style.font = "default-large"
	flow_1.style.left_padding = 5
	
	local flow_2 = background.add{type="flow", name="line-2"}
	flow_2.add{type="label", name="exposure-level"}
	flow_2["exposure-level"].style.font = "default-large"
	flow_2.style.left_padding = 5
	flow_2.style.top_padding = 20
	
	local flow_3 = background.add{type="flow", name="line-3"}
	flow_3.add{type = "label", name="shield-level"}
	flow_3["shield-level"].style.font = "default-large"
	flow_3.style.left_padding = 5
	flow_3.style.top_padding = 52
end

-- Make player GUI
function RKS.create_gui(event)

	local player = game.get_player(event.player_index)

	if player and player.valid then OSM.RKS.gui.init_gui(player) end
end

-- Output values
function RKS.display_gui(player, player_exposure, radiation_shield)

	if not player.gui.screen["radiation-gui"] then OSM.RKS.gui.init_gui(player) end

	local display_HUD = player.mod_settings["osm-rks-display-gui"].value
	local move_HUD = player.mod_settings["osm-rks-move-gui"].value
	local radiation_level = global.player_radiation_exposure[player.name] or 0
	local capacity = 0
	local shield_level = 0
	local float = 0
	local text = ""
	local message = {}

	-- Make values float 0/10%
	if not OSM.debug_mode then float = math.random(0, 10) end

	-- Enable/disable GUI dragger
	if move_HUD then
		player.gui.screen["radiation-gui"]["dragger"].visible = true
	else
		player.gui.screen["radiation-gui"]["dragger"].visible = false
	end

	-- GUI display always off
	if display_HUD == "always-off" then
		player.gui.screen["radiation-gui"].visible = false
	end
	
	-- GUI display always on
	if display_HUD == "always-on" then
		player.gui.screen["radiation-gui"].visible = true
	end

	-- GUI display dynamic
	if display_HUD == "dynamic" then
		if radiation_level == 0 and player_exposure == 0 then
			player.gui.screen["radiation-gui"].visible = false
		else
			player.gui.screen["radiation-gui"].visible = true
		end
	end

	if not player.gui.screen["radiation-gui"].visible then return end

	-- Check shield
	if radiation_shield then

		local armor = player.get_inventory(defines.inventory.character_armor)[1]

		if armor.valid_for_read and armor.grid then
			capacity = armor.grid.battery_capacity or 0
			shield_level = armor.grid.available_in_batteries or 0
		end
	end
	
	-- Shield level
	text = string.format("%.0f", shield_level/capacity*100)

	if not radiation_shield then
		text = {"", "[color=#ff392f]", {"string-name.osm-shield-missing"}, "![/color]"}
	elseif capacity == 0 then
		text = {"", "[color=#ff392f]", {"string-name.osm-shield-unpowered"}, "![/color]"}
	elseif shield_level < capacity/100 and shield_level < 10^6 then
		text = {"", "[color=#ff392f]", {"string-name.osm-shield-down"}, "![/color]"}
	elseif shield_level >= capacity*21/100 then
		player_exposure = 0
		text = "[color=#27c43c]"..text.."%[/color]" -- green
	elseif shield_level >= capacity*11/100 and shield_level < capacity*21/100 then
		player_exposure = 0
		text = "[color=#ffc500]"..text.."%[/color]" -- yellow
	elseif shield_level < capacity*11/100 then
		player_exposure = 0
		text = "[color=#ff392f]"..text.."%[/color]" -- red
	end
	message[3] = {"", "[color=#1cafb7]", {"string-name.osm-shield-level"}, ": [/color]", text}

	-- Player exposure
	text = string.format("%.2f", player_exposure+player_exposure*float/100)

	if player_exposure < 0.1 then
		text = "[color=#27c43c]"..text.."[/color]" -- green
	elseif player_exposure >= 0.1 and player_exposure < 0.2 then
		text = "[color=#ffc500]"..text.."[/color]" -- yellow
	elseif player_exposure >= 0.2 then
		text = "[color=#ff392f]"..text.."[/color]" -- red
	end
	message[2] = {"", "[color=#e5a4e1]", {"string-name.osm-exposure-level"}, ": [/color]", text}

	-- Global radioactivity
	text = string.format("%.2f", radiation_level+radiation_level*float/100)

	if radiation_level < 0.1 then
		text = "[color=#27c43c]"..text.."[/color]" -- green
	elseif radiation_level >= 0.1 and radiation_level < 0.2 then
		text = "[color=#ffc500]"..text.."[/color]" -- yellow
	elseif radiation_level >= 0.2 then
		text = "[color=#ff392f]"..text.."[/color]" -- red
	end
	message[1] = {"", {"string-name.osm-radiation-level"}, ": ", text}

	-- Output to GUI
	if player.gui.screen["radiation-gui"] then
		player.gui.screen["radiation-gui"]["background"]["line-1"]["radiation-level"].caption = message[1]
		player.gui.screen["radiation-gui"]["background"]["line-2"]["exposure-level"].caption = message[2]
		player.gui.screen["radiation-gui"]["background"]["line-3"]["shield-level"].caption = message[3]
	end
end

-- Output alerts
function RKS.display_alerts(player, player_exposure)

	if not player_exposure then player_exposure = 0 end

	local character = player.character
	local radiation_level = global.player_radiation_exposure[player.name] or 0

	local geiger_sound = player.mod_settings["osm-rks-geiger-sound"].value
	local geiger_path = {path="osm-rks-geiger-sound", position=character.position, volume_modifier=0.5}

	-- Damage warnings
	if player_exposure >= 0.2 then
		if geiger_sound then player.play_sound(geiger_path) end
		player.remove_alert{entity=character, type=defines.alert_type.custom, icon={type="item", name="osm-rks-nuclear-alert"}, message="string-name.osm-nuclear-alert"}
		player.add_custom_alert(character, {type="item", name="osm-rks-nuclear-danger"}, {"string-name.osm-nuclear-danger"}, false)

	-- Radiation warning
	elseif (player_exposure < 0.2 and player_exposure >= 0.01) or (radiation_level < 0.2 and radiation_level >= 0.01) then
		if geiger_sound then player.play_sound(geiger_path) end
		player.remove_alert{entity=character, type=defines.alert_type.custom, icon={type="item", name="osm-rks-nuclear-danger"}, message="string-name.osm-nuclear-danger"}
		player.add_custom_alert(character, {type="item", name="osm-rks-nuclear-alert"}, {"string-name.osm-nuclear-alert"}, false)
	end

	-- Remove warnings
	if radiation_level == 0 and player_exposure == 0 then
		player.remove_alert{entity=character, type=defines.alert_type.custom, icon={type="item", name="osm-rks-nuclear-alert"}, message="string-name.osm-nuclear-alert"}
		player.remove_alert{entity=character, type=defines.alert_type.custom, icon={type="item", name="osm-rks-nuclear-danger"}, message="string-name.osm-nuclear-danger"}
	end
end


return RKS