-- this will allow us to more easily extend behavior e.g. interacting directly w/ inventory bags

local class = smartshop.util.class
local get_stack_key = smartshop.util.get_stack_key
local remove_stack_with_meta = smartshop.util.remove_stack_with_meta

--------------------


local player_inv_class = class()
smartshop.player_inv_class = player_inv_class

--------------------

function player_inv_class:__new(player)
	self.player = player
	self.name = player:get_player_name()
	self.inv = player:get_inventory()
end

function smartshop.api.get_player_inv(player)
	return player_inv_class:new(player)
end

--------------------

function player_inv_class:room_for_item(stack)
	return self.inv:room_for_item("main", stack)
end

function player_inv_class:add_item(stack)
	return self.inv:add_item("main", stack)
end

function player_inv_class:contains_item(stack)
	return self.inv:contains_item("main", stack, true)
end

function player_inv_class:remove_item(stack)
	return remove_stack_with_meta(self.inv, "main", stack)
end

function player_inv_class:get_count(stack, kind)
	if type(stack) == "string" then
		stack = ItemStack(stack)
	end
	if stack:is_empty() then
		return 0
	end
	local inv = self.inv
	local total = 0

	local key = get_stack_key(stack, true)
	for _, inv_stack in inv:get_list("main") do
		if key == get_stack_key(inv_stack, true) then
			total = total + inv_stack:get_count()
		end
	end

	return math.floor(total / stack:get_count())
end

function player_inv_class:get_all_counts()
	local inv = self.inv
	local all_counts = {}

	for _, stack in inv:get_list("main") do
		local key = get_stack_key(stack)
		local count = all_counts[key] or 0
		count = count + stack:get_count()
		all_counts[key] = count
	end

	return all_counts()
end

