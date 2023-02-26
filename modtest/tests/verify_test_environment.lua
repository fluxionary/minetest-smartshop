modtest.with_dirty_environment(function(state, env)
	it("verify the test environment exists", function()
		assert.is_not_nil(env.player_admin)
		assert.is_not_nil(env.player_owner)
		assert.is_not_nil(env.player_user)
		assert(vector.check(env.shop_pos))
		assert(type(ItemStack():get_tool_capabilities()) == "table", "default tool capabilities are not specified")
	end)
end)

modtest.with_fresh_environment(function(state, env)
	it("can place items in player inventory", function()
		local pos = env.shop_pos
		local player = env.player_owner
		local inv = player:get_inventory()
		assert(inv, "no inventory?")
		assert(inv:get_size("main") > 0, "no main inventory???")

		local item = ItemStack("smartshop:shop")
		assert(inv:room_for_item("main", item), "no room for item")

		local remainder = inv:add_item("main", item)
		assert(remainder:is_empty(), "failed to add item to inventory")

		minetest.handle_node_drops(pos, { item }, player)
		assert(player:get_inventory():contains_item("main", "smartshop:shop"), "player got a shop item")
	end)
end)
