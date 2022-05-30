-- luacheck: globals mineunit fixture world sourcefile Player

require("mineunit")

mineunit("core")
mineunit("player")
mineunit("server")

fixture("nodes")
fixture("tools")
fixture("items")

local function initialize_inventory(player)
	local inv = player:get_inventory()
	inv:set_list("main", {
		ItemStack("smartshop:currency_1 99"),
		ItemStack("smartshop:currency_5 99"),
		ItemStack("smartshop:currency_10 99"),
		ItemStack("smartshop:currency_50 99"),
		ItemStack("smartshop:test_node 99"),
		ItemStack("smartshop:test_tool"),
		ItemStack("smartshop:test_tool 1 1000"),
		ItemStack("smartshop:test_tool 1 1000 \"\\u0001foo\\u00022\\u0003\""),
	})
end

describe("Can players configure shops correctly?", function()

	-- Load current mod executing init.lua
	sourcefile("init")

	-- Execute on mods loaded callbacks to finish loading.
	mineunit:mods_loaded()

	local Admin = Player("Admin", {
		creative = true,
		protection_bypass = true,
		smartshop_admin = true,
		interact = true,
	})
	local Sam = Player("Sam", {interact = true})
	local Sue = Player("Sue", {interact = true})

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

		initialize_inventory(Admin)
		initialize_inventory(Sam)
		initialize_inventory(Sue)

		minetest.item_place_node(
			ItemStack("smartshop:shop"),
			minetest.get_player_by_name("Sam"),
			{
				type="node",
				under=vector.new(0, 0, 0),
				above=vector.new(1, 0, 0),
			}
		)
		minetest.item_place_node(
			ItemStack("smartshop:storage"),
			minetest.get_player_by_name("Sam"),
			{
				type="node",
				under=vector.new(1, 0, 0),
				above=vector.new(2, 0, 0),
			}
		)
		minetest.item_place_node(
			ItemStack("smartshop:storage"),
			minetest.get_player_by_name("Sam"),
			{
				type="node",
				under=vector.new(2, 0, 0),
				above=vector.new(3, 0, 0),
			}
		)

		minetest.item_place_node(
			ItemStack("smartshop:shop"),
			minetest.get_player_by_name("Admin"),
			{
				type="node",
				under=vector.new(0, 0, 0),
				above=vector.new(0, 0, 1),
			}
		)
		minetest.item_place_node(
			ItemStack("smartshop:storage"),
			minetest.get_player_by_name("Admin"),
			{
				type="node",
				under=vector.new(0, 0, 1),
				above=vector.new(0, 0, 2),
			}
		)
	end)

	after_each(function()
		world.clear()
	end)

	it("player sets up an item for sale", function()
		-- i'd rather do this through formspec stuff, but the necessary callbacks aren't in mineunit currently

		local shop_pos = {x=1, y=0, z=0}
		local shop = smartshop.api.get_object()
		local sam_inv = smartshop.player_inv_class(Sam)
		local price_item = sam_inv:remove_item("smartshop:currency_10")
		local sale_item = sam_inv:remove_item("smartshop:test_node")
		-- i can't even trigger moving something from one inventory to another O_O
	end)
end)
