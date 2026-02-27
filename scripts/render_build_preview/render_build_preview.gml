function render_build_preview()
{
    var _item_data = global.item_data;
    var _sprite_asset = global.sprite_asset;
    
    // Get local player
    var _lp = noone;
    with (obj_Player) { if (is_local) { _lp = id; break; } }
    if (_lp == noone) exit;
    
    // Only show preview if GUI is not covering the world
    if (obj_Game_Control.is_opened & (WORLD_OPENED_BOOL.MENU | WORLD_OPENED_BOOL.CHAT | WORLD_OPENED_BOOL.INVENTORY)) exit;
    
    var _inventory_selected_hotbar = global.inventory_selected_hotbar;
    var _item = global.inventory.base[_inventory_selected_hotbar];
    
    if (_item == INVENTORY_EMPTY) exit;
    
    var _id = _item.get_id();
    var _data = _item_data[$ _id];
    
    // Some items shouldn't show a tile preview (like tools with only on_use)
    var _on_item_use_length = _data.get_on_item_use_length() ?? 0;
    if (_on_item_use_length > 0) exit;
    
    var _z = CHUNK_DEPTH_DEFAULT;
    
    if (_data.has_type(ITEM_TYPE_BIT.UNTOUCHABLE))
    {
        if (_data.is_wall())
        {
            _z = CHUNK_DEPTH_WALL;
        }
        else if (_data.is_foliage())
        {
            // Foliage logic is slightly more complex in player_build, but for preview we can pick a default
            _z = CHUNK_DEPTH_FOLIAGE_FRONT;
        }
    }
    else if !(_data.has_type(ITEM_TYPE_BIT.SOLID | ITEM_TYPE_BIT.PLATFORM)) exit;
    
    // Calculate snapped position
    var _tile_x = round(mouse_x / TILE_SIZE);
    var _tile_y = round(mouse_y / TILE_SIZE);
    
    var _world_x = _tile_x * TILE_SIZE;
    var _world_y = _tile_y * TILE_SIZE;
    
    // Check reach distance
    var _mouse_distance = rectangle_distance(mouse_x, mouse_y, _lp.bbox_left, _lp.bbox_top, _lp.bbox_right, _lp.bbox_bottom);
    var _is_in_reach = (_mouse_distance < ATTRIBUTE_DEFAULT_BUILD_REACH);
    
    // Check validity
    var _is_valid = _is_in_reach && tile_placement_is_valid(_tile_x, _tile_y, _z, _item);
    
    // Render the preview
    var _sprite = _sprite_asset[$ _data.get_sprite()];
    if (_sprite == undefined) exit;
    
    var _color = _is_valid ? c_white : c_red;
    var _alpha = 0.5;
    
    draw_sprite_ext(_sprite.get_sprite(), _data.get_inventory_index(), _world_x, _world_y, 1, 1, 0, _color, _alpha);
}
