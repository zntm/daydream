#macro INVENTORY_DROP_XVELOCITY 0.2
#macro INVENTORY_DROP_YVELOCITY 0.6

function inventory_drop()
{
    var _inventory_selected_hotbar = global.inventory_selected_hotbar;
    var _item = global.inventory.base[_inventory_selected_hotbar];
    
    if (_item == INVENTORY_EMPTY) exit;
    
    if (keyboard_check(vk_shift))
    {
        spawn_item_drop(x, y - TILE_SIZE, _item, sign(image_xscale), image_xscale * INVENTORY_DROP_XVELOCITY, -INVENTORY_DROP_YVELOCITY, GAME_TICK * 3);
        
        global.inventory.base[@ _inventory_selected_hotbar] = INVENTORY_EMPTY;
        
        exit;
    }
    
    spawn_item_drop(x, y - TILE_SIZE, variable_clone(_item).set_amount(1), sign(image_xscale), image_xscale * INVENTORY_DROP_XVELOCITY, -INVENTORY_DROP_YVELOCITY, GAME_TICK * 3);
    
    inventory_item_decrement("base", _inventory_selected_hotbar);
}