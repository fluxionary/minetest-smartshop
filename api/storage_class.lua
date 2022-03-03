local build_wifi_formspec = smartshop.api.build_wifi_formspec

--------------------

local node_class = smartshop.node_class
local storage_class = node_class:new()
smartshop.storage_class = storage_class

--------------------

function storage_class:get_title()
	if not self.meta:get("title") then
		self:set_title("storage@%s", self:get_pos_as_string())
	end
	return self.meta:get_string("title")
end

function storage_class:set_title(format, ...)
	return self:set_string("title", format:format(...))
end

function node_class:get_mesein()
	return self.meta:get_int("mesein")
end

function node_class:set_mesein(value)
	self.meta:set_int("mesein", value)
end

function storage_class:toggle_mesein(meta)
	local mesein = smartshop.get_mesein(meta)
	if mesein <= 2 then
		mesein = mesein + 1
	else
		mesein = 0
	end
	smartshop.set_mesein(meta, mesein)
end

--------------------

function storage_class:initialize_metadata(player)
	node_class.initialize_metadata(self, player)

	local player_name = player:get_player_name()

	self:set_mesein(0)
	self:set_infotext("External storage by: %s", player_name)
	self:set_title("storage@%s", minetest.pos_to_string(self.pos))
end

function storage_class:initialize_inventory()
	node_class.initialize_inventory(self)

	local inv = self:get_inventory()
	inv:set_size("main", 60)
end

--------------------

function storage_class:show_formspec(player)
	if not self:can_access(player) then
		return
	end

	local player_name = player:get_player_name()

	local gui = build_wifi_formspec(self)
	minetest.show_formspec(player_name, "smartshop.wifi_showform", gui)
end

--------------------

