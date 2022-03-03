local nodes = smartshop.nodes

local smartshop_def = {
	description = "Smartshop",
	tiles = {"(default_chest_top.png^[colorize:#FFFFFF77)^default_obsidian_glass.png"},
	groups = {
		choppy = 2,
        oddly_breakable_by_hand = 1,
	    tubedevice = 1,
	    tubedevice_receiver = 1,
	    mesecon = 2
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.0, 0.5, 0.5, 0.5}
	},
	paramtype2 = "facedir",
	paramtype = "light",
	sunlight_propagates = true,
	light_source = 10,
	on_timer = nodes.on_timer,
	tube = {
		insert_object = nodes.tube_insert,
		can_insert = nodes.tube_can_insert,
		input_inventory = "main",
		connect_sides = {
			left = 1,
			right = 1,
			front = 1,
			back = 1,
			top = 1,
			bottom = 1}
	},
	after_place_node = nodes.after_place_node,
	on_rightclick = nodes.on_rightclick,
	allow_metadata_inventory_put = nodes.allow_metadata_inventory_put,
	allow_metadata_inventory_take = nodes.allow_metadata_inventory_take,
	allow_metadata_inventory_move = nodes.allow_metadata_inventory_move,
	on_metadata_inventory_put = nodes.on_metadata_inventory_put,
	on_metadata_inventory_take = nodes.on_metadata_inventory_take,
	can_dig = nodes.can_dig,
	on_blast = function() end,  -- explosion-proof
}

local smartshop_full_def = smartshop.util.deepcopy(smartshop_def)
smartshop_full_def.drop = "smartshop:shop"
smartshop_full_def.tiles = {"(default_chest_top.png^[colorize:#FFFFFF77)^(default_obsidian_glass.png^[colorize:#0000FF77)"}
smartshop_full_def.groups.not_in_creative_inventory = 1

local smartshop_empty_def = smartshop.util.deepcopy(smartshop_full_def)
smartshop_empty_def.tiles = {"(default_chest_top.png^[colorize:#FFFFFF77)^(default_obsidian_glass.png^[colorize:#FF000077)"}

local smartshop_used_def = smartshop.util.deepcopy(smartshop_full_def)
smartshop_used_def.tiles = {"(default_chest_top.png^[colorize:#FFFFFF77)^(default_obsidian_glass.png^[colorize:#00FF0077)"}

local smartshop_admin_def = smartshop.util.deepcopy(smartshop_full_def)
smartshop_admin_def.tiles = {"(default_chest_top.png^[colorize:#FFFFFF77)^(default_obsidian_glass.png^[colorize:#00FFFF77)"}

minetest.register_node("smartshop:shop", smartshop_def)
minetest.register_node("smartshop:shop_full", smartshop_full_def)
minetest.register_node("smartshop:shop_empty", smartshop_empty_def)
minetest.register_node("smartshop:shop_used", smartshop_used_def)
minetest.register_node("smartshop:shop_admin", smartshop_admin_def)
