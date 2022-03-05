local F = minetest.formspec_escape

local S = smartshop.S
local formspec_pos = smartshop.util.formspec_pos

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
	self:set_string("title", format:format(...))
	self.meta:mark_as_private("title")
end

function node_class:get_mesein()
	return self.meta:get_int("mesein")
end

function node_class:set_mesein(value)
	self.meta:set_int("mesein", value)
	self.meta:mark_as_private("mesein")
end

function storage_class:toggle_mesein(meta)
	local mesein = self:get_mesein()
	if mesein == 3 then
		mesein = 0
	else
		mesein = mesein + 1
	end
	self:set_mesein(mesein)
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

	local inv = self.inv
	inv:set_size("main", 60)
end

--------------------

local mesein_descriptions = {
	S("Don't send"),
	S("Incoming"),
	S("Outgoing"),
	S("Both"),
}

function storage_class:build_formspec()
	local fpos = formspec_pos(self.pos)
	local title = F(self:get_title())

	local fs_parts = {
		"size[12,9]",
		("field[0.3,5.3;2,1;title;;%s]"):format(title),
		"field_close_on_enter[title;false]",
		("tooltip[title;%s]"):format(S("Used with connected smartshops")),
		("button_exit[0,6;2,1;save;%s]"):format(S("Save")),
		("list[nodemeta:%s;main;0,0;12,5;]"):format(fpos),
		"list[current_player;main;2,5;8,4;]",
		("listring[nodemeta:%s;main]"):format(fpos),
		"listring[current_player;main]",
	}

	if smartshop.has.mesecons then
		local mesein = self:get_mesein()
		local description = mesein_descriptions[mesein + 1]
		table.insert(fs_parts, ("button[0,7;2,1;mesesin;%s]"):format(description))
		table.insert(fs_parts, ("tooltip[mesesin;%s]"):format(S("When to send a mesecons signal")))
	end

	return table.concat(fs_parts, "")
end

function storage_class:show_formspec(player)
	if not self:can_access(player) then
		return
	end

	local player_name = player:get_player_name()
	local formspec = self:build_formspec()
	local formname = ("smartshop:%s"):format(self:get_pos_as_string())

	minetest.show_formspec(player_name, formname, formspec)
end

function storage_class:receive_fields(player, fields)
	if fields.mesesin then
		self:toggle_mesein()
		self:show_formspec(player)

	elseif fields.title then
		self:set_title(fields.title)
		self:show_formspec(player)
	end
end

--------------------

