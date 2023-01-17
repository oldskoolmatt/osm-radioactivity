---------------------
---- control.lua ----
---------------------

-- Setup hosts
OSM = {}
OSM.control_stage = 1

-- Load core
require("__osm-lib__.core.lib-core")

OSM.RKS = {}
OSM.RKS.utils = require("utils.lib")
OSM.RKS.build = require("script.build")
OSM.RKS.values = require("script.values")
OSM.RKS.init = require("script.init")
OSM.RKS.runtime = require("script.runtime")
OSM.RKS.gui = require("script.gui")

-- Initialize
script.on_init(OSM.RKS.init.on_init)
script.on_configuration_changed(OSM.RKS.init.on_init)
script.on_load(OSM.RKS.init.on_load)

-- Create player gui
script.on_event(defines.events.on_player_joined_game, OSM.RKS.gui.create_gui)
script.on_event(defines.events.on_player_respawned, OSM.RKS.gui.create_gui)
script.on_event(defines.events.on_player_toggled_map_editor, OSM.RKS.gui.create_gui)

-- Reset radiation values and gui on player death
script.on_event(defines.events.on_pre_player_died, OSM.RKS.runtime.death_solves_all_problems)
