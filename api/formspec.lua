local formspec_escape = minetest.formspec_escape

local formspec_pos = smartshop.util.formspec_pos

--------------------

local mesein_descriptions = {
	"Don't send",
	"Incoming",
	"Outgoing",
	"Both",
}

function smartshop.api.build_wifi_formspec(obj)
	local fpos = formspec_pos(obj.pos)
	local title = formspec_escape(obj:get_title())

	local gui_parts = {
		"size[12,9]",
		("field[0.3,5.3;2,1;title;;%s]"):format(title),
		"tooltip[title;Used with connected smartshops]",
		"button_exit[0,6;2,1;save;Save]",
		("list[nodemeta:%s;main;0,0;12,5;]"):format(fpos),
		"list[current_player;main;2,5;8,4;]",
		("listring[nodemeta:%s;main]"):format(fpos),
		"listring[current_player;main]"
	}

	if smartshop.has.mesecons then
		local mesein = obj:get_mesein()
		local description = mesein_descriptions[mesein]
		table.insert(gui_parts, ("button[0,7;2,1;mesesin;%s]"):format(description))
		table.insert(gui_parts, "tooltip[mesesin;Send mesecon signal when items from shops does:]")
	end

	return table.concat(gui_parts, "")
end

function smartshop.api.wifi_receive_fields(player, pressed)
	local player_name = player:get_player_name()
	if not pos then return end

	if pressed.mesesin then
		toggle_mesein(meta)
		smartshop.wifi_showform(pos, player)
	elseif pressed.save then
		local title = pressed.title
		if not title or title == "" then
			title = "wifi " .. minetest.pos_to_string(pos)
		end
		smartshop.set_title(meta, title)
		local spos = minetest.pos_to_string(pos)
		smartshop.log("action", "%s set title of wifi storage at %s to %s", player_name, spos, title)
		smartshop.player_pos[player_name] = nil
	elseif pressed.quit then
		smartshop.player_pos[player_name] = nil
	end
end
