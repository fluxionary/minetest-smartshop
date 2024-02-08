local inv_count = smartshop.tests.inv_count

smartshop.tests.register_test({
	name = "split payment purchase",
	func = function(player, state)
		minetest.set_player_privs(player:get_player_name(), {
			interact = true,
			server = true,
			[smartshop.settings.admin_shop_priv] = true,
		})

		local under = state.place_shop_against
		local shop_at = vector.subtract(state.place_shop_against, vector.new(0, 0, 1))

		minetest.remove_node(shop_at)
		minetest.item_place_node(ItemStack("smartshop:shop"), player, { type = "node", under = under, above = shop_at })

		local shop = smartshop.api.get_object(shop_at)

		shop.inv:set_stack("pay3", 1, "smartshop:currency_1 2")
		shop.inv:set_stack("give3", 1, "smartshop:gold 99")
		shop:update_appearance()

		local player_inv = player:get_inventory()
		player_inv:set_list("main", {
			"smartshop:currency_1 97",
			"smartshop:currency_1 2",
			"smartshop:gold",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
		})

		shop:receive_fields(player, { buy3a = true })

		assert(inv_count(player_inv, "main", "smartshop:gold") == 100, "correct amount was received")
		assert(inv_count(player_inv, "main", "smartshop:currency_1") == 97, "correct amount was spent")
		assert(inv_count(player_inv, "main", "smartshop:tool") == 29, "tools not replaced")
	end,
})

smartshop.tests.register_test({
	name = "split payment purchase failure",
	func = function(player, state)
		minetest.set_player_privs(player:get_player_name(), {
			interact = true,
			server = true,
			[smartshop.settings.admin_shop_priv] = true,
		})

		local under = state.place_shop_against
		local shop_at = vector.subtract(state.place_shop_against, vector.new(0, 0, 1))

		minetest.remove_node(shop_at)
		minetest.item_place_node(ItemStack("smartshop:shop"), player, { type = "node", under = under, above = shop_at })

		local shop = smartshop.api.get_object(shop_at)

		shop.inv:set_stack("pay3", 1, "smartshop:currency_1 2")
		shop.inv:set_stack("give3", 1, "smartshop:gold 99")
		shop:update_appearance()

		local player_inv = player:get_inventory()
		player_inv:set_list("main", {
			"smartshop:currency_1 2",
			"smartshop:currency_1 97",
			"smartshop:gold",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
			"smartshop:tool",
		})

		shop:receive_fields(player, { buy3a = true })

		assert(inv_count(player_inv, "main", "smartshop:gold") == 1, "correct amount was received")
		assert(inv_count(player_inv, "main", "smartshop:currency_1") == 99, "correct amount was spent")
		assert(inv_count(player_inv, "main", "smartshop:tool") == 29, "tools not replaced")
	end,
})
