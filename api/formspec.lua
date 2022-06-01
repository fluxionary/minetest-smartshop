
local F = minetest.formspec_escape
local string_to_pos = minetest.string_to_pos

local S = smartshop.S
local api = smartshop.api

local function FS(text, ...)
	return F(S(text, ...))
end

local formspec_pos = smartshop.util.formspec_pos
local player_is_admin = smartshop.util.player_is_admin

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
		("button[6,0;1.5,1;customer;%s]"):format(FS("Customer")),
		("label[0,0.2;%s]"):format(FS("On Sale:")),
		("label[0,1.2;%s]"):format(FS("Price:")),
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
		table.insert(fs_parts, ("label[0.5,-0.4;%s]"):format(FS("Your stock is unlimited")))
	end
	if player_is_admin(owner) then
		table.insert(fs_parts, ("button[6,1;2.2,1;toggle_unlimited;%s]"):format(FS("Toggle limit")))
	end

	if not is_unlimited then
		table.insert(fs_parts, ("button_exit[5,0;1,1;tsend;%s]"):format(FS("Send")))
		table.insert(fs_parts, ("button_exit[5,1;1,1;trefill;%s]"):format(FS("Refill")))

		if send then
			local title = F(send:get_title())
			table.insert(fs_parts, ("tooltip[tsend;%s]"):format(FS("Payments sent to @1", title)))
		else
			table.insert(fs_parts, ("tooltip[tsend;%s]"):format(FS("Click to set send storage")))
		end

		if refill then
			local title = F(refill:get_title())
			table.insert(fs_parts, ("tooltip[trefill;%s]"):format(FS("Automatically refilled from @1", title)))
		else
			table.insert(fs_parts, ("tooltip[trefill;%s]"):format(FS("Click to set refill storage")))
		end
	end

	return table.concat(fs_parts, "")
end

function api.build_client_formspec(shop)
	local fpos = formspec_pos(shop.pos)

	local fs_parts = {
		"formspec_version[3]",
		"size[10.5,8]",
		"style_type[image_button;bgcolor=#00000000;bgimg=blank.png;border=false]",
		"list[current_player;main;0.375,3.125;8,4;]",
		("label[0.375,0.625;%s]"):format(FS("On Sale:")),
		("label[0.375,1.875;%s]"):format(FS("Price:")),
	}

	local function give_i(i)
		if shop:can_exchange(i) then
			local give = shop:get_give_stack(i)
			return table.concat({
				("list[nodemeta:%s;give%i;%f,0.375;1,1;]"):format(fpos, i, (i + 1) * (5 / 4) + (3 / 8)),
				("image_button[%f,0.375;1,1;blank.png;buy%ia;]"):format((i + 1) * (5 / 4) + (3 / 8), i),
				("tooltip[buy%ia;%s]"):format(i, F(give:to_string()))
			}, "")
		else
			return ""
		end
	end

	local function buy_i(i)
		if shop:can_exchange(i) then
			local pay = shop:get_pay_stack(i)
			return table.concat({
				("list[nodemeta:%s;pay%i;%f,1.625;1,1;]"):format(fpos, i, (i + 1) * (5 / 4) + (3 / 8)),
				("image_button[%f,1.625;1,1;blank.png;buy%ib;]"):format((i + 1) * (5 / 4) + (3 / 8), i),
				("tooltip[buy%ib;%s]"):format(i, F(pay:to_string()))
			}, "")
		else
			return ""
		end
	end

	for i = 1, 4 do
		table.insert(fs_parts, give_i(i))
		table.insert(fs_parts, buy_i(i))
	end

	return table.concat(fs_parts, "")
end

function api.build_storage_formspec(storage)
	local fpos = formspec_pos(storage.pos)

	local fs_parts = {
		"size[12,9]",
		("field[0.3,5.3;2,1;title;;%s]"):format(F(storage:get_title())),
		"field_close_on_enter[title;false]",
		("tooltip[title;%s]"):format(FS("Used with connected smartshops")),
		("button_exit[0,6;2,1;save;%s]"):format(FS("Save")),
		("list[nodemeta:%s;main;0,0;12,5;]"):format(fpos),
		"list[current_player;main;2,5;8,4;]",
		("listring[nodemeta:%s;main]"):format(fpos),
		"listring[current_player;main]",
	}

	return table.concat(fs_parts, "")
end

