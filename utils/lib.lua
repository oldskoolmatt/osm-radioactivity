-- Setup function host
local local_function = {}


-- Get local player
function local_function.get_player()
	for _, player in pairs(game.connected_players) do
		return player
	end
end

-- Returns total radiation level rounded up
function local_function.total_round(table, decimals)
	local sum = 0
	local power = 10^decimals
	for _, v in pairs(table) do
		sum = sum+v
	end
	return math.floor(sum*power)/power
end

-- Print exposure and radiation levels
function local_function.print_geiger_value(radiation_level, exposure_level, player)

	local print_millibobs = settings.global["osm-rad-print-millibobs"].value
	local print_exposure = settings.global["osm-rad-print-exposure"].value

	-- Returns radiation level on screen
	if print_millibobs == true then
		if not radiation_level or radiation_level <= 0 then return end

		local radiation = string.format("%.2f", radiation_level)

		if radiation_level < 0.1 then
			player.print("Rad. level: [color=#27c43c]"..radiation.."[/color]") -- green

		elseif radiation_level >= 0.1 and radiation_level <= 0.19 then
			player.print("Rad. level: [color=#ffc500]"..radiation.."[/color]") -- yellow

		elseif radiation_level >= 0.2 then
			player.print("Rad. level: [color=#ff392f]"..radiation.."[/color]") -- red
		end
	end
	
	-- Returns exposure level on screen
	if print_exposure == true then

		if not exposure_level or exposure_level <= 0 then exposure_level = 0 end

		local exposure = string.format("%.2f", exposure_level)

		if exposure_level < 0.1 then
			player.print("[color=#e5a4e1]Exposure: [/color][color=#27c43c]"..exposure.."[/color]") -- green

		elseif exposure_level >= 0.1 and radiation_level <= 0.19 then
			player.print("[color=#e5a4e1]Exposure: [/color][color=#ffc500]"..exposure.."[/color]") -- yellow

		elseif exposure_level >= 0.2 then
			player.print("[color=#e5a4e1]Exposure: [/color][color=#ff392f]".. exposure.."[/color]") -- red
		end
	end
end

-- Returns radiation resistance
function local_function.get_radiation_resistance(player)

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

-- Returns geiger counter sound
function local_function.play_geiger_sound(player)
	if player and player.valid and player.character and player.character.valid then
		local character = player.character
		if settings.global["osm-rad-geiger-sound"].value == true then
			return player.play_sound({path = "geiger-counter", position=character.position, volume_modifier = 0.5})
		end
	end
end

-- Returns warning alert
function local_function.warning_alert(player)
	if player and player.valid and player.character and player.character.valid then
		local character = player.character
		return player.add_custom_alert(character, {type="virtual", name="nuclear-alert"}, {""}, false)
	end
end

-- Returns damage alert
function local_function.damage_alert(player)
	if player and player.valid and player.character and player.character.valid then
		local character = player.character
		return player.add_custom_alert(character, {type="virtual", name="nuclear-damage"}, {""}, false)
	end
end

-- Assign locale descriptions
function local_function.make_description(type, prototype, prototype_name, radioactivity)
	
	local OSM_table = require("control-table")
	local radioactive_ores = OSM_table.ores
	local radioactive_items = OSM_table.items
	local radioactive_fluids = OSM_table.fluids
	
	for radioactive_fluid, radioactivity in pairs(radioactive_fluids) do
		radioactive_items[radioactive_fluid.."-barrel"] = radioactivity*50
	end

	local localised_description = {"", "[font=default-semibold][color=#ffe6c0]Radioactivity:[/color][/font] "..radioactivity.." MilliBobs"}
	
	if type.name == prototype_name  then
		prototype[prototype_name].localised_description = localised_description
	elseif type.name == "infinite-"..prototype_name then
		prototype["infinite-"..prototype_name].localised_description = localised_description
	end
end
	
return local_function