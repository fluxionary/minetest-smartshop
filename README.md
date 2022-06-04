smartshop redo mod for minetest. 

based on the original smartshop mod by AiTechEye
* https://forum.minetest.net/viewtopic.php?f=11&t=14304
* https://github.com/AiTechEye/smartshop

# LICENSE

CODE: 
* (c) flux AGPL v3
* inspired by code (c) AiTechEye LGPL-2.1, though it's been rewritten from the ground up twice now...

TEXTURES:
* smartshop_border.png (c) celeron55 CC BY-SA 3.0
* smartshop_face.png (c) celeron55 CC BY-SA 3.0
* smartshop_animation_mask.png (unknown, i think i made it? it's a single white pixel? ~flux)

# USER DOCUMENTATION

This mod provides two nodes - a shop, and an external storage. 

![Preview](https://github.com/fluxionary/minetest-smartshop/screenshot.png)

the top 4 slots are for things you want to sell. you don't need to fill them all. 
the 4 slots below that are the price of the thing above them. this is what you'll get from players who buy things
at your shop.

the remaining 32 slots are the main inventory. 

# ADMIN DOCUMENTATION

why should you use this fork over AiTechEye's?

features:
* far fewer bugs, more active development
* automatic upgrade from existing smartshops (though there is no "downgrade" path, so make backups!)
* when possible, it uses fewer entities, and entities w/ drawtypes that don't cause as much of an FPS drop
  for low-power clients. 
* it simplifies the UI somewhat, and is more informative as to the source of common smartshop problems, 
  such as a shop having too many items it to permit an exchange
* saner connected storage semantics. get rid of the label "wifi" because it's confusing. 
* automatically makes correct change for currency
* API for integration with many other kinds of mods
* comes with built-in compatability w/ mesecons, mescons_mvps, pipeworks, and tubelib
* no hard dependencies on minetest_game or other mods

# LUA API

The lua API is extensive, I'll try to document it as I have time. You can interact w/ pretty much all smartshop
behavior, and easily extend functionality. 
