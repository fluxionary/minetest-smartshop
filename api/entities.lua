
local pos_to_string = minetest.pos_to_string

local debug = false
local debug_cache = {}

local entities_by_pos = {}

function smartshop.api.record_entity(pos, obj)
	local spos = pos_to_string(pos)
	local entities = entities_by_pos[spos] or {}
	table.insert(entities, obj)
	entities_by_pos[spos] = entities
end

function smartshop.api.clear_entities(pos)
	local spos = pos_to_string(pos)
	local entities = entities_by_pos[spos] or {}
	for _, obj in ipairs(entities) do
		obj:remove()
	end
	entities_by_pos[spos] = nil
end

function smartshop.api.generate_entities(shop)
	
end

local function get_image_from_tile(tile)
	if type(tile) == "string" then
		return tile
	elseif type(tile) == "table" then
		local image_name
		if type(tile.image) == "string" then
			image_name = tile.image
		elseif type(tile.name) == "string" then
			image_name = tile.name
		end
		if image_name then
			if tile.animation and tile.animation.type == "vertical_frames" and tile.animation.aspect_w and tile.animation.aspect_h then
				return ("smartshop_animation_mask.png^[resize:%ix%i^[mask:"):format(tile.animation.aspect_w, tile.animation.aspect_h) .. image_name
			elseif tile.animation and tile.animation.type == "sheet_2d" and tile.animation.frames_w and tile.animation.frames_h then
				return image_name .. ("^[sheet:%ix%i:0,0"):format(tile.animation.frames_w, tile.animation.frames_h)
			else
				return image_name
			end
		end
	end
	return "unknown_node.png"
end

local function get_image_cube(tiles)
	if #tiles == 6 then
		return minetest.inventorycube(
			get_image_from_tile(tiles[1]),
			get_image_from_tile(tiles[6]),
			get_image_from_tile(tiles[3])
		)
	elseif #tiles == 4 then
		return minetest.inventorycube(
			get_image_from_tile(tiles[1]),
			get_image_from_tile(tiles[4]),
			get_image_from_tile(tiles[3])
		)
	elseif #tiles == 3 then
		return minetest.inventorycube(
			get_image_from_tile(tiles[1]),
			get_image_from_tile(tiles[3]),
			get_image_from_tile(tiles[3])
		)
	elseif #tiles >= 1 then
		return minetest.inventorycube(
			get_image_from_tile(tiles[1]),
			get_image_from_tile(tiles[1]),
			get_image_from_tile(tiles[1])
		)
	end
	return "unknown_node.png"
end

function smartshop.api.get_image(item)
	local def = minetest.registered_items[item]
	if not def then
		return "unknown_node.png"
	end

	local image
	local tiles = def.tiles or def.tile_images
	local inventory_image = def.inventory_image

	if inventory_image and inventory_image ~= "" then
		if type(inventory_image) == "string" then
			image = inventory_image

		elseif type(inventory_image) == "table" and #inventory_image == 1 and type(inventory_image[1]) == "string" then
			image = inventory_image[1]

		else
			smartshop.log("warning", "could not decode inventory image for %s", item)
			image = "unknown_node.png"
		end

	elseif tiles then
		if type(tiles) == "string" then
			image = tiles

		elseif type(tiles) == "table" then
			if ((not def.type or def.type == "node") and
				(not def.drawtype or
					def.drawtype == "normal" or
					def.drawtype == "allfaces" or
					def.drawtype == "allfaces_optional" or
					def.drawtype == "glasslike" or
					def.drawtype == "glasslike_framed" or
					def.drawtype == "glasslike_framed_optional" or
					def.drawtype == "liquid")
			) then
				image = get_image_cube(tiles)
			else
				image = get_image_from_tile(tiles[1])
			end
		end
	end

	if (debug or not image or image == "" or image == "unknown_node.png") and not debug_cache[item] then
		smartshop.log("warning", "[smartshop] definition for %s", item)
		for key, value in pairs(def) do
			smartshop.log("warning", "[smartshop]     %q = %q", key, minetest.serialize(value))
		end
		debug_cache[item] = true
	end

	return image or "unknown_node.png"
end
