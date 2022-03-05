local F = minetest.formspec_escape
local parse_json = minetest.parse_json
local pos_to_string = minetest.pos_to_string
local write_json = minetest.write_json

local S = smartshop.S
local formspec_pos = smartshop.util.formspec_pos
local player_is_admin = smartshop.util.player_is_admin
local string_to_pos = smartshop.util.string_to_pos
local table_is_empty = smartshop.util.table_is_empty

local api = smartshop.api

--------------------

local node_class = smartshop.node_class
local shop_class = node_class:new()
smartshop.shop_class = shop_class

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
	self:set_strict_meta(true)
end

function shop_class:initialize_inventory()
	node_class.initialize_inventory(self)

	local inv = self.inv
	inv:set_size("main", 32)
	for i = 1, 4 do
		inv:set_size(("give%i"):format(i), 1)
		inv:set_size(("pay%i"):format(i), 1)
	end
end

--------------------

function shop_class:set_admin(value)
	self.meta:set_int("creative", value and 1 or 0)
	self.meta:mark_as_private("creative")
end

function shop_class:is_admin()
	return self.meta:get_int("creative") == 1
end

function shop_class:set_unlimited(value)
	self.meta:set_int("unlimited", value and 1 or 0)
	self.meta:mark_as_private("unlimited")
end

function shop_class:toggle_unlimited()
	local owner_is_admin = player_is_admin(self:get_owner())
	if self:is_unlimited() or not owner_is_admin then
		self:set_unlimited(false)
	else
		self:set_unlimited(true)
		self:set_send_pos()
		self:set_refill_pos()
	end
end

function shop_class:is_unlimited()
	return self.meta:get_int("unlimited") == 1
end

function shop_class:set_send_pos(send_pos)
	local pos_as_string = send_pos and pos_to_string(send_pos) or ""
	self.meta:set_string("item_send", pos_as_string)
	self.meta:mark_as_private("item_send")
end

function shop_class:get_send_pos()
	local string_as_pos = self.meta:get_string("item_send")
	return string_to_pos(string_as_pos)
end

function shop_class:get_send()
	local send_pos = self:get_send_pos()
	if send_pos then
		local send = api.get_object(send_pos)
		if not send or not send:is_owner(self:get_owner()) then
			self:set_send_pos()
		end
		return send
	end
end

function shop_class:get_send_inv()
	local send = self:get_send()
	if send then
		return send.inv
	end
end

function shop_class:set_refill_pos(refill_pos)
	local pos_as_string = refill_pos and pos_to_string(refill_pos) or ""
	self.meta:set_string("item_refill", pos_as_string)
	self.meta:mark_as_private("item_refill")
end

function shop_class:get_refill_pos()
	local string_as_pos = self.meta:get_string("item_refill")
	return string_to_pos(string_as_pos)
end

function shop_class:get_refill()
	local refill_pos = self:get_refill_pos()
	if refill_pos then
		local refill = api.get_object(refill_pos)
		if not refill or not refill:is_owner(self:get_owner()) then
			self:set_refill_pos()
		end
		return refill
	end
end

function shop_class:get_refill_inv()
	local refill = self:get_refill()
	if refill then
		return refill.inv
	end
end

function shop_class:set_upgraded()
	self.meta:set_string("upgraded", "true")
	self.meta:mark_as_private("upgraded")
end

function shop_class:has_upgraded()
	return self.meta:get("upgraded")
end

function shop_class:set_refund(refund)
	if table_is_empty(refund) then
		self.meta:set_string("refund", "")
	else
		self.meta:set_string("refund", write_json(refund))
	end
	self.meta:mark_as_private("refund")
end

function shop_class:get_refund()
	local refund = self.meta:get("refund")
	return refund and parse_json(refund) or {}
end

function shop_class:has_refund()
	return self.meta:get("refund")
end

function shop_class:set_state(value)
	self.meta:set_int("state", value)
	self.meta:mark_as_private("state")
end

function shop_class:set_strict_meta(value)
	self.meta:set_int("strict_meta", value and 1 or 0)
	self.meta:mark_as_private("strict_meta")
