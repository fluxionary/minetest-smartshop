local nodes = smartshop.nodes

minetest.register_node("smartshop:wifistorage", {
	description = "Smartshop external storage",
	tiles = {"default_chest_top.png^[colorize:#ffffff77^default_obsidian_glass.png"},
	groups = {
		choppy = 2,
		oddly_breakable_by_hand = 1,
		tubedevice = 1,
		tubedevice_receiver = 1,
		mesecon = 2
	},
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
			bottom = 1
		}
	},
	after_place_node = nodes.after_place_node,
	on_rightclick = nodes.on_rightclick,
	allow_metadata_inventory_put = nodes.allow_metadata_inventory_put,
	allow_metadata_inventory_take = nodes.allow_metadata_inventory_take,
	allow_metadata_inventory_move = nodes.allow_metadata_inventory_move,
	on_metadata_inventory_put = nodes.on_metadata_inventory_put,
	on_metadata_inventory_take = nodes.on_metadata_inventory_take,
	can_dig = nodes.can_dig,
	on_blast = function()
	end,
})
