-- luacheck: globals mineunit fixture world sourcefile Player

require("mineunit")
local json = require('mineunit.lib.json')

mineunit("core")
mineunit("player")
mineunit("server")

fixture("nodes")
fixture("tools")

describe("Are shops from the old fork properly upgraded?", function()

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


end)
