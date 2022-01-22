---------------------
---- control.lua ----
---------------------

-- Radiation values
local rad_uranium_ore = 0.002		-- Ore
local rad_thorium_ore = 0.001		-- Ore
--------------------------------------
local rad_yellow_cake = 0.2			-- Item
local rad_uranium_238 = 0.5			-- Item
local rad_uranium_236 = 12			-- Item
local rad_uranium_235 = 3			-- Item
local rad_uranium_234 = 10			-- Item
local rad_uranium_233 = 20			-- Item
local rad_thorium_232 = 0.15		-- Item
local rad_neptunium_239 = 25		-- Item
local rad_neptunium_237 = 10		-- Item
local rad_plutonium_239 = 20		-- Item
local rad_plutonium_238 = 20		-- Item
local rad_radium_226 = 40			-- Item
local rad_radium_228 = 40			-- Item
local rad_americium_241 = 40		-- Item
local rad_tritium = 0.01
local rad_depleted_uranium = 0.6	-- Item
local rad_uranium_plate = 0.1		-- Item
--------------------------------------
local rad_uranium_fc = 12							-- Item
local rad_plutonium_fc = 38							-- Item
local rad_thorium_fc = 6							-- Item
local rad_th_pu_fc = 23								-- Item
local rad_deuterium_fc = 2							-- Item
local rad_deuterium_2_fc = 3						-- Item
local rad_dep_mox_fc = 50							-- Item

-- local rad_mox_fc = 								-- Item
local rad_dep_uranium_fc = rad_uranium_fc*2			-- Item
local rad_dep_plutonium_fc = rad_plutonium_fc*2		-- Item
local rad_dep_thorium_fc = rad_thorium_fc*2			-- Item
local rad_dep_th_pu_fc = rad_th_pu_fc*2				-- Item
local rad_dep_deuterium_fc = 0						-- Item
local rad_dep_mox_fc = rad_dep_mox_fc*2				-- Item
--------------------------------------
local rad_uranium_hex = 0.2			-- Fluid
local rad_deuterium =  0.01			-- Fluid
local rad_tritium =  0.01			-- Fluid

-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------

-- Setup local host
local rad = {}

-- Radioactive ores
rad.ores =
{
	["uranium-ore"] = rad_uranium_ore,
	["thorium-ore"] = rad_thorium_ore
}

-- Radioactive items
rad.items =
{
	["uranium-ore"] = rad_uranium_ore,
	["thorium-ore"] = rad_thorium_ore,
	["uranium-238"] = rad_uranium_238,
	["uranium-236"] = rad_uranium_236,
	["uranium-235"] = rad_uranium_235,
	["uranium-234"] = rad_uranium_234,
	["uranium-233"] = rad_uranium_233,
	["thorium-232"] = rad_thorium_232,
	["neptunium-239"] = rad_neptunium_239,
	["neptunium-237"] = rad_neptunium_237,
	["plutonium-239"] = rad_plutonium_239,
	["plutonium-238"] = rad_plutonium_238,
	["radium-226"] = rad_radium_226,
	["radium-228"] = rad_radium_228,
	["americium-241"] = rad_americium_241,

	["uranium-fuel-cell"] = rad_uranium_fc,
	["plutonium-fuel-cell"] = rad_plutonium_fc,
	["thorium-fuel-cell"] = rad_thorium_fc,
	["thorium-plutonium-fuel-cell"] = rad_th_pu_fc,
	["deuterium-fuel-cell"] = rad_deuterium_fc,
	["deuterium-fuel-cell-2"] = rad_deuterium_2_fc,
 	["mox-fuel-cell"] = rad_mox_fc,
	["used-up-uranium-fuel-cell"] = rad_dep_uranium_fc,
	["used-up-plutonium-fuel-cell"] = rad_dep_plutonium_fc,
	["used-up-thorium-fuel-cell"] = rad_dep_thorium_fc,
	["used-up-thorium-plutonium-fuel-cell"] = rad_dep_th_pu_fc,
	["used-up-deuterium-fuel-cell"] = rad_dep_deuterium_fc,
	["used-up-deuterium-fuel-cell-2"] = rad_dep_deuterium_fc,
 	["used-up-mox-fuel-cell"] = rad_dep_mox_fc

	["uranium-hexafluoride"] = rad_uranium_hex,
	["deuterium"] = rad_tritium,
	["tritium"] = rad_tritium,

}

-- Radioactive fluids
rad.fluids =
{
	["uranium-hexafluoride"] = rad_uranium_hex,
	["deuterium"] = rad_deuterium,
	["tritium"] = rad_tritium
}

return rad