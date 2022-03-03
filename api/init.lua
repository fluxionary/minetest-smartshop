smartshop.api = {}


local shop_node_names = {
	"smartshop:shop",
	"smartshop:shop_full",
	"smartshop:shop_empty",
	"smartshop:shop_used",
	"smartshop:shop_admin"
}

function smartshop.api.is_smartshop(pos)
	local node_name = minetest.get_node(pos).name
	for _, name in ipairs(shop_node_names) do
		if name == node_name then
			return true
		end
	end
	return false
end

smartshop.dofile("api", "node_class")
smartshop.dofile("api", "shop_class")
smartshop.dofile("api", "storage_class")

function smartshop.api.get_object(pos)
	if smartshop.api.is_smartshop(pos) then
		return smartshop.node_class:new(pos)
	else
		return smartshop.storage_class:new(pos)
	end
end


