smartshop.settings = {
    storage_max_distance = tonumber(settings:get("smartshop.storage_max_distance")) or 30,
	storage_link_time = tonumber(settings:get("smartshop.storage_link_time")) or 30,

    change_currency = settings:get_bool("smartshop.change_currency", true),
	enable_refund = settings:get_bool("smartshop.enable_refund", true),

	admin_shop_priv = settings:get("smartshop.admin_shop_priv") or "smartshop_admin",

    -- crash, announce, log
    error_behavior = settings:get("smartshop.error_behavior") or "announce"
}
