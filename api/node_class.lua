local check_player_privs = minetest.check_player_privs
local get_meta = minetest.get_meta
local pos_to_string = minetest.pos_to_string

local api = smartshop.api

local class = smartshop.util.class
local get_formspec_pos = smartshop.util.get_formspec_pos
local get_stack_key = smartshop.util.get_stack_key
local remove_stack_with_meta = smartshop.util.remove_stack_with_meta

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

function node_class:is_shop()
	return api.is_shop(self.pos)
end

function node_class:is_storage()
	return api.is_storage(self.pos)
end

--------------------

function node_class:get_count(stack, match_meta)
	if type(stack) == "string" then
		stack = ItemStack(stack)
	end
	if stack:is_empty() then
		return 0
	end
	local inv = self.inv
	local total = 0

	local key = get_stack_key(stack, match_meta)
	for _, inv_stack in inv:get_list("main") do
		if key == get_stack_key(inv_stack, match_meta) then
			total = total + inv_stack:get_count()
		end
	end

	return math.floor(total / stack:get_count())
end

function node_class:get_all_counts(match_meta)
	local inv = self.inv
	local all_counts = {}

	for _, stack in inv:get_list("main") do
		local key = get_stack_key(stack, match_meta)
		local count = all_counts[key] or 0
		count = count + stack:get_count()
		all_counts[key] = count
	end

	return all_counts()
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

	local removed
	if match_meta then
		removed = remove_stack_with_meta(inv, "main", stack)

	else
		removed = inv:remove_item("main", stack)
	end

	return removed
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
