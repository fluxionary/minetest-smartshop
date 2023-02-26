modtest.with_fresh_environment(function(state, env)
	it("place a shop and validate that it is correctly set up", function()
		local place_at = env.shop_pos
		local owner = env.player_owner
		local node_before = minetest.get_node(place_at)
		assert(node_before.name == "air", "before placing, the node is " .. node_before.name)

		assert(vector.check(place_at))
		local placed_stack, placed_pos = minetest.item_place(ItemStack("smartshop:shop"), owner, {
			type = "node",
			under = place_at,
			above = place_at,
		})
		assert(vector.check(placed_pos), "placed location is not a vector " .. dump(placed_pos))
		assert(vector.equals(placed_pos, place_at), "wasn't placed to right position")
		assert(placed_stack:is_empty(), "item wasn't used up on place")
		local node = minetest.get_node(place_at)
		assert(node.name == "smartshop:shop", "correct node wasn't placed")
	end)
end)
