smartshop.tests = {}
minetest.settings:set("movement_gravity", 0)

minetest.register_chatcommand("smartshop_tests", {
    privs = {server = true},
    func = function(name)
        local player = minetest.get_player_by_name(name)
        local state = {}

        for _, test in ipairs(smartshop.tests) do
            local ok, res = xpcall(test.func, debug.traceback, player, state)
            if ok then
                minetest.chat_send_player(name, ("%s passed"):format(test.name))
                state = res
            else
                minetest.chat_send_player(name, ("%s failed"):format(test.name))
                minetest.chat_send_player(name, res)
                return
            end
        end
    end
})

smartshop.dofile("tests", "define_items")

smartshop.dofile("tests", "initialize")
smartshop.dofile("tests", "place_shop")
smartshop.dofile("tests", "dig_shop")
smartshop.dofile("tests", "configure_shop")
