require("mineunit")

mineunit("core")
mineunit("player")
mineunit("server")

fixture("nodes")
fixture("tools")

describe("API", function()
	world.layout({
		{{{x=-10,y=-10,z=-10},{x=10,y=10,z=10}}, "air"},
		{{x=0, y=0, z=0}, "smartshop:test_node"},
	})

	-- Load current mod executing init.lua
	sourcefile("init")

	-- Execute on mods loaded callbacks to finish loading.
	mineunit:mods_loaded()

	local Sam = Player("Sam")

	setup(function()
		mineunit:execute_on_joinplayer(Sam)
	end)

	teardown(function()
		mineunit:execute_on_leaveplayer(Sam)
	end)

	it("place a shop", function()
		local itemstack = ItemStack("smartshop:shop")
		local placer = minetest.get_player_by_name("Sam")
		local pointed_thing = {
			type="node",
			under=vector.new(0, 0, 0),
			above=vector.new(1, 0, 0),
		}
		assert.equals("node", itemstack:get_definition().type)
		assert.True(not placer:get_player_control().sneak)

		local placed_stack, placed_pos = minetest.item_place_node(itemstack, placer, pointed_thing)
		assert.equals("", placed_stack:to_string())
		assert.same({x=1, y=0, z=0}, placed_pos)
		assert.Nil(smartshop.api.get_object({x=0, y=0, z=0}))
		local shop = smartshop.api.get_object({x=1, y=0, z=0})
		assert.False(shop:is_unlimited())
	end)
end)
