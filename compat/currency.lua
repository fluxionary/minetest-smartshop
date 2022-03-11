
local check_shop_add = smartshop.util.check_shop_add_remainder
local check_shop_removed = smartshop.util.check_shop_remove_remainder
local check_player_add = smartshop.util.check_player_add_remainder
local check_player_removed = smartshop.util.check_player_remove_remainder
local get_stack_key = smartshop.util.get_stack_key

smartshop.currency = {}
local currency = smartshop.currency

local known_currency = {
    -- standard currency
    ["currency:minegeld_cent_5"]=5,
    ["currency:minegeld_cent_10"]=10,
    ["currency:minegeld_cent_25"]=25,
    ["currency:minegeld"]=100,
    ["currency:minegeld_2"]=200,
    ["currency:minegeld_5"]=500,
    ["currency:minegeld_10"]=1000,
    ["currency:minegeld_20"]=2000,
    ["currency:minegeld_50"]=5000,
    ["currency:minegeld_100"]=10000,

    -- tunneler's abyss
    ["currency:cent_1"]=1,
    ["currency:cent_2"]=2,
    ["currency:cent_5"]=5,
    ["currency:cent_10"]=10,
    ["currency:cent_20"]=20,
    ["currency:cent_50"]=50,
    ["currency:buck_1"]=100,
    ["currency:buck_2"]=200,
    ["currency:buck_5"]=500,
    ["currency:buck_10"]=1000,
    ["currency:buck_20"]=2000,
    ["currency:buck_50"]=5000,
    ["currency:buck_100"]=10000,
    ["currency:buck_200"]=20000,
    ["currency:buck_500"]=50000,
    ["currency:buck_1000"]=100000,
}

currency.available_currency = {}
for name, amount in pairs(known_currency) do
    if minetest.registered_items[name] then
        currency.available_currency[name] = amount
        smartshop.log("action", "available currency: %s=%q", name, tostring(amount))
    end
end

local function sum_stack(stack)
    local name = stack:get_name()
    local count = stack:get_count()
    local amount = currency.available_currency[name] or 0
    return amount * count
end

local function sum_inv(inv, kind)
	local total = 0

	for item, value in pairs(currency.available_currency) do
		local count = inv:get_count(item, kind)
		total = total + (count * value)
	end

    return total
end

local function is_currency(stack)
	local name
	if type(stack) == "string" then
		name = stack
	else
		name = stack:get_name()
	end
    return smartshop.available_currency[name]
end

local function sort_increasing(a, b)
    return smartshop.available_currency[a[1]] < smartshop.available_currency[b[1]]
end

local function sort_decreasing(a, b)
    return smartshop.available_currency[b[1]] < smartshop.available_currency[a[1]]
end

function currency.room_for_item(inv, stack, kind)
	return inv:room_for_item(stack)
end

function currency.add_item(inv, stack, kind)
	return inv:add_item(stack)
end

function currency.contains_item(inv, stack, kind)
	--local stack_amount = sum_stack(stack)
	--local inv_amount = sum_inv(inv, kind)
	--return inv_amount >= stack_amount
	-- TODO whoops forgot to account for change
	error("whoops forgot to account for change")
end

function currency.remove_item(inv, stack, kind)
	-- do the simple thing if possible
	if inv:contains_item(stack) then
		return inv:remove_item(stack)
	end
	-- here be dragons
	local owed_amount = sum_stack(stack)
	local paid_amount = 0

	local key_stack = ItemStack(get_stack_key(stack, true))
	if inv:contains_item(key_stack) then
		local removed = inv:remove_item(stack)
		local removed_amount = sum_stack(removed)
		paid_amount = paid_amount + removed_amount
		owed_amount = owed_amount - removed_amount
	end

	local all_counts = inv:get_all_counts(kind)
	local currency_counts = {}
	for item, count in pairs(all_counts) do
		if is_currency(item) then
			table.insert(currency_counts, {item, count})
		end
	end
	table.sort(currency_counts, sort_decreasing)

	error("not finished")
	return ItemStack(stack)
end


api.register_purchase_mechanic({
	name = "smartshop:currency",
	allow_purchase = function(player, shop, i)
		local player_inv = api.get_player_inv(player)

		local pay_stack = shop:get_pay_stack(i)
		local give_stack = shop:get_give_stack(i)

		local shop_contains_item
		local shop_room_for_item
		local player_contains_item
		local player_room_for_item

		if is_currency(pay_stack) then
			shop_room_for_item = currency.room_for_item(shop, pay_stack, "pay")
			player_contains_item = currency.contains_item(player_inv, pay_stack, "pay")
		else
			shop_room_for_item = shop:room_for_item(pay_stack)
			player_contains_item = player_inv:contains_item(pay_stack)
		end

		if is_currency(give_stack) then
			shop_contains_item = currency.contains_item(shop, give_stack, "give")
			player_room_for_item = currency.room_for_item(player_inv, give_stack, "give")
		else
			shop_contains_item = shop:contains_item(give_stack)
			player_room_for_item = player_inv:room_for_item(give_stack)
		end

		return (
			shop_contains_item and
			shop_room_for_item and
			player_contains_item and
			player_room_for_item
		)
	end,
	do_purchase = function(player, shop, i)
		local player_inv = api.get_player_inv(player)

		local pay_stack = shop:get_pay_stack(i)
		local give_stack = shop:get_give_stack(i)

		local shop_removed
		local shop_remaining
		local player_removed
		local player_remaining

		if is_currency(pay_stack) then
			player_removed = currency.remove_item(player_inv, pay_stack, "pay")
			shop_remaining = currency.add_item(shop, pay_stack, "pay")
		else
			player_removed = player_inv:remove_item(pay_stack)
			shop_remaining = shop:add_item(pay_stack)
		end

		if is_currency(give_stack) then
			shop_removed = currency.remove_item(shop, give_stack, "give")
			player_remaining = currency.add_item(player_inv, give_stack, "give")
		else
			shop_removed = shop:remove_item(give_stack)
			player_remaining = player_inv:add_item(give_stack)
		end

		check_shop_removed(shop, shop_removed, give_stack)
		check_player_removed(player_inv, shop, player_removed, pay_stack)
		check_player_add(player_inv, shop, player_remaining)
		check_shop_add(shop, shop_remaining)
	end,
})
