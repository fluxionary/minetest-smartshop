local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

smartshop = {
	redo = true,
	version = os.time({year = 2022, month = 2, day = 28}),
	modname = modname,
	modpath = modpath,

	log = function(level, messagefmt, ...)
		return minetest.log(level, ("[%s] %s"):format(modname, messagefmt:format(...)))
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
