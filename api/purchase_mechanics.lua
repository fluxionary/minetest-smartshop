local S = smartshop.S

local api = smartshop.api

local check_shop_add_remainder = smartshop.util.check_shop_add_remainder
local check_shop_remove_remainder = smartshop.util.check_shop_remove_remainder
local check_player_add_remainder = smartshop.util.check_player_add_remainder
local check_player_remove_remainder = smartshop.util.check_player_remove_remainder

api.registered_purchase_mechanics = {}

--[[
	TODO: mechanic definition isn't set in stone currently, see below
	      for an example
]]
function api.register_purchase_mechanic(def)
	table.insert(api.registered_purchase_mechanics, def)
end

function api.try_purchase(player, shop, n)
	local player_inv = api.get_player_inv(player)

	for _, def in ipairs(api.registered_purchase_mechanics) do
		if def.allow_purchase(player_inv, shop, n) then
			def.do_purchase(player_inv, shop, n)
			return true
		end
	end

	local reason = api.get_purchase_fail_reason(player_inv, shop, n)
	smartshop.chat_send_player(player, reason)

	return false
end

function api.get_purchase_fail_reason(player_inv, shop, n)
	local pay_stack = shop:get_pay_stack(n)
	local give_stack = shop:get_give_stack(n)

	if not player_inv:contains_item(pay_stack, true) then
		return S("You lack sufficient payment")
	elseif not player_inv:room_for_item(give_stack) then
		return "Your inventory is full"
	elseif not shop:contains_item(give_stack, true) then
		return "Shop is sold out"
	elseif not shop:room_for_item(pay_stack) then
		return "Shop is full"
	end

	return "Transaction failed for unknown reason"
end

api.register_purchase_mechanic({
	name = "smartshop:basic_purchase",
	allow_purchase = function(player_inv, shop, n)
		local pay_stack = shop:get_pay_stack(n)
		local give_stack = shop:get_give_stack(n)

		return (
			shop:contains_item(give_stack) and
			shop:room_for_item(pay_stack) and
			player_inv:contains_item(pay_stack) and
			player_inv:room_for_item(give_stack)
		)
	end,
	do_purchase = function(player_inv, shop, n)
		local pay_stack = shop:get_pay_stack(n)
		local give_stack = shop:get_give_stack(n)

		check_shop_remove_remainder(shop, shop:remove_item(give_stack), give_stack)
		check_player_remove_remainder(player_inv, shop, player_inv:remove_item(pay_stack), pay_stack)
		check_player_add_remainder(player_inv, shop, player_inv:add_item(give_stack))
		check_shop_add_remainder(shop, shop:add_item(pay_stack))
	end
})

