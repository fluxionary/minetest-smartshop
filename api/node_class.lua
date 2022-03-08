local check_player_privs = minetest.check_player_privs
local get_meta = minetest.get_meta
local pos_to_string = minetest.pos_to_string

local class = smartshop.util.class
local get_formspec_pos = smartshop.util.get_formspec_pos

--------------------

local node_class = class()
smartshop.node_class = node_class

--------------------

function node_class:__new(pos)
	self.pos = pos
	self.meta = get_meta(pos)
	self.inv = self.meta:get_inventory()
end

function node_class:get_pos()
	return self.pos
end

function node_class:get_meta()
	return self.meta
end

function node_class:get_inv()
	return self.inv
end

function node_class:get_pos_as_string()
	return pos_to_string(self.pos)
end

function node_class:get_formspec_pos()
	return get_formspec_pos(self.pos)
end

--------------------

function node_class:set_owner(owner)
	self.meta:set_string("owner", owner)
	self.meta:mark_as_private("owner")
end

function node_class:get_owner()
	return self.meta:get_string("owner")
end

function node_class:is_owner(player)
	if type(player) == "userdata" then
		return player:get_player_name() == self:get_owner()
	else
		return player == self:get_owner()
	end
end

function node_class:set_infotext(infotext)
	self.meta:set_string("infotext", infotext)
end

function node_class:get_infotext()
	return self.meta:get_string("infotext")
end

--------------------

function node_class:get_count(stack, match_meta)
	if stack:is_empty() then
		return 0
	end
	local inv = self.inv
	local total = 0
	if match_meta then
		local singleton = ItemStack(stack)
		singleton:set_count(1)
		local singleton_string = singleton:to_string()
		for i = 1, inv:get_size("main") do
			local si = inv:get_stack("main", i)
			local count = si:get_count()
			si:set_count(1)
			if singleton_string == si:to_string() then
				total = total + count
			end
		end
	else
		local stack_name = stack:get_name()
		for i = 1, inv:get_size("main") do
			local si = inv:get_stack("main", i)
			if stack_name == si:get_name() then
				total = total + si:get_count()
			end
		end
	end
	return math.floor(total / stack:get_count())
end

function node_class:room_for_item(stack)
	return self.inv:room_for_item("main", stack)
end

function node_class:add_item(stack)
	return self.inv:add_item("main", stack)
end

function node_class:contains_item(stack, match_meta)
	return self.inv:contains_item("main", stack, match_meta)
end

function node_class:remove_item(stack, match_meta)
	local inv = self.inv

	local remainder
	if match_meta then
		local stack_string = stack:to_string()

		local index
		for i, inv_stack in ipairs(inv:get_list("main")) do
			if inv_stack:to_string() == stack_string then
				index = i
				break
			end
		end

		if index then
			remainder = ItemStack()
			inv:set_stack("main", index, remainder)
		else
			remainder = stack
		end

	else
		remainder = inv:remove_item("main", stack)
	end

	return remainder
end

--------------------

function node_class:initialize_metadata(owner)
	local player_name = owner:get_player_name()
	self:set_owner(player_name)
end

function node_class:initialize_inventory()
	-- noop
end

--------------------

function node_class:on_destruct()
	-- noop
end

--------------------

function node_class:on_rightclick(node, player, itemstack, pointed_thing)
	self:show_formspec(player)
end

function node_class:show_formspec(player)
	-- noop
end

function node_class:receive_fields(player, fields)
	-- noop
end

--------------------

function node_class:update_appearance()
	-- noop
end

--------------------

function node_class:can_access(player)
	return (
		self:is_owner(player) or
		check_player_privs(player, {protection_bypass = true})
	)
end

function node_class:can_dig(player)
	local inv = self.inv
	return inv:is_empty("main") and self:can_access(player)
end

--------------------

function node_class:allow_metadata_inventory_put(listname, index, stack, player)
	if not self:can_access(player) or stack:get_wear() ~= 0 or not stack:is_known() then
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
