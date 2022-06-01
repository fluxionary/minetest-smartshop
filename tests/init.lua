smartshop.tests = {}
minetest.settings:set("movement_gravity", 0)

local function run_test(name, state, i)
    if not i then error(("? %s %s %s"):format(name, state, i)) end
    if i > #smartshop.tests then
        return
    end
    local player = minetest.get_player_by_name(name)
    if not player then
        return
    end
    local start = minetest.get_us_time()
    local test = smartshop.tests[i]
    local ok, res = xpcall(test.func, debug.traceback, player, state)
    local elapsed = (minetest.get_us_time() - start) / 1e6
    if ok then
        minetest.chat_send_player(name, ("%s passed in %ss"):format(test.name, elapsed))
        state = res or state
    else
        minetest.chat_send_player(name, ("%s failed in %ss"):format(test.name, elapsed))
        minetest.chat_send_player(name, res)
        return
    end

    minetest.after(0, run_test, name, state, i + 1)
end

minetest.register_chatcommand("smartshop_tests", {
    privs = {server = true},
    func = function(name)
        run_test(name, {}, 1)
    end
})

smartshop.dofile("tests", "define_items")

smartshop.dofile("tests", "initialize")
smartshop.dofile("tests", "place_shop")
smartshop.dofile("tests", "dig_shop")
smartshop.dofile("tests", "configure_shop")
smartshop.dofile("tests", "do_purchase")
smartshop.dofile("tests", "do_refund")
