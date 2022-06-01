--[[
because this fork turns the "give" and "pay" lines in the shop inventory into
placeholders, and not actual inventory slots, upgrading causes the items
stored in those slots to be lost.

if enabled (by default), this LBM will refund those items, even in the event
that the shop is currently full, by waiting until there's available space.

the items can still be lost, though, if the player empties the shop and then
breaks the node, before the LBM has been run.
--]]

local function try_refund(shop)
	local owner = shop:get_owner()

	local unrefunded = {}

	for _, itemstring in ipairs(shop:get_refund()) do
		local itemstack = ItemStack(itemstring)
		if shop:room_for_item(itemstack) then
			smartshop.log("action", "refunding %s to %s's shop at %s",
				itemstring, owner, minetest.pos_to_string(shop.pos, 0)
			)
			shop:add_item(itemstack)
		else
			table.insert(unrefunded, itemstack:to_string())
		end
	end

	shop:set_refund(unrefunded)
end

local function generate_unrefunded(shop)
	local inv = shop.inv

	local unrefunded = {}

	for index = 1, 4 do
		local pay_stack = inv:get_stack("pay" .. index, 1)
		if not pay_stack:is_empty() then
			table.insert(unrefunded, pay_stack:to_string())
		end

		local give_stack = inv:get_stack("give" .. index, 1)
		if not give_stack:is_empty() then
			table.insert(unrefunded, give_stack:to_string())
		end
	end

	return unrefunded
end

function smartshop.compat.do_refund(pos)
	local shop = smartshop.api.get_object(pos)

	-- don't bother refunding admin shops
	if shop:is_admin() then
		return
	end

	if not shop:has_upgraded() then
		local unrefunded = generate_unrefunded(shop)
		shop:set_refund(unrefunded)
		shop:set_upgraded()
	end

	if shop:has_refund() then
		try_refund(shop)
	end
end

if smartshop.settings.enable_refund then
	minetest.register_lbm({
		name = "smartshop:repay_lost_stuff",
		nodenames = {
			"smartshop:shop",
			"smartshop:shop_empty",
			"smartshop:shop_full",
			"smartshop:shop_used",
		},
		run_at_every_load = true,
		action = function(pos, node)
			smartshop.compat.do_refund(pos)
		end,
	})
end