end

function shop_class:is_strict_meta()
	return self.meta:get_int("strict_meta") == 1
end

--------------------

function shop_class:get_pay_stack(n)
	local inv = self.inv
	local listname = ("pay%i"):format(n)
	return inv:get_stack(listname, 1)
end

function shop_class:get_give_stack(n)
	local inv = self.inv
	local listname = ("give%i"):format(n)
	return inv:get_stack(listname, 1)
end

--------------------

function shop_class:link_storage(storage, storage_type)
	if storage_type == "send" then
		self:set_send_pos(storage.pos)
	elseif storage_type == "refill" then
		self:set_refill_pos(storage.pos)
	end

	self:update_appearance()
end

--------------------

function shop_class:room_for_item(stack)
	if self:is_unlimited() then
		return true
	end

	if node_class.room_for_item(self, stack) then
		return true
	end

	local send = self:get_send()
	return send and send:room_for_item("main", stack)
end

function shop_class:add_item(stack)
	if self:is_unlimited() then
		return ItemStack()
	end

	local send = self:get_send()
	if send and send:room_for_item(stack) then
		return send:add_item(stack)
	end

	return node_class.add_item(self, stack)
end

function shop_class:contains_item(stack)
	if self:is_unlimited() then
		return true
	end

	local match_meta = self:is_strict_meta()

	if node_class.contains_item(self, stack, match_meta) then
		return true
	end

	local refill = self:get_refill()
	return refill and refill:contains_item(stack, match_meta)
end

function shop_class:remove_item(stack)
	if self:is_unlimited() then
		return stack
	end

	local strict_meta = self:is_strict_meta()
	local refill = self:get_refill()

	if refill and refill:contains_item(stack, strict_meta) then
		return refill:remove_item("main", stack, strict_meta)
	end

	return node_class.remove_item(self, stack, strict_meta)

end

--------------------

function shop_class:on_destruct()
	self:clear_entities()
end

--------------------

function shop_class:on_rightclick(node, player, itemstack, pointed_thing)
	if self:is_owner(player) and self:is_admin() and not player_is_admin(player) then
		-- if a shop is admin, but the player no longer has admin privs, revert the shop
		self:set_admin(false)
		self:set_unlimited((false))
	end

	node_class.on_rightclick(self, node, player, itemstack, pointed_thing)
end

function shop_class:show_formspec(player, force_client_view)
	local formspec
	if self:is_owner(player) and not force_client_view then
		formspec = self:build_owner_formspec(player)
	else
		formspec = self:build_client_formspec()
	end

	local player_name = player:get_player_name()
	local formname = ("smartshop:%s"):format(self:get_pos_as_string())

	minetest.show_formspec(player_name, formname, formspec)
end

function shop_class:build_client_formspec()
	local fpos = formspec_pos(self.pos)
	local inv = self.inv
	local pay1 = inv:get_stack("pay1", 1)
	local pay2 = inv:get_stack("pay2", 1)
	local pay3 = inv:get_stack("pay3", 1)
	local pay4 = inv:get_stack("pay4", 1)

	local fs_parts = {
		"size[8,6]",
		"list[current_player;main;0,2.2;8,4;]",
		("label[0,0.2;%s]"):format(S("On Sale:")),
		("label[0,1.2;]"):format(S("Price:")),
		("list[nodemeta:%s;give1;2,0;1,1;]"):format(fpos),
		-- TODO why `\n\n\b\b\b\b\b`
		("item_image_button[2,1;1,1;%s;buy1;\n\n\b\b\b\b\b%i]"):format(pay1:get_name(), pay1:get_count()),
		("list[nodemeta:%s;give2;3,0;1,1;]"):format(fpos),
		("item_image_button[3,1;1,1;%s;buy2;\n\n\b\b\b\b\b%i]"):format(pay2:get_name(), pay2:get_count()),
		("list[nodemeta:%s;give3;4,0;1,1;]"):format(fpos),
		("item_image_button[4,1;1,1;%s;buy3;\n\n\b\b\b\b\b%i]"):format(pay3:get_name(), pay3:get_count()),
		("list[nodemeta:%s;give4;5,0;1,1;]"):format(fpos),
		("item_image_button[5,1;1,1;%s;buy4;\n\n\b\b\b\b\b%i]"):format(pay4:get_name(), pay4:get_count()),
	}

	return table.concat(fs_parts, "")
