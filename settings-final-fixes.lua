----------------------------------
---- settings-final-fixes.lua ----
----------------------------------

-- Parse OSM-lib functions
require("__osm-lib__.functions.settings-stage")

-- Amator Phasma's Nuclear compatibility
OSM.lib.setting.force_disable("apm_lib_radiation_dmg")
OSM.lib.setting.hide_setting("double-setting", "apm_lib_radiation_dmg_multiplier")
