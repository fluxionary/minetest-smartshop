
local player_is_admin = smartshop.util.player_is_admin
local string_to_pos = smartshop.util.string_to_pos
local table_is_empty = smartshop.util.table_is_empty

--------------------

local node_class = smartshop.node_class
local shop_class = node_class:new()
smartshop.shop_class = shop_class

--------------------

function shop_class:is_admin()
    return self.meta:get_int("creative") == 1
end

function shop_class:set_admin(value)
	self.meta:set_int("creative", value and 1 or 0)
end

function shop_class:is_unlimited()
	return self.meta:get_int("unlimited") == 1
end

function shop_class:set_unlimited(value)
	self.meta:set_int("unlimited", value and 1 or 0)
end

function shop_class:get_send_pos()
	local string_as_pos = self.meta:get_string("item_send")
	return string_to_pos(string_as_pos)
end

function shop_class:set_send_pos(send_pos)
	local pos_as_string = send_pos and minetest.pos_to_string(send_pos) or ""
	self.meta:set_string("item_refill", pos_as_string)
end

function shop_class:get_refill_pos()
	local string_as_pos = self.meta:get_string("item_refill")
	return string_to_pos(string_as_pos)
end

function shop_class:set_refill_pos(refill_pos)
	local pos_as_string = refill_pos and minetest.pos_to_string(refill_pos) or ""
	self.meta:set_string("item_refill", pos_as_string)
end

function shop_class:has_upgraded()
	return self.meta:get("upgraded")
end

function shop_class:set_upgraded()
	self.meta:set_string("upgraded", "true")
end

function shop_class:get_refund()
	local refund = self.meta:get("refund")
	return refund and minetest.parse_json(refund) or {}
end

function shop_class:has_refund()
	return self.meta:get("refund")
end

function shop_class:set_refund(refund)
	if table_is_empty(refund) then
		self.meta:set_string("refund", "")
	else
		self.meta:set_string("refund", minetest.write_json(refund))
	end
end

function shop_class:set_state(value)
	self.meta:set_int("state", value)
end

--------------------

function shop_class:initialize_metadata(player)
	node_class.initialize_metadata(self, player)

	local player_name = player:get_player_name()
	local is_admin = player_is_admin(player_name)

	self:set_infotext("Shop by: %s", player_name)
	self:set_admin(is_admin)
	self:set_unlimited(is_admin)
	self:set_upgraded()
	self:set_state(0)  -- mesecons?
end

function shop_class:initialize_inventory()
	node_class.initialize_inventory(self)

	local inv = self:get_inventory()
	inv:set_size("main", 32)
	for i = 1, 4 do
		inv:set_size(("give%i"):format(i), 1)
		inv:set_size(("pay%i"):format(i), 1)
	end
end

--------------------

function shop_class:show_formspec(player)
	-- TODO
end

function shop_class:update_appearance()
	-- TODO
end

--------------------

function shop_class:allow_metadata_inventory_put(listname, index, stack, player)
	if node_class.allow_metadata_inventory_put(self, listname, index, stack, player) == 0 then
		return 0

	elseif listname == "main" then
		return stack:get_count()

	else
		-- interacting with give/pay slots
		local inv = self:get_inventory()

		local old_stack = inv:get_stack(listname, index)
		if old_stack:get_name() == stack:get_name() then
			local old_count = old_stack:get_count()
			local add_count = stack:get_count()
			local max_count = old_stack:get_stack_max()
			local new_count = math.min(old_count + add_count, max_count)
			old_stack:set_count(new_count)
			inv:set_stack(listname, index, old_stack)

		else
			inv:set_stack(listname, index, stack)
		end

		-- so we don't remove anything from the player's own stuff
		return 0
	end
end

function shop_class:allow_metadata_inventory_take(listname, index, stack, player)
	if node_class.allow_metadata_inventory_take(self, listname, index, stack, player) == 0 then
		return 0

	elseif listname == "main" then
		return stack:get_count()

	else
		local inv = self:get_inventory()
		local cur_stack = inv:get_stack(listname, index)
		local new_count = math.max(0, cur_stack:get_count() - stack:get_count())
		if new_count == 0 then
			cur_stack = ItemStack("")
		else
			cur_stack:set_count(new_count)
		end
		inv:set_stack(listname, index, cur_stack)
		return 0
	end
end

function shop_class:allow_metadata_inventory_move(from_list, from_index, to_list, to_index, count, player)
	if node_class.allow_metadata_inventory_move(self, from_list, from_index, to_list, to_index, count, player) == 0 then
		return 0

	elseif from_list == "main" and to_list == "main" then
		return count

	elseif from_list == "main" then
		local inv = self:get_inventory()
		local stack = inv:get_stack(from_list, from_index)
		if self:allow_metadata_inventory_put(to_list, to_index, stack, player) == 0 then
			return 0
		else
			return count
		end

	elseif to_list == "main" then
		local inv = self:get_inventory()
		local stack = inv:get_stack(to_list, to_index)
		if self:allow_metadata_inventory_take(from_list, from_index, stack, player) == 0 then
			return 0
		else
			return count
		end
	else
		return count
	end
end

function shop_class:on_metadata_inventory_put(listname, index, stack, player)
	if listname == "main" then
		node_class.on_metadata_inventory_put(self, listname, index, stack, player)
	end
end

function shop_class:on_metadata_inventory_take(listname, index, stack, player)
	if listname == "main" then
		node_class.on_metadata_inventory_take(self, listname, index, stack, player)
	end
end

function shop_class:can_dig(player)
	if node_class.can_dig(self, player) then
		self:clear_entities()
		return true
	end
end
