-- luacheck: globals mineunit fixture world sourcefile Player

require("mineunit")
local json = require('mineunit.lib.json')

mineunit("core")
mineunit("player")
mineunit("server")

fixture("nodes")
fixture("tools")

describe("API", function()

	-- Load current mod executing init.lua
	sourcefile("init")

	-- Execute on mods loaded callbacks to finish loading.
	mineunit:mods_loaded()

	local Admin = Player("Admin", {
		creative = true,
		protection_bypass = true,
		smartshop_admin = true,
	})
	local Sam = Player("Sam")
	local Sue = Player("Sue")

	setup(function()
		mineunit:execute_on_joinplayer(Admin)
		mineunit:execute_on_joinplayer(Sam)
		mineunit:execute_on_joinplayer(Sue)
	end)

	teardown(function()
		mineunit:execute_on_leaveplayer(Sue)
		mineunit:execute_on_leaveplayer(Sam)
		mineunit:execute_on_leaveplayer(Admin)
	end)

	before_each(function()
		world.layout({
			{{{x=-10,y=-10,z=-10},{x=10,y=10,z=10}}, "air"},
			{{x=0, y=0, z=0}, "smartshop:test_node"},
		})
	end)

	after_each(function()
		world.clear()
	end)

	it("not a shop", function()
		assert.Nil(smartshop.api.get_object({x=0, y=0, z=0}))
	end)

	it("place a shop", function()
		local itemstack = ItemStack("smartshop:shop")
		local placer = minetest.get_player_by_name("Sam")
		local pointed_thing = {
			type="node",
			under=vector.new(0, 0, 0),
			above=vector.new(1, 0, 0),
		}

		-- luacheck: push ignore 211 214
		local placed_stack, placed_pos = minetest.item_place_node(itemstack, placer, pointed_thing)

		--assert.equals("", placed_stack:to_string())  -- TODO: enable when my mineunit PR is merged
		-- luacheck: pop
		assert.same({x=1, y=0, z=0}, placed_pos)

		local shop = smartshop.api.get_object({x=1, y=0, z=0})

		assert.True(shop:is_shop())
		assert.False(shop:is_storage())
		assert.equal("Sam", shop:get_owner())
		assert.equal("(1,0,0)", shop:get_pos_as_string())
		assert.equal("1,0,0", shop:get_formspec_pos())
		assert.True(shop:is_owner(placer))
		assert.False(shop:is_owner("Admin"))
		assert.equal("1,0,0", shop:get_formspec_pos())
		assert.equal(
			'"\\u001b(T@smartshop)(Smartshop by \\u001bFSam\\u001bE)\\nThis shop is empty.\\u001bE"',
			json.encode(shop:get_infotext())
		)
		assert.True(shop:can_access("Sam"))
		assert.True(shop:can_access("Admin"))
		assert.False(shop:can_access("Sue"))
		assert.True(shop:can_dig("Sam"))
		assert.True(shop:can_dig("Admin"))
		assert.False(shop:can_dig("Sue"))

		assert.False(shop:is_unlimited())
		assert.False(shop:is_admin())
		assert.Nil(shop:get_send_pos())
		assert.Nil(shop:get_send())
		assert.Nil(shop:get_send_inv())
		assert.Nil(shop:get_refill_pos())
		assert.Nil(shop:get_refill())
		assert.Nil(shop:get_refill_inv())
		assert.True(shop:has_upgraded())
		assert.same({}, shop:get_refund())
		assert.False(shop:has_refund())
		assert.False(shop:is_strict_meta())
	end)

	it("place an admin shop", function()
		local itemstack = ItemStack("smartshop:shop")
		local placer = minetest.get_player_by_name("Admin")
		local pointed_thing = {
			type="node",
			under=vector.new(0, 0, 0),
			above=vector.new(1, 0, 0),
		}

		-- luacheck: push ignore 211 214
		local placed_stack, placed_pos = minetest.item_place_node(itemstack, placer, pointed_thing)

		--assert.equals("smartshop:shop", placed_stack:to_string())  -- TODO: enable when my mineunit PR is merged
		-- luacheck: pop

		local shop = smartshop.api.get_object({x=1, y=0, z=0})

		assert.equal("Admin", shop:get_owner())
		assert.True(shop:is_owner(placer))
		assert.True(shop:is_owner("Admin"))
		assert.False(shop:is_owner("Sam"))
		assert.equal(
			'"\\u001b(T@smartshop)(Smartshop by \\u001bFAdmin\\u001bE)\\nThis shop is empty.\\u001bE"',
			json.encode(shop:get_infotext())
		)
		assert.False(shop:can_access("Sam"))
		assert.True(shop:can_access("Admin"))
		assert.False(shop:can_access("Sue"))
		assert.False(shop:can_dig("Sam"))
		assert.True(shop:can_dig("Admin"))
		assert.False(shop:can_dig("Sue"))

		assert.True(shop:is_unlimited())
		assert.True(shop:is_admin())
	end)

	it("place a storage", function()
		local itemstack = ItemStack("smartshop:storage")
		local placer = minetest.get_player_by_name("Sam")
		local pointed_thing = {
			type="node",
			under=vector.new(0, 0, 0),
			above=vector.new(1, 0, 0),
		}

		-- luacheck: push ignore 211 214
		local placed_stack, placed_pos = minetest.item_place_node(itemstack, placer, pointed_thing)

		--assert.equals("", placed_stack:to_string())  -- TODO: enable when my mineunit PR is merged
		-- luacheck: pop
		assert.same({x=1, y=0, z=0}, placed_pos)

		local storage = smartshop.api.get_object({x=1, y=0, z=0})

		assert.False(storage:is_shop())
		assert.True(storage:is_storage())
		assert.equal("Sam", storage:get_owner())
		assert.equal("(1,0,0)", storage:get_pos_as_string())
		assert.equal("1,0,0", storage:get_formspec_pos())
		assert.True(storage:is_owner(placer))
		assert.True(storage:is_owner("Sam"))
		assert.False(storage:is_owner("Admin"))
		assert.False(storage:is_owner("Sue"))
		assert.equal("1,0,0", storage:get_formspec_pos())
		assert.equal(
			'"\\u001b(T@smartshop)External storage by: \\u001bFSam\\u001bE\\u001bE"',
			json.encode(storage:get_infotext())
		)
		assert.True(storage:can_access("Sam"))
		assert.True(storage:can_access("Admin"))
		assert.False(storage:can_access("Sue"))
		assert.True(storage:can_dig("Sam"))
		assert.True(storage:can_dig("Admin"))
		assert.False(storage:can_dig("Sue"))

		assert.equal("storage@(1,0,0)", storage:get_title())
	end)
end)
