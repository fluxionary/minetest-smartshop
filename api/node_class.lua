local get_formspec_pos = smartshop.util.get_formspec_pos
local pos_to_string = minetest.pos_to_string

--------------------

local node_class = {}
smartshop.node_class = node_class

--------------------

function node_class:new(pos)
	local object = {
		pos = pos,
		meta = minetest.get_meta(pos),
	}
	setmetatable(object, self)
	self.__index = self  -- magic for inheritance?
	return object
end

function node_class:get_pos_as_string()
	return pos_to_string(self.pos)
end

function node_class:get_formspec_pos()
	return get_formspec_pos(self.pos)
end

--------------------

function node_class:get_owner()
	return self.meta:get_string("owner")
end

function node_class:set_owner(owner)
	self.meta:set_string("owner", owner)
end

function node_class:get_infotext()
	return self.meta:get_string("infotext")
end

function node_class:set_infotext(format, ...)
	self:set_string("infotext", format:format(...))
end

function node_class:get_inventory()
	return self.meta:get_inventory()
end

--------------------

function node_class:initialize_metadata(player)
	local player_name = player:get_player_name()
	self:set_owner(player_name)
end

function node_class:initialize_inventory()
	-- noop
end

--------------------

function node_class:show_formspec(player)
	-- noop
end

function node_class:update_appearance()
	-- noop
end

function node_class:can_access(player)
	local player_name = player:get_player_name()

	return (
		self:get_owner(pos) == player_name or
		minetest.check_player_privs(player_name, {protection_bypass = true})
	)
end

function node_class:allow_metadata_inventory_put(listname, index, stack, player)
	if not self:can_access(player) then
		return 0

	elseif stack:get_wear() ~= 0 then
		return 0

	else
		return stack:get_count()
	end
end

function node_class:allow_metadata_inventory_take(listname, index, stack, player)
	if not self:can_access(player) then
		return 0

	else
		return stack:get_count()
	end
end

function node_class:allow_metadata_inventory_move(from_list, from_index, to_list, to_index, count, player)
	if not self:can_access(player) then
		return 0

	else
		return count
	end
end

function node_class:on_metadata_inventory_put(listname, index, stack, player)
	smartshop.log("action", "%s put %q in %s @ %s",
		player:get_player_name(),
		stack:to_string(),
		minetest.get_node(self.pos).name,
		minetest.pos_to_string(self.pos)
	)
end

function node_class:on_metadata_inventory_take(listname, index, stack, player)
	smartshop.log("action", "%s took %q from %s @ %s",
		player:get_player_name(),
		stack:to_string(),
		minetest.get_node(self.pos).name,
		minetest.pos_to_string(self.pos)
	)
end

function node_class:can_dig(player)
	local inv = self:get_inventory()
	local owner = self:get_owner()
	if (owner == "" or self:can_access(player)) and inv:is_empty("main") then
		return true
	end
end
