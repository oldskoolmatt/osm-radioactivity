------------------------------
---- control.lua/data.lua ----
------------------------------

-- Setup function host
local RKS = {}

-- Check if ingredient/result is candidate for being radioactive
function RKS.prototype_is_candidate(prototype)

	local prototype_is_allowed = OSM.RKS.utils.prototype_is_allowed

	--Allowed
	local dictionary =
	{
		"radium",
		"thorium",
		"uranium",
		"plutonium",
		"americium",
		"neptunium",
		"protactinium",
		"polonium",
		"caesium",
		"iodine",
		"strontium",
		"zinc",
		"cobalt",
		"tritium",
		"technetium",
		"californium",
		"MOX",
		"mox",
		"mixed-oxide",
		"radioactive",
		"uranyl",
		"diuranate",
		"nuclear",
		"atomic",
		"hexafluoride",
		"yellowcake",
		"purex",
		"truex",
		"diamex",
		"sanex",
		"unex",
		"radiothermal",
	}

	-- Check if prototype type is allowed
	if prototype_is_allowed(prototype) then

		-- Check if prototype name is candidate
		for _, word in pairs(dictionary) do
			if string.find(prototype.name, word, 1, true) then return true end
		end
	end
end

function RKS.prototype_is_allowed(prototype)

	-- not allowed
	local dictionary =
	{
		"warhead",
		"bomb",
		"rocket",
		"rounds",
		"grenade",
		"shell",
		"bullet",
		"shotgun",
		"turret",
		"breeder-reactor",
		"nuclear-reactor",
		"centrifuge",
	}

	-- not allowed
	local types =
	{
		"ammo",
		"land-mine",
		"gun",
		"capsule",
		"ammo-turret",
		"electric-turret",
		"combat-robot",
	}

	-- Check from type
	if types[prototype.type] then return false end

	-- Check from name
	for _, word in pairs(dictionary) do
		if string.find(prototype.name, word, 1, true) then return false end
	end
	
	return true
end

-- Get radiation table index
function RKS.get_radiation_index(radiation_table)
	local count = 0
	for _, index in pairs(radiation_table) do
		for _ in pairs(index) do
			count = count+1
		end
	end
	return count
end

-- Checks if radiation value can be edited	
function RKS.value_can_be_edited(name)
	if not OSM.RKS.values.items[name] and not OSM.RKS.values.fluids[name] then
		return true
	end
end

-- Returns total radiation level nicely rounded up
function RKS.finalise_radiation_table(radiation_table, game_data)
	
	local function round_up(radioactivity)

		local function truncate(radioactivity, power)
			power = 10^power
			return math.floor(radioactivity*power)/power
		end
		
		radioactivity = truncate(radioactivity, 4)

		local count = 1
		local last_decimal = 0

		local length = #string.match(tostring(radioactivity), ".(.*)")

		if length > 4 then
			last_decimal = tonumber(string.sub(tostring(radioactivity), -1))
			if last_decimal >= 5 then radioactivity = radioactivity+0.001 end
		end
		
		if not radioactivity or radioactivity == 0 then return 0 end
		
		if radioactivity >= 10 or (radioactivity < 10 and radioactivity >= 1) then
			return truncate(radioactivity, 3)/count
		end

		if radioactivity < 10 then
			::retry::
			radioactivity = radioactivity*10
			count = count*10
			if radioactivity >= 10 then
				return truncate(radioactivity/count, 3)
			end
			goto retry
		end
	end

	for ore, radioactivity in pairs(radiation_table.ore) do
		if not radioactivity or radioactivity == 0 then
			radiation_table.ore[ore] = nil
		else
			radiation_table.ore[ore] = round_up(radioactivity)
		end
	end

	for item, radioactivity in pairs(radiation_table.item) do
		if not radioactivity or radioactivity == 0 then
			radiation_table.item[item] = nil
		else
			radiation_table.item[item] = round_up(radioactivity)
		end
	end

	for fluid, radioactivity in pairs(radiation_table.fluid) do
		if not radioactivity or radioactivity == 0 then
			radiation_table.fluid[fluid] = nil
		else
			radiation_table.fluid[fluid] = round_up(radioactivity)
		end
	end
	
	for entity, radioactivity in pairs(radiation_table.entity) do
		if not radioactivity or radioactivity == 0 then
			radiation_table.entity[entity] = nil
		else
			radiation_table.entity[entity] = round_up(radioactivity)
		end
	end

	return radiation_table
end

-- Make description tooltip 
function RKS.make_description(prototype)

	local tooltip = {""}

	-- Resources
	if prototype.type == "resource" then
		tooltip = {"", "[img=osm-rks-tooltip-radioactive] ", "[font=default-semibold][color=yellow]", {"string-name.osm-resource-tooltip"}, "[/color][/font]"}

	-- Items
	elseif OSM.data.item[prototype.type] then
		tooltip = {"", "[img=osm-rks-tooltip-radioactive] ", "[font=default-semibold][color=yellow]", {"string-name.osm-item-tooltip"}, "[/color][/font]"}

	-- Fluids
	elseif prototype.type == "fluid" then
		tooltip = {"", "[img=osm-rks-tooltip-radioactive] ", "[font=default-semibold][color=yellow]", {"string-name.osm-fluid-tooltip"}, "[/color][/font]"}

	-- Entities
	elseif OSM.data.entity[prototype.type] then
		tooltip = {"", "[img=osm-rks-tooltip-radioactive] ", "[font=default-semibold][color=yellow]", {"string-name.osm-entity-tooltip"}, "[/color][/font]"}
	end
	
	prototype.localised_description = tooltip
end

-- Check if player is doing fine
function RKS.player_check(player)
	if player and player.valid and player.character and player.character.valid then return true end
end

return RKS