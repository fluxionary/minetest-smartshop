local state = ...

do
	state:set_current_modname("smartshop")

	minetest.register_node("smartshop:node", {})

	minetest.register_tool("smartshop:tool", {})
	minetest.register_craftitem("smartshop:gold", {})

	minetest.register_craftitem("smartshop:currency_1", { stack_max = 10000 })
	minetest.register_craftitem("smartshop:currency_2", {})
	minetest.register_craftitem("smartshop:currency_5", {})
	minetest.register_craftitem("smartshop:currency_10", {})
	minetest.register_craftitem("smartshop:currency_20", {})
	minetest.register_craftitem("smartshop:currency_50", {})
	minetest.register_craftitem("smartshop:currency_100", {})
	minetest.register_craftitem("smartshop:currency_10000", { stack_max = 10000 })

	if not smartshop.has.currency then
		-- force loading this code
		smartshop.dofile("compat", "currency")
	end

	state:set_current_modname()
end

state:create_player("admin", "admin")
state:create_player("owner", "owner")
state:create_player("user", "user")

minetest.set_player_privs("admin", { interact = true, server = true, protection_bypass = true })
minetest.set_player_privs("owner", { interact = true })
minetest.set_player_privs("user", { interact = true })

local player_admin = state:try_join_player("admin", "admin")
local player_owner = state:try_join_player("owner", "owner")
local player_user = state:try_join_player("user", "user")

player_admin:get_inventory():set_size("main", 32)
player_owner:get_inventory():set_size("main", 32)
player_user:get_inventory():set_size("main", 32)

local shop_pos = vector.zero()

state:load_mapblock(modtest.util.get_blockpos(shop_pos))

return {
	player_admin = player_admin,
	player_owner = player_owner,
	player_user = player_user,
	shop_pos = shop_pos,

	inv_count = function(inv, listname, item_name)
		local count = 0
		for _, item in ipairs(inv:get_list(listname)) do
			if item:get_name() == item_name then
				count = count + item:get_count()
			end
		end
		return count
	end,

	put_in_shop = function(shop, item, player)
		local stack = ItemStack(item)
		for i = 1, 32 do
			if shop.inv:get_stack("main", i):is_empty() then
				shop.inv:set_stack("main", i, stack)
				shop:on_metadata_inventory_put("main", i, stack, player)
				return
			end
		end
	end,
}
