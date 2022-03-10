-- this will allow us to more easily extend behavior e.g. interacting directly w/ inventory bags

local class = smartshop.util.class
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

