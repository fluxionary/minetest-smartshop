local string_to_pos = minetest.string_to_pos

--------------------

function smartshop.api.on_player_receive_fields(player, formname, fields)
	local spos = formname:match("smartshop:(.+)")
	local pos = spos and string_to_pos(spos)
	local obj = smartshop.api.get_object(pos)
	if obj then
		obj:receive_fields(player, fields)
		return true
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	return smartshop.api.on_player_receive_fields(player, formname, fields)
end)

--------------------
