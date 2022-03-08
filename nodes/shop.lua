local S = smartshop.S
local deepcopy = smartshop.util.deepcopy
local nodes = smartshop.nodes

smartshop.shop_node_names = {}

local smartshop_def = {
	description = S("Smartshop"),
	tiles = {"(default_chest_top.png^[colorize:#FFFFFF77)^default_obsidian_glass.png"},
	use_texture_alpha = "opaque",
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
	on_destruct = nodes.on_destruct,
	on_blast = function() end,  -- explosion-proof
}

local function register_variant(name, overrides)
	local variant_def
	if overrides then
		variant_def = deepcopy(smartshop_def)
		for key, value in pairs(overrides) do
			variant_def[key] = value
		end
		variant_def.drop = "smartshop:shop"
		variant_def.groups.not_in_creative_inventory = 1
	else
		variant_def = smartshop_def
	end

	minetest.register_node(name, variant_def)
	table.insert(smartshop.shop_node_names, name)
end

local function make_variant_tiles(color)
	return {("(default_chest_top.png^[colorize:#FFFFFF77)^(default_obsidian_glass.png^[colorize:%s)"):format(color)}
end

register_variant("smartshop:shop")
register_variant("smartshop:shop_full", {
	tiles = make_variant_tiles("#0000FF77")
})
register_variant("smartshop:shop_empty", {
	tiles = make_variant_tiles("#FF000077")
})
register_variant("smartshop:shop_used", {
	tiles = make_variant_tiles("#00FF0077")
})
register_variant("smartshop:shop_admin", {
	tiles = make_variant_tiles("#00FFFF77")
})
