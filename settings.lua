smartshop.settings = {
    max_wifi_distance = tonumber(settings:get("smartshop.max_wifi_distance")) or 30,
	wifi_link_time = tonumber(settings:get("smartshop.wifi_link_time")) or 30,
    change_currency = settings:get_bool("smartshop.change_currency", true),
	enable_refund = settings:get_bool("smartshop.enable_refund", true),

	admin_shop_priv = settings:get("smartshop.admin_shop_priv") or "smartshop_admin",
}
