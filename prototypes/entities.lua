------------------
---- data.lua ----
------------------

local hit_effects = require("__base__.prototypes.entity.hit-effects")

-----------------------------------------------------------------------------------------------------------------------
-- Shielded chest is based on the sprite from void chest + [https://mods.factorio.com/mod/VoidChestPlus] --------------
local shielded_chest =
{
	type = "container",
	name = "shielded-chest",
	icon = "__osm-radioactivity__/graphics/icons/shielded-chest.png",
	icon_size = 64,
	icon_mipmaps = 4,
	order = "a[items]-d[shielded-chest]",
	flags = {"placeable-neutral", "player-creation", "not-rotatable"},
	minable = {mining_time = 0.1, result = "shielded-chest"},
	max_health = 100,
	corpse = "iron-chest-remnants",
	dying_explosion = "iron-chest-explosion",
	collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
	fast_replaceable_group = "container",
	selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	damaged_trigger_effect = hit_effects.entity(),
	inventory_size = 32,
	open_sound = {filename = "__base__/sound/metallic-chest-open.ogg", volume = 0.6},
	close_sound = {filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.6},
	vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.5},
	picture =
	{
		layers =
		{
			{
				filename = "__osm-radioactivity__/graphics/entity/shielded-chest/shielded-chest.png",
				priority = "extra-high",
				width = 33,
				height = 37,
				shift = util.by_pixel(0.5, -2),
				hr_version =
				{
					filename = "__osm-radioactivity__/graphics/entity/shielded-chest/hr-shielded-chest.png",
					priority = "extra-high",
					width = 66,
					height = 74,
					shift = util.by_pixel(0.5, -2),
					scale = 0.5
				}
			},
			{	
				filename = "__osm-radioactivity__/graphics/entity/shielded-chest/shielded-chest-shadow.png",
				priority = "extra-high",
				width = 56,
				height = 24,
				shift = util.by_pixel(10, 6.5),
				draw_as_shadow = true,
				hr_version =
				{
					filename = "__osm-radioactivity__/graphics/entity/shielded-chest/hr-shielded-chest-shadow.png",
					priority = "extra-high",
					width = 112,
					height = 46,
					shift = util.by_pixel(10, 6.5),
					draw_as_shadow = true,
					scale = 0.5
				}
			}
		}
	},
	circuit_wire_connection_point = circuit_connector_definitions["chest"].points,
	circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
	circuit_wire_max_distance = default_circuit_wire_max_distance
}	data:extend({shielded_chest})
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------
-- shamelessly stolen from fluid must flow [https://mods.factorio.com/mod/FluidMustFlow] ------------------------------

local circuit_wire_connection = circuit_connector_definitions.create(universal_connector_template, {
  { variation = 26, main_offset = util.by_pixel(0, -3), shadow_offset = util.by_pixel(2, -3), show_shadow = true },
  { variation = 26, main_offset = util.by_pixel(0, 0), shadow_offset = util.by_pixel(2, 0), show_shadow = true },
  { variation = 2, main_offset = util.by_pixel(0, 3), shadow_offset = util.by_pixel(2, 3), show_shadow = true },
  { variation = 26, main_offset = util.by_pixel(0, 0), shadow_offset = util.by_pixel(2, 0), show_shadow = true },
})

-----------------------------------------------------------------------------------------------------------------------
-- Shielded tank is based on the end duct sprite from fluid must flow -------------------------------------------------
local shielded_tank =
{
	type = "storage-tank",
	name = "shielded-tank",
	icon = "__osm-radioactivity__/graphics/icons/shielded-tank.png",
	icon_size = 64,
	icon_mipmaps = 4,
	order = "b[items]-e[shielded-tank]",
	flags = {"placeable-player", "player-creation", "not-rotatable"},
	minable = {mining_time = 0.2, result = "shielded-tank"},
	max_health = 200,
	corpse = "small-remnants",
	collision_box = {{-0.3, -0.3}, {0.3, 0.3}},
	selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	fluid_box =
	{
		base_area = 20,
		pipe_covers = pipecoverspictures(),
		pipe_connections =
		{
			{position = { 0, -1}},
			{position = { 0, 1}},
			{position = {-1, 0}},
			{position = { 1, 0}},
		}
	},
	window_bounding_box = {util.by_pixel(-3, -5), util.by_pixel(3, 11)},
	pictures =
	{
		picture =
		{
		sheets =
		{
			{
				filename = "__osm-radioactivity__/graphics/entity/shielded-tank/shielded-tank.png",
				priority = "extra-high",
				frames = 1,
				width = 64,
				height = 64,
				shift = util.by_pixel(0, -1),
				hr_version =
				{
					filename = "__osm-radioactivity__/graphics/entity/shielded-tank/hr-shielded-tank.png",
					priority = "extra-high",
					frames = 1,
					width = 128,
					height = 128,
					shift = util.by_pixel(0, -1),
					scale = 0.5,
				}
			},
			{
				filename = "__osm-radioactivity__/graphics/entity/shielded-tank/shielded-tank-shadow.png",
				priority = "extra-high",
				frames = 1,
				width = 64,
				height = 64,
				shift = util.by_pixel(0, -1),
				draw_as_shadow = true,
				hr_version =
				{
					filename = "__osm-radioactivity__/graphics/entity/shielded-tank/hr-shielded-tank-shadow.png",
					priority = "extra-high",
					frames = 1,
					width = 128,
					height = 128,
					shift = util.by_pixel(0, -1),
					scale = 0.5,
					draw_as_shadow = true
				}
			}
		}
		},
		fluid_background =
		{
			filename = "__core__/graphics/empty.png",
			priority = "extra-high",
			width = 1,
			height = 1
		},
		window_background =
		{
			filename = "__core__/graphics/empty.png",
			priority = "extra-high",
			width = 1,
			height = 1,
		},
		flow_sprite =
		{
			filename = "__core__/graphics/empty.png",
			priority = "extra-high",
			width = 1,
			height = 1
		},
		gas_flow =
		{
			filename = "__core__/graphics/empty.png",
			priority = "extra-high",
			line_length = 1,
			width = 1,
			height = 1,
			frame_count = 1,
			axially_symmetrical = false,
			direction_count = 1,
			animation_speed = 0.25,
		}
	},
	flow_length_in_ticks = 360,
	vehicle_impact_sound =	{ filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
	working_sound =
	{
		sound =
		{
			filename = "__base__/sound/storage-tank.ogg",
			volume = 0.8
		},
		match_volume_to_activity = true,
		apparent_volume = 1.5,
		max_sounds_per_type = 3
	},
    circuit_wire_connection_points = circuit_wire_connection.points,
    circuit_connector_sprites = circuit_wire_connection.sprites,
	circuit_wire_max_distance = default_circuit_wire_max_distance
}	data:extend({shielded_tank})
