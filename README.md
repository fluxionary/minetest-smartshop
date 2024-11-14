smartshop redo mod for minetest.

based on the original smartshop mod by AiTechEye
* https://forum.minetest.net/viewtopic.php?f=11&t=14304
* https://github.com/AiTechEye/smartshop

# LICENSE

CODE:
* (c) flux LGPL v3
* inspired by code (c) AiTechEye LGPL-2.1, though it's been rewritten from the ground up twice now...

TEXTURES:
* smartshop_border.png (c) celeron55 CC BY-SA 3.0
* smartshop_face.png (c) celeron55 CC BY-SA 3.0

# USER DOCUMENTATION

this mod provides two nodes - a shop, and an external storage.

here is a picture of 2 properly configured shops with items for sale:

![Preview](https://github.com/fluxionary/minetest-smartshop/raw/master/screenshot.png)

here is a picture of the inventory that a shop owner sees:

![Preview](https://github.com/fluxionary/minetest-smartshop/raw/master/screenshot2.png)

the top 4 slots are for things you want to sell. you don't need to fill them all.

the 4 slots below that are the price of the thing above them. this is what you'll get from players who buy things
at your shop.

the remaining 32 slots are the main inventory.

in this example, 99 blueberries are being sold for 5 gold ingots, and 1 "cottages:roof_brown" is being sold
for 10 gold ingots.

here is a picture of what a customer will see when interacting with your shop:

![Preview](https://github.com/fluxionary/minetest-smartshop/raw/master/screenshot3.png)

if the customer has gold in their inventory, and clicks on the icons, they will "trade" some of their gold
for the items that were in the shop.

only valid exchanges will show up in the shop. the border of the shop will turn red if the shop has sold
out of any item, and it will turn purple if it is too full to allow an exchange. it will also turn green,
if it has been used and has payments inside it or connected storage.

the "send" and "refill" buttons allow you to connect a shop to external storage. press the button, then punch
a storage node. they can be the same storage node, or different nodes, and multiple shops can share storage, which
is convenient if you want to keep all your payments in one place.

the "customer" button allows the shop owner to see the shop as if they were a customer, to test that things are
configured correctly.

checking "strict meta" allows a player to sell objects with specific metadata, such as written books. by
default, metadata is ignored.

unchecking "private" allows anyone who could break the shop node, to also configure the shop, which is useful
with e.g. shared protection areas.

admin users also have the option to create a shop with unlimited inventory.

## Digiline interface

### get shop status

```lua
digiline_send('channel', {
        type='get',
        only_items_on_sale_or_buy = false
    }
)
```

Response is sent to the same channel the instruction is sent to. `only_items_on_sale_or_buy` field is optional, if this field is set to `true`, items not give or accept by shop is hidden in response. Response from shop looks like this:

```lua
{
	inventory = {
		{
			metadata = "",
			name = "smartshop:storage",
			wear = 0,
			meta = {
				
			},
			count = 1
		},
		{
			metadata = "",
			name = "default:dirt",
			wear = 0,
			meta = {
				
			},
			count = 3
		},
		{
			metadata = "",
			name = "default:dry_dirt",
			wear = 0,
			meta = {
				
			},
			count = 32
		},
		{
			metadata = "",
			name = "mesecons_luacontroller:luacontroller0000",
			wear = 0,
			meta = {
				
			},
			count = 1
		}
	},
	type = "shop status",
	offer = {
		{
			give = {
				metadata = "",
				name = "default:cobble",
				wear = 0,
				meta = {
					
				},
				count = 7
			},
			stock = 16,
			pay = {
				metadata = "",
				name = "default:dry_dirt",
				wear = 0,
				meta = {
					
				},
				count = 2
			}
		},
		{
			give = {
				metadata = "",
				name = "default:dirt",
				wear = 0,
				meta = {
					
				},
				count = 6
			},
			stock = 1,
			pay = {
				metadata = "",
				name = "smartshop:storage",
				wear = 0,
				meta = {
					
				},
				count = 1
			}
		},
		{
			give = {
				metadata = "",
				name = "currency:minegeld_5",
				wear = 0,
				meta = {
					
				},
				count = 3
			},
			stock = 1,
			pay = {
				metadata = "",
				name = "mesecons_luacontroller:luacontroller0000",
				wear = 0,
				meta = {
					
				},
				count = 1
			}
		},
		{
			stock = 0
		}
	},
	freebies = false,
	strict_meta = false
}
```

## set shop offer

Following program will set third slot of offer, then this slot will receive three cobble for four dirt:

```lua
digiline_send('channel', {
        type='set',
        offer={
            [3] = {give="basenodes:dirt",give_count=4,pay="basenodes:cobble",pay_count=3}
        }
    }
)
```

## notify on run out of items

When smart shop run out of items, or customer request an item which is already sold out, message will be sent by smartshop on the same channel set by owner of smartshop. Message is a table, and its fields should be like this:

```lua
{
    type = "out of storage",
    item = "basenodes:dirt",
    offer_index = 2
}
```

## notify on transaction completed

When a transaction is completed, in other words, an item is sold and corresponding price is received, message will be sent by smartshop on the same channel set by owner of smartshop. Message is a table, and its fields should be like this:

```lua
{
    type = "transaction complete",
    item = "basenodes:dirt",
    offer_index = 2
}
```

# ADMIN DOCUMENTATION

note: now requires [futil](https://github.com/fluxionary/minetest-futil)

why should you use this fork over AiTechEye's?

## features:
* far fewer bugs, more active development
* automatic upgrade from existing smartshops (though there is no "downgrade" path, so make backups!)
* when possible, it uses fewer entities, and entities w/ drawtypes that don't cause as much of an FPS drop
  for low-power clients.
* it simplifies the UI somewhat, and is more informative as to the source of common smartshop problems,
  such as a shop having too many items it to permit an exchange
* saner external storage semantics. get rid of the label "wifi" because it's confusing.
* automatically makes correct change for known currency mods
* API for easy integration with many other kinds of mods
* comes with built-in compatability w/ mesecons, mescons_mvps, pipeworks, and tubelib
* no hard dependencies on minetest_game or other mods

## settings
* `smartshop.storage_max_distance` (default: 30)
  maximum distance between a shop and a linked storage. 0 disables the behavior.
* `smartshop.storage_link_time` (default: 30)
  time allowed to link storage after initiating the process
* `smartshop.change_currency` (default: true)
  automatically make change for currency, if currency is present
* `smartshop.enable_refund` (default: true)
  whether to refund the pay/give line of "old" shops. if you are not upgrading from the old version, set this to false
  to disable an LBM that otherwise has to run on every load.
* `smartshop.admin_shop_priv` (default: smartshop_admin)
  privilege of a shop admin user, who may use the owner interface of any shop, and may set up shops which allow for
  unlimited exchanges without need for stock
* `smartshop.error_behavior` (default: announce)
  behavior on serious errors which wouldn't normally crash, such as not being able to properly remove or add an item
  to an inventory, resulting in possible lost items.
* `smartshop.enable_tests` (default: false)
  enable if you want to run the testing suite. do not enable in general, and do not use on a real world, as it is
  destructive

# LUA API

The lua API is extensive, I'll try to document it as I have time. You can interact w/ pretty much all smartshop
behavior, and easily extend functionality. I'll outline a few important things now:

* `smartshop.api.is_shop(pos)`
* `smartshop.api.is_storage(pos)`
* `smartshop.api.get_object(pos)`
  returns a shop object, a storage object, or nil if the node is not a shop or storage.
* `smartshop.api.register_purchase_mechanic(def)`
```lua
def = {
    name = "mod:some_name",
    allow_purchase = function(player, shop, i)
        return true -- if this mechanic can handle this transaction
    end,
    do_purchase = function(player, shop, i)
        -- does the exchange and updates player and shop inventories
    end,
}
```
* `smartshop.api.register_on_purchase(callback)`
```lua
callback = function(player, shop, i)
    -- called when something is purchased
end
```
* `smartshop.api.register_on_shop_full(callback)`
```lua
callback = function(player, shop, i)
    -- called when a purchase fails because the shop is full
end
```
* `smartshop.api.register_on_shop_empty(callback)`
```lua
callback = function(player, shop, i)
    -- called when the shop sells out of something
end
```
* `smartshop.api.register_transaction_transform(callback)`
```lua
callback = function(player, shop, i, shop_removed, player_removed)
    -- sometimes, it is necessary to alter the items in an exchange
    -- e.g. changing the owner of a petz "pet"
    return shop_removed, player_removed
end
```
