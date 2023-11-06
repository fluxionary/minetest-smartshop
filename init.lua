futil.check_version({ year = 2023, month = 11, day = 1 }) -- is_player

smartshop = fmod.create()

smartshop.dofile("privs")
smartshop.dofile("resources")
smartshop.dofile("util")
smartshop.dofile("api", "init")
smartshop.dofile("nodes", "init")
smartshop.dofile("entities", "init")
smartshop.dofile("compat", "init")

smartshop.dofile("crafting")
smartshop.dofile("aliases")

if smartshop.settings.enable_tests then
	smartshop.dofile("tests", "init")
end
