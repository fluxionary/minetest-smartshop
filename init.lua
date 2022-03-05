local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

smartshop = {
	redo = true,
	version = os.time({year = 2022, month = 2, day = 28}),
	modname = modname,
	modpath = modpath,

	S = S,

	log = function(level, messagefmt, ...)
		return minetest.log(level, ("[%s] %s"):format(modname, messagefmt:format(...)))
	end,

	chat_send_player = function(player, message, ...)
		minetest.chat_send_player(player, ("[%s] %s"):format(modname, S(message, ...)))
	end,

	has = {
		currency = minetest.get_modpath("currency"),
		mesecons = minetest.get_modpath("mesecons"),
		mesecons_mvps = minetest.get_modpath("mesecons_mvps"),
		tubelib = minetest.get_modpath("tubelib"),
	},

	dofile = function(...)
		dofile(table.concat({modpath, ...}, "/") .. ".lua")
	end,
}

smartshop.dofile("settings")
smartshop.dofile("util")
smartshop.dofile("api", "init")
smartshop.dofile("nodes", "init")

smartshop.dofile("refunds")

smartshop.dofile("crafting")


--------------------------------
smartshop.dofile = nil  -- no need to export this, not sure whether it's dangerous
