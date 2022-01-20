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

-- Returns true radiation level on screen
local function print_millibob_value(radiation_level, player)
	
	local millibob_value = string.format("%.2f", radiation_level)

	if radiation_level < 0.1 then
		return player.print("Rad. level: [color=#27c43c]"..millibob_value.."[/color]") -- green

	elseif radiation_level >= 0.1 and radiation_level <= 0.19 then
		return player.print("Rad. level: [color=#ffc500]"..millibob_value.."[/color]") -- yellow

	elseif radiation_level >= 0.2 then
		return player.print("Rad. level: [color=#ff392f]"..millibob_value.."[/color]") -- red
	end
end

-- Returns perceived radiation level on screen
local function print_perceived_value(radiation_level, player)
	
	local perceived_value = string.format("%.2f", radiation_level)
	
	if perceived_value == "0.00" then return end

	if radiation_level < 0.1 then
		return player.print("[color=#e5a4e1]Exposure: [/color][color=#27c43c]"..perceived_value.."[/color]") -- green

	elseif radiation_level >= 0.1 and radiation_level <= 0.19 then
		return player.print("[color=#e5a4e1]Exposure: [/color][color=#ffc500]"..perceived_value.."[/color]") -- yellow

	elseif radiation_level >= 0.2 then
		return player.print("[color=#e5a4e1]Exposure: [/color][color=#ff392f]".. perceived_value.."[/color]") -- red
	end
end


function local_function.print_geiger_value(millibob_value, perceived_level, player)

	local print_millibobs = settings.global["osm-rad-print-millibobs"]
	local print_perceived = settings.global["osm-rad-print-exposure"]

	if print_millibobs.value == true then
		print_millibob_value(millibob_value, player)
	end
	if print_perceived.value == true then
		print_perceived_value(perceived_level, player)
	end
end

return local_function