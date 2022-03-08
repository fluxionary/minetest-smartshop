local error_behavior = smartshop.settings.error_behavior

smartshop.util = {}

function smartshop.util.error(messagefmt, ...)
	local message = messagefmt:format(...)

	if error_behavior == "crash" then
		error(message)

	elseif error_behavior == "announce" then
		minetest.chat_send_all(message)
	end

	smartshop.log("error", message)
end

function smartshop.util.string_to_pos(pos_as_string)
	-- can't just use minetest.string_to_pos, for sake of backward compatibility
	if not pos_as_string or type(pos_as_string) ~= "string" then
		return nil
	end
	local x, y, z = pos_as_string:match("^%s*%(?%s*(%-?%d+)[%s,]+(%-?%d+)[%s,]+(%-?%d+)%s*%)?%s*$")
	if x and y and z then
		return vector.new(tonumber(x), tonumber(y), tonumber(z))
	end
end

function smartshop.util.formspec_pos(pos)
	return ("%i,%i,%i"):format(pos.x, pos.y, pos.z)
end

function smartshop.util.player_is_admin(player_or_name)
	return minetest.check_player_privs(player_or_name, {[smartshop.settings.admin_shop_priv] = true})
end

function smartshop.util.deepcopy(orig, _memo)
	-- taken from lua documentation
	_memo = _memo or {}
	local orig_type = type(orig)
	local copy
	if orig_type == "table" then
		if _memo[orig] then
			copy = _memo[orig]
		else
			copy = {}
			for orig_key, orig_value in next, orig, nil do
				copy[smartshop.util.deepcopy(orig_key, _memo)] = smartshop.util.deepcopy(orig_value, _memo)
			end
			_memo[orig] = copy
			setmetatable(copy, smartshop.util.deepcopy(getmetatable(orig), _memo))
		end
	else
		-- number, string, boolean, etc
		copy = orig
	end
	return copy
end

function smartshop.util.table_invert(t)
	local inverted = {}
	for k, v in pairs(t) do
		inverted[v] = k
	end
	return inverted
end

function smartshop.util.table_reversed(t)
	local len = #t
	local reversed = {}
	for i = len, 1, -1 do
		reversed[len - i + 1] = t[i]
	end
	return reversed
end

function smartshop.util.table_contains(t, value)
	for _, v in ipairs(t) do
		if v == value then
			return true
		end
	end
	return false
end

function smartshop.util.table_is_empty(t)
	return not next(t)
end

function smartshop.util.pairs_by_keys(t, f)
	local a = {}
	for n in pairs(t) do
		table.insert(a, n)
	end
	table.sort(a, f)
	local i = 0
	return function()
		i = i + 1
		if a[i] == nil then
			return nil
		else
			return a[i], t[a[i]]
		end
	end
end

function smartshop.util.pairs_by_values(t, f)
	if not f then
		f = function(a, b)
			return a < b
		end
	end
	local s = {}
	for k, v in pairs(t) do
		table.insert(s, {k, v})
	end
	table.sort(s, function(a, b)
		return f(a[2], b[2])
	end)
	local i = 0
	return function()
		i = i + 1
		local v = s[i]
		if v then
			return unpack(v)
		else
			return nil
		end
	end
end

function smartshop.util.round(x)
	-- approved by kahan
	if x % 2 == 0.5 then
		return x - 0.5
	else
		return math.floor(x + 0.5)
	end
end

function smartshop.util.clone_tmp_inventory(inv_name, src_inv, src_list_name)
	-- TODO are these "default" allow functions required? :\
	local tmp_inv = minetest.create_detached_inventory(inv_name, {
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			return count
		end,
		allow_put = function(inv, listname, index, stack, player)
			return stack:get_size()
		end,
		allow_take = function(inv, listname, index, stack, player)
			return stack:get_size()
		end,
	})

	for name, _ in pairs(src_inv:get_lists()) do
		if not tmp_inv:is_empty(name) or tmp_inv:get_size(name) ~= 0 then
			smartshop.util.error("attempt to re-use existing temporary inventory %s", inv_name)
			return
		end
	end

	if src_list_name then
		tmp_inv:set_size(src_list_name, src_inv:get_size(src_list_name))
		tmp_inv:set_list(src_list_name, src_inv:get_list(src_list_name))
	else
		for name, list in pairs(src_inv:get_lists()) do
			tmp_inv:set_size(name, src_inv:get_size(name))
			tmp_inv:set_list(name, list)
		end
	end

	return tmp_inv
end

function smartshop.util.delete_tmp_inventory(inv_name)
	minetest.remove_detached_inventory(inv_name)
end

function smartshop.util.check_shop_add_remainder(shop, remainder)
	if remainder:get_count() == 0 then
		return false
	end

	local owner = shop:get_owner()
	local pos_as_string = shop:get_pos_as_string()

	smartshop.util.error("ERROR: %s's smartshop @ %s lost %s while adding", owner, pos_as_string, remainder:to_string())

	return true
end
function smartshop.util.check_shop_remove_remainder(shop, remainder, expected)
	if remainder:get_count() == expected:get_count() then
		return false
	end

	local owner = shop:get_owner()
	local pos_as_string = shop:get_pos_as_string()

	smartshop.util.error("ERROR: %s's smartshop @ %s lost %s of %s while removing",
		owner, pos_as_string, remainder:to_string(), expected:to_string())

	return true
end

function smartshop.util.check_player_add_remainder(player_inv, shop, remainder)
	if remainder:get_count() == 0 then
		return false
	end

	local player_name = player_inv.name

	smartshop.util.error("ERROR: %s lost %s on add using %'s shop @ %s",
		player_name, remainder:to_string(), shop:get_owner(), shop:get_pos_as_string())

	return true
end

function smartshop.util.check_player_remove_remainder(player_inv, shop, remainder, expected)
	if remainder:get_count() == expected:get_count() then
		return false
	end

	local player_name = player_inv.name

	smartshop.util.error("ERROR: %s lost %s of %s on remove from %'s shop @ %s",
		player_name, remainder:to_string(), expected:to_string(), shop:get_owner(), shop:get_pos_as_string())

	return true
end

function smartshop.util.class(super)
    local class = {}
	class.__index = class

	if super then
		setmetatable(class, {__index = super})
	end

    function class:new(...)
        local obj = setmetatable({}, class)
        if obj.__new then
            obj:__new(...)
        end
        return obj
    end

    return class
end
