------------------
---- data.lua ----
------------------

-- Set mod name
OSM.mod = "Radioactivity Kills Slowly"

-- Utils path
require("__osm-lib__.functions.utils")

-- Stores local files
OSM.RKS = {}
OSM.RKS.utils = require("utils.lib")
OSM.RKS.build = require("script.build")
OSM.RKS.values = require("script.values")

-- Load prototypes
require("prototypes.entities")
require("prototypes.recipe")
require("prototypes.item")
require("prototypes.equipment")
require("prototypes.technology")
require("prototypes.gui")
require("prototypes.misc")

OSM.lib.recipe_replace_ingredient("steel-plate", "titanium-plate", "osm-rks-radiation-shield-equipment")
OSM.lib.technology_add_prerequisite("titanium-processing", "osm-rks-radiation-shield-equipment")
OSM.lib.technology_add_unlock("osm-rks-shielded-chest", "uranium-processing")
OSM.lib.technology_add_unlock("osm-rks-shielded-tank", "uranium-processing")
OSM.lib.technology_add_unlock("osm-rks-hazmat-suit", "plastics")

local storage_tank = settings.startup["osm-rks-enable-shielded-tank"].value
if not storage_tank then OSM.lib.disable_prototype("all", "osm-rks-shielded-tank") end

OSM.mod = nil