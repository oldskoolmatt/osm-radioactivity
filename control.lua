---------------------
---- control.lua ----
---------------------

-- Setup hosts
OSM_local = require("utils.lib")
OSM_script = require("utils.control-script")

-- Setup index
local radiation_values = require("utils.dependencies.isotope-values")
local build_radiation_table = require("utils.table-builder").build_radiation_table
local dependencies_index =
{
	require("utils.dependencies.base").get_table(radiation_values),
	require("utils.dependencies.bob").get_table(radiation_values),
	require("utils.dependencies.angels").get_table(radiation_values),
	require("utils.dependencies.madclown").get_table(radiation_values),
	require("utils.dependencies.krastorio").get_table(radiation_values),
}
local overrides_index =
{
	require("utils.overrides.angels")
}

-- Load library
local get_player = OSM_local.get_player
local calculate_damage = OSM_script.calculate_damage
local calculate_decay = OSM_script.calculate_decay
local calculate_radiation = OSM_script.calculate_radiation

-- Generate globals
script.on_init(function()

	RKS = {}
	RKS.mod = {}
	
	global.player_half_life = {}
	global.player_radiation_exposure = {}
	
	resource_index = {}
	item_index = {}
	fluid_index = {}
	recipe_index = {}

	for i, recipe in pairs(game.recipe_prototypes) do
		if recipe.valid == true then
			recipe_index[i] = {}
			recipe_index[i].name = recipe.name
			recipe_index[i].ingredients = recipe.ingredients
			recipe_index[i].products = recipe.products
		end
	end
	
	for i, resource in pairs(game.entity_prototypes) do
		if resource.valid == true and resource.type == "resource" then
			resource_index[i] = {}
			resource_index[i].name = resource.name
		end
	end
	
	for i, item in pairs(game.item_prototypes) do
		if item.valid == true then
			item_index[i] = {}
			item_index[i].name = item.name
		end
	end
	
	for i, fluid in pairs(game.fluid_prototypes) do
		if fluid.valid == true then
			fluid_index[i] = {}
			fluid_index[i].name = fluid.name
		end
	end

	local radiation_table = build_radiation_table(dependencies_index, overrides_index, OSM_local)

	global.ores = radiation_table.ores
	global.items = radiation_table.items
	global.fluids = radiation_table.fluids
end)

-- Rebuild globals
script.on_configuration_changed(function()

	RKS = {}
	RKS.mod = {}
	
	if not global.player_half_life then global.player_half_life = {} end
	if not global.player_radiation_exposure then global.player_radiation_exposure = {} end

	resource_index = {}
	item_index = {}
	fluid_index = {}
	recipe_index = {}

	for i, recipe in pairs(game.recipe_prototypes) do
		if recipe.valid == true then
			recipe_index[i] = {}
			recipe_index[i].name = recipe.name
			recipe_index[i].ingredients = recipe.ingredients
			recipe_index[i].products = recipe.products
		end
	end
	
	for i, resource in pairs(game.entity_prototypes) do
		if resource.valid == true and resource.type == "resource" then
			resource_index[i] = {}
			resource_index[i].name = resource.name
		end
	end
	
	for i, item in pairs(game.item_prototypes) do
		if item.valid == true then
			item_index[i] = {}
			item_index[i].name = item.name
		end
	end
	
	for i, fluid in pairs(game.fluid_prototypes) do
		if fluid.valid == true then
			fluid_index[i] = {}
			fluid_index[i].name = fluid.name
		end
	end

	local radiation_table = build_radiation_table(dependencies_index, overrides_index, OSM_local)

	global.ores = radiation_table.ores
	global.items = radiation_table.items
	global.fluids = radiation_table.fluids
end)

-- Initialise event handler
script.on_event({defines.events.on_tick}, function(event)
	if event.tick % 30 == 0 then -- 60
		calculate_damage(event)
	end
	if event.tick % 60 == 0 then -- 90
		calculate_radiation(event)
	end
	if event.tick % 90 == 0 then -- 180
		calculate_decay(event)
	end
end)

-- Reset radiation values on player death
script.on_event(defines.events.on_player_died, function(event)

    local player = game.connected_players[event.player_index]
	local character = player.character
	
	global.player_radiation_exposure[player.name] = nil
	global.player_half_life[player.name] = nil
	
	player.remove_alert{character, {type="virtual", name="nuclear-damage"}}
	player.remove_alert{character, {type="virtual", name="nuclear-alert"}}
end)