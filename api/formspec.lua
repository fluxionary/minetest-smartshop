
local F = minetest.formspec_escape
local string_to_pos = minetest.string_to_pos

local S = smartshop.S
local api = smartshop.api

local formspec_pos = smartshop.util.formspec_pos

--------------------

local mesein_descriptions = {
	S("Don't send"),
	S("Incoming"),
	S("Outgoing"),
	S("Both"),
}

--------------------

function api.on_player_receive_fields(player, formname, fields)
	local spos = formname:match("^smartshop:(.+)$")
	local pos = spos and string_to_pos(spos)
	local obj = api.get_object(pos)
	if obj then
		obj:receive_fields(player, fields)
		return true
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	return api.on_player_receive_fields(player, formname, fields)
end)

function api.build_owner_formspec(shop)
	local fpos = formspec_pos(shop.pos)
	local send = shop:get_send()
	local refill = shop:get_refill()

	local is_unlimited = shop:is_unlimited()
	local owner = shop:get_owner()

	local fs_parts = {
		"size[8,10]",
		("button[6,0;1.5,1;customer;%s]"):format(S("Customer")),
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

function api.build_client_formspec(shop)
	local fpos = formspec_pos(shop.pos)
	local inv = shop.inv
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

function api.build_storage_formspec(storage)
	local fpos = formspec_pos(storage.pos)
	local title = F(storage:get_title())

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
		local mesein = storage:get_mesein()
		local description = mesein_descriptions[mesein + 1]
		table.insert(fs_parts, ("button[0,7;2,1;mesesin;%s]"):format(description))
		table.insert(fs_parts, ("tooltip[mesesin;%s]"):format(S("When to send a mesecons signal")))
	end

	return table.concat(fs_parts, "")
end