end

function shop_class:build_owner_formspec()
	local fpos = formspec_pos(self.pos)
	local send = self:get_send()
	local refill = self:get_refill()

	local is_unlimited = self:is_unlimited()
	local owner = self:get_owner()

	local fs_parts = {
		"size[8,10]",
		("button_exit[6,0;1.5,1;customer;%s]"):format(S("Customer")),
		("label[0,0.2;%s]"):format(S("On Sale:")),
		("label[0,1.2;]"):format(S("Price:")),
		("list[nodemeta:%s;give1;1,0;1,1;]"):format(fpos),
		("list[nodemeta:%s;pay1;1,1;1,1;]"):format(fpos),
		("list[nodemeta:%s;give2;2,0;1,1;]"):format(fpos),
		("list[nodemeta:%s;pay2;2,1;1,1;]"):format(fpos),
		("list[nodemeta:%s;give3;3,0;1,1;]"):format(fpos),
		("list[nodemeta:%s;pay3;3,1;1,1;]"):format(fpos),
		("list[nodemeta:%s;give4;4,0;1,1;]"):format(fpos),
		("list[nodemeta:%s;pay4;4,1;1,1;]"):format(fpos),
		("list[nodemeta:%s;main;0,2;8,4;]"):format(fpos),
		"list[current_player;main;0,6.2;8,4;]",
		("listring[nodemeta:%s;main]"):format(fpos),
		"listring[current_player;main]"
	}

	if is_unlimited then
		table.insert(fs_parts, ("label[0.5,-0.4;%s]"):format(S("Your stock is unlimited")))
	end
	if player_is_admin(owner) then
		table.insert(fs_parts, ("button[6,1;2.2,1;toggle_unlimited;%s]"):format(S("Toggle limit")))
	end

	if not is_unlimited then
		table.insert(fs_parts, ("button_exit[5,0;1,1;tsend;%s]"):format(S("Send")))
		table.insert(fs_parts, ("button_exit[5,1;1,1;trefill;%s]"):format(S("Refill")))

		if send then
			local title = F(send:get_title())
			table.insert(fs_parts, ("tooltip[tsend;%s]"):format(S("Payments sent to @1", title)))
		else
			table.insert(fs_parts, ("tooltip[tsend;%s]"):format(S("Click to set send storage")))
		end

		if refill then
			local title = F(refill:get_title())
			table.insert(fs_parts, ("tooltip[trefill;%s]"):format(S("Automatically refilled from @1", title)))
		else
			table.insert(fs_parts, ("tooltip[trefill;%s]"):format(S("Click to set refill storage")))
		end
	end

	return table.concat(fs_parts, "")
end

local function get_buy_n(pressed)
    for n = 1, 4 do
        if pressed["buy" .. n] then return n end
    end
end

function shop_class:receive_fields(player, fields)
    if fields.tsend then
        api.start_storage_linking(player, self, "send")

    elseif fields.trefill then
        api.start_storage_linking(player, self, "refill")

    elseif fields.customer then
        self:show_formspec(player, true)

    elseif fields.toggle_unlimited then
	    self:toggle_unlimited(player)
        self:show_formspec(player)

    elseif not fields.quit then
        local n = get_buy_n(fields)
        if n then
            api.try_purchase(player, self, n)
        end
    end

    self:update_appearance()
end

--------------------

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
		local inv = self.inv

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
		local inv = self.inv
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
		local inv = self.inv
		local stack = inv:get_stack(from_list, from_index)
		if self:allow_metadata_inventory_put(to_list, to_index, stack, player) == 0 then
			return 0
		else
			return count
		end

	elseif to_list == "main" then
		local inv = self.inv
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
