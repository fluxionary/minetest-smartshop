local v_eq = vector.equals
local v_round = vector.round

local get_meta = minetest.get_meta
local get_objects_inside_radius = minetest.get_objects_inside_radius

local api = smartshop.api

local function clear_legacy_entities(pos)
    for _, ob in ipairs(get_objects_inside_radius(pos, 3)) do
        -- "3" was chosen because "2" doesn't work sometimes. it should work w/ "1" but doesn't.
        -- note that we still check that the entity is related to the current shop

        if ob then
            local le = ob:get_luaentity()
            if le then
                if le.smartshop then
                    -- old smartshop entity
                    ob:remove()
                elseif le.pos and type(le.pos) == "table" and v_eq(pos, v_round(le.pos)) then
                    -- entities associated w/ the current pos
                    ob:remove()
                end
            end
        end
    end
end

minetest.register_lbm({
	name = "smartshop:convert_legacy",
	nodenames = {
        "smartshop:shop",
    },
    run_at_every_load = false,
	action = function(pos, node)
        -- convert legacy metadata
        local meta = get_meta(pos)
        local metatable = meta:to_table() or {}
        if metatable.creative == 1 then
            if metatable.type == 0 then
                metatable.unlimited = 1
                metatable.item_send = nil
                metatable.item_refill = nil

            elseif metatable.type == 1 then
                metatable.unlimited = 0
            end
        end

        metatable.type = nil
        meta:from_table(metatable)

		clear_legacy_entities(pos)

		local shop = api.get_object(pos)
		shop:update_appearance()
	end,
})
