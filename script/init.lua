---------------------
---- control.lua ----
---------------------

local RKS = {}

function RKS.on_init()

	-- Set on_first_tick() trigger state
	global.first_tick_trigger = true

	-- Init before tick
	if not global.player_half_life then global.player_half_life = {} end
	if not global.player_radiation_exposure then global.player_radiation_exposure = {} end
	
	global.radioactive_ores = {}
	global.radioactive_items = {}
	global.radioactive_fluids = {}
	global.radioactive_entities = {}

	OSM.RKS.init.addons()
	OSM.RKS.build.core()
	
	-- Init on first tick
	script.on_event(defines.events.on_tick, OSM.RKS.init.on_first_tick)
end

-- Init on first tick
function RKS.on_first_tick()
	if global.first_tick_trigger then

		-- Make GUI for connected players
		for _, player in pairs(game.connected_players) do
			if player and player.valid and player.character and player.character.valid then
				OSM.RKS.gui.init_gui(player)
			end
		end

		global.first_tick_trigger = nil

	else -- Unregister on_first_tick() and switch to runtime
		script.on_event(defines.events.on_tick, OSM.RKS.init.runtime_handler)
	end
end

-- Init on load
function RKS.on_load()
	if global.first_tick_trigger then
		script.on_event(defines.events.on_tick, OSM.RKS.init.on_first_tick)
	else
		script.on_event(defines.events.on_tick, OSM.RKS.init.runtime_handler)
	end
end

-- Sets the environment for mod specific compatibility needs
function RKS.addons()
	
	local get_table_length = OSM.utils.get_table_length
	local mod_installed = OSM.utils.mod_installed
	
	-- Disables Krastorio radioactivity system
	if mod_installed("Krastorio2") then
		remote.call("kr-radioactivity", "set_enabled", false)
	end
end

-- Runtime handler
function RKS.runtime_handler(event)
	if event.tick % 30 == 0 then
		for _, player in pairs(game.connected_players) do
			OSM.RKS.runtime.calculate_damage(player)
		end
	end
	if event.tick % 60 == 0 then
		for _, player in pairs(game.connected_players) do
			OSM.RKS.runtime.calculate_radiation(player)
		end
	end
	if event.tick % 120 == 0 then
		for _, player in pairs(game.connected_players) do
			OSM.RKS.runtime.calculate_decay(player)
		end
	end
end

return RKS