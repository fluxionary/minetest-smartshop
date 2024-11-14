local F = minetest.formspec_escape
local S = smartshop.S
local get_stack_key = smartshop.util.get_stack_key

local function FS(text, ...)
	return F(S(text, ...))
end

--------------------

local get_shop_status = function(shop, filtered)
	local match_meta = shop:is_strict_meta()
	local offers = {}
	local keys = {}
	for i = 1, 4, 1 do
		local pay_stack = shop:get_give_stack(i);
		local give_stack = shop:get_pay_stack(i);

		offers[i] = {
			give = give_stack:to_table(),
			pay = pay_stack:to_table(),
			stock = shop:can_give_count(i) -- times customer can purchase before sold out
		}
		if smartshop.has.currency and smartshop.compat.currency.is_currency(pay_stack) then
			local mg_price = smartshop.compat.currency.get_stack_value(pay_stack)
			offers[i].pay_price = mg_price / offers[i].give.count
		end

		keys[i] = {give = get_stack_key(give_stack, match_meta), pay = get_stack_key(pay_stack, match_meta)}
	end

	local inv = shop.inv
	local mainlist = inv:get_list("main")

	local inventory = {}
	for index, stack in pairs(mainlist) do
		local key = get_stack_key(stack, match_meta)

		if filtered then
			for _, offer_item_key in pairs(keys) do
				if key == offer_item_key.give or key == offer_item_key.pay then
					inventory[index] = stack:to_table()
					break
				end
			end
		else
			inventory[index] = stack:to_table()
		end
	end
	return {
		type = "shop status",
		strict_meta = match_meta,
		freebies = shop:allow_freebies(),
		offer = offers,
		inventory = inventory
	}
end

local set_shop_status = function(shop, message)
	-- TODO: a proper api here to set give/pay stack
	local inventory = shop.inv;
	for i = 1, 4, 1 do
		local current_offer = message.offer[i]
		if type(current_offer) == 'table' and current_offer.give and current_offer.pay then
			local give_item = ItemStack(current_offer.give);
			local pay_item = ItemStack(current_offer.pay);
			if give_item:is_known() and (not give_item:is_empty()) and pay_item:get_name() and (not pay_item:is_empty()) then
				if type(current_offer.give_count) == "number" then
					give_item:set_count(math.floor(current_offer.give_count))
				end
				inventory:set_stack('give' .. i, 1, give_item)
				if type(current_offer.pay_count) == "number" then
					pay_item:set_count(math.floor(current_offer.pay_count))
				end
				inventory:set_stack('pay' .. i, 1, pay_item)
			end
		end
	end
	shop:update_appearance()
end

local rotate_rules = function(rulesin, dir)
	local rules = {}
	for k, v in ipairs(rulesin) do
		rules[k] = v
	end
	if dir.z > 0 then
		return rules
	elseif dir.z < 0 then
		for _, i in ipairs(rules) do
			i.x = -i.x
			i.z = -i.z
		end
		return rules
	elseif dir.x > 0 then
		for _, i in ipairs(rules) do
			local z = i.x
			i.x = i.z
			i.z = -z
		end
		return rules
	elseif dir.x < 0 then
		for _, i in ipairs(rules) do
			local z = i.x
			i.x = -i.z
			i.z = z
		end
		return rules
	elseif dir.y > 0 then
		for _, i in ipairs(rules) do
			local z = i.y
			i.y = i.z
			i.z = z
		end
		return rules
	elseif dir.y < 0 then
		for _, i in ipairs(rules) do
			local z = i.y
			i.y = -i.z
			i.z = -z
		end
		return rules
	else
		minetest.log("warning", string.format("rotate_rules() called with invalid direction %s,%s,%s", dir.x, dir.y, dir.z))
		return {}
	end
end

local function digilines_override(itemstring)
	minetest.override_item(itemstring, {
		digilines = {
			wire = {
				rules = function(node)
					local rules = {
						{x = 1, y = 0, z = 0},
						{x = -1, y = 0, z = 0},
						{x = 0, y = 1, z = 0},
						{x = 0, y = -1, z = 0},
						{x = 0, y = 0, z = 1}
					}
					return rotate_rules(rules, minetest.facedir_to_dir(node.param2))
				end
			},
			receptor = {},
			effector = {
				-- invoked when this node receives a message from digiline
				---@param position_of_message table
				---@param nodedef table
				---@param channel string
				---@param message {type:'get'|'set',offer:{give:string, give_count:number, pay:string, pay_count:number}[]}
				action = function(position_of_message, nodedef, channel, message)
					local shop = smartshop.api.get_object(position_of_message)
					local setchan = shop:get_channel()
					if setchan ~= channel then
						return
					end

					if type(message) == 'table' and type(message.type) == 'string' then
						if message.type == 'get' then
							local filtered = false
							if message.only_items_on_sale_or_buy then
								filtered = true
							end
							local sendmessage = get_shop_status(shop, filtered)
							digiline:receptor_send(position_of_message, digiline.rules.default, setchan, sendmessage)
						elseif message.type == 'set' and message.offer then
							set_shop_status(shop, message)
						end
					end
				end
			}
		}
	})
end

for _, variant in ipairs(smartshop.nodes.shop_node_names) do
	digilines_override(variant)
end

-- for _, variant in ipairs(smartshop.nodes.storage_node_names) do
-- 	digilines_override(variant)
-- end

--------------------

--------------------

local shop_class = smartshop.shop_class

function shop_class:set_channel(value)
	self.meta:set_string("channel", value)
end

function shop_class:get_channel()
	return self.meta:get_string("channel")
end

local old_shop_initialize_metadata = shop_class.initialize_metadata
function shop_class:initialize_metadata(player)
	old_shop_initialize_metadata(self, player)

	self:set_channel(player:get_player_name())
end

local old_shop_receive_fields = shop_class.receive_fields
function shop_class:receive_fields(player, fields)
	if fields.channel and self:is_owner(player) then
		self:set_channel(fields.channel)
		self:show_formspec(player)
	end
	old_shop_receive_fields(self, player, fields)
end

--------------------

local old_build_owner_formspec = smartshop.api.build_owner_formspec
function smartshop.api.build_owner_formspec(shop)
	local fs_parts = {old_build_owner_formspec(shop)}

	local channel = shop:get_channel()

	table.insert(fs_parts, ("label[0,2.2;%s]"):format(FS("channel:")))
	table.insert(fs_parts, ("field[2.3,2.3;3,1;channel;;%s]"):format(channel))
	table.insert(fs_parts, ("tooltip[channel;%s]"):format(S("Digiline channel of smartshop")))

	return table.concat(fs_parts, "")
end

--------------------

smartshop.api.register_on_shop_empty(function(player, shop, i)
	local pos = shop.pos
	local setchan = shop:get_channel()
	local item_name = shop:get_give_stack(i):get_name()
	digiline:receptor_send(pos, digiline.rules.default, setchan,
		{type = "out of storage", item = item_name, offer_index = i})
end)

smartshop.api.register_on_purchase(function(player, shop, i)
	local pos = shop.pos
	local setchan = shop:get_channel()
	local item_name = shop:get_give_stack(i):get_name()
	digiline:receptor_send(pos, digiline.rules.default, setchan,
		{type = "transaction complete", item = item_name, offer_index = i})
	if shop:can_give_count(i) == 0 then
		digiline:receptor_send(pos, digiline.rules.default, setchan,
			{type = "out of storage", item = item_name, offer_index = i})
	end
end)
