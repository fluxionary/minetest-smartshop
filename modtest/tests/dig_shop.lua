modtest.with_fresh_environment(function(state, env)
	it("dig a shop", function()
		local to_place_pos = env.shop_pos
		local node_before_place = minetest.get_node(to_place_pos)
		assert(node_before_place.name == "air", "nothing there yet")

		local owner = env.player_owner
		local placed_stack, placed_pos = minetest.item_place(ItemStack("smartshop:shop"), owner, {
			type = "node",
			under = to_place_pos,
			above = to_place_pos,
		})

		assert(vector.equals(to_place_pos, placed_pos), "placed to correct spot")

		local node_before_dig = minetest.get_node(placed_pos)
		assert(node_before_dig.name == "smartshop:shop", "correct node placed")

		local def = minetest.registered_nodes["smartshop:shop"]
		assert(def.diggable, "shop is not diggable?!")

		local shop_obj = smartshop.api.get_object(placed_pos)
		assert(shop_obj, "didn't get shop obj")
		assert(shop_obj.inv:is_empty("main"), "inventory not empty?")
		assert(shop_obj:is_owner(owner), "owner isn't the owner?!")
		assert(shop_obj:can_access(owner), "owner can't access?!")

		assert(def.can_dig(to_place_pos, owner), "shop is not diggable by owner?!")

		assert(minetest.node_dig(placed_pos, node_before_dig, owner), "node not dug successfully")
		local node_after_dig = minetest.get_node(placed_pos)
		assert(
			node_after_dig.name == "air",
			"after attempting to dig the shop, the result is '" .. node_after_dig.name .. "'"
		)
		assert(owner:get_inventory():contains_item("main", "smartshop:shop"), "owner got a shop item")
	end)
end)
