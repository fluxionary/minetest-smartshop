if smartshop.has.default then
	minetest.register_craft({
		output = "smartshop:shop",
		recipe = {
			{ "default:chest_locked",   "default:chest_locked", "default:chest_locked" },
			{ "default:sign_wall_wood", "default:chest_locked", "default:sign_wall_wood" },
			{ "default:sign_wall_wood", "default:torch",        "default:sign_wall_wood" },
		}
	})

	minetest.register_craft({
		output = "smartshop:storage",
		recipe = {
			{ "default:mese_crystal_fragment", "default:chest_locked", "default:mese_crystal_fragment" },
			{ "default:mese_crystal_fragment", "default:chest_locked", "default:mese_crystal_fragment" },
			{ "default:steel_ingot",           "default:copper_ingot", "default:steel_ingot" },
		}
	})
end
