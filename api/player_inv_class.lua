-- this will allow us to more easily extend behavior e.g. interacting directly w/ inventory bags

local check_player_add_remainder = smartshop.util.check_player_add_remainder
local check_player_remove_remainder = smartshop.util.check_player_remove_remainder

--------------------


local player_inv_class = {}
smartshop.player_inv_class = player_inv_class

--------------------

function player_inv_class:new(player)
	local name = player:get_player_name()
	local inv = player:get_inventory()
	local object = {
		player = player,
		name = name,
		inv = inv,
	}
	setmetatable(object, self)
	self.__index = self  -- magic for inheritance?
	return object
end

function smartshop.api.get_player_inv(player)
	return player_inv_class:new(player)
end

--------------------

function player_inv_class:room_for_item(stack)
	return self.inv:room_for_item("main", stack)
end

function player_inv_class:add_item(stack)
	local remainder = self.inv:add_item("main", stack)
	check_player_add_remainder(remainder)
	return remainder
end

function player_inv_class:contains_item(stack, match_meta)
	return self.inv:contains_item("main", stack, match_meta)
end

function player_inv_class:remove_item(stack)
	local remainder =  self.inv:remove_item("main", stack)
	check_player_remove_remainder(remainder)
	return remainder
end

