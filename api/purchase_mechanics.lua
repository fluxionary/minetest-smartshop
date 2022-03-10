local S = smartshop.S

local api = smartshop.api

local check_shop_add = smartshop.util.check_shop_add_remainder
local check_shop_removed = smartshop.util.check_shop_remove_remainder
local check_player_add = smartshop.util.check_player_add_remainder
local check_player_removed = smartshop.util.check_player_remove_remainder

api.registered_purchase_mechanics = {}

--[[
	TODO: mechanic definition isn't set in stone currently, see below
	      for an example
]]
function api.register_purchase_mechanic(def)
	table.insert(api.registered_purchase_mechanics, def)
end

function api.try_purchase(player, shop, i)
	local player_inv = api.get_player_inv(player)

	for _, def in ipairs(api.registered_purchase_mechanics) do
		if def.allow_purchase(player_inv, shop, i) then
			def.do_purchase(player_inv, shop, i)
			return true
		end
	end

	local reason = api.get_purchase_fail_reason(player_inv, shop, i)
	smartshop.chat_send_player(player, ("Cannot exchange: %s"):format(reason))

	return false
end

function api.get_purchase_fail_reason(player_inv, shop, i)
	local pay_stack = shop:get_pay_stack(i)
	local give_stack = shop:get_give_stack(i)

	if not player_inv:contains_item(pay_stack) then
		return "You lack appropriate payment"
	elseif not shop:contains_item(give_stack) then
		return "Shop is sold out"
	elseif not player_inv:room_for_item(give_stack) then
		return "No room in your inventory"
	elseif not shop:room_for_item(pay_stack) then
		return "Shop is full"
	end

	return "Failed for unknown reason"
end

api.register_purchase_mechanic({
	name = "smartshop:basic_purchase",
	allow_purchase = function(player_inv, shop, i)
		local pay_stack = shop:get_pay_stack(i)
		local give_stack = shop:get_give_stack(i)

		return (
			shop:contains_item(give_stack) and
			shop:room_for_item(pay_stack) and
			player_inv:contains_item(pay_stack) and
			player_inv:room_for_item(give_stack)
		)
	end,
	do_purchase = function(player_inv, shop, i)
		local pay_stack = shop:get_pay_stack(i)
		local give_stack = shop:get_give_stack(i)

		local shop_removed = shop:remove_item(give_stack)
		local player_removed = player_inv:remove_item(pay_stack)
		local player_remaining = player_inv:add_item(give_stack)
		local shop_remaining = shop:add_item(pay_stack)

		check_shop_removed(shop, shop_removed, give_stack)
		check_player_removed(player_inv, shop, player_removed, pay_stack)
		check_player_add(player_inv, shop, player_remaining)
		check_shop_add(shop, shop_remaining)
	end
})

