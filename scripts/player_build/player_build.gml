function player_build(_dt, _x, _y)
{
    var _item_data = global.item_data;
    
    var _inventory_selected_hotbar = global.inventory_selected_hotbar;
    var _item = global.inventory.base[_inventory_selected_hotbar];
    
    // Check for tile interaction first (top-down through layers)
    for (var _z_int = CHUNK_DEPTH - 1; _z_int >= 0; --_z_int)
    {
        var _tile_at = tile_get(_x, _y, _z_int);
        if (_tile_at == TILE_EMPTY) continue;
        
        var _tile_data = _item_data[$ _tile_at.get_id()];
        if (_tile_data != undefined)
        {
            var _on_tile_use = _tile_data.get_on_tile_use();
            var _on_tile_use_length = _tile_data.get_on_tile_use_length() ?? 0;
            
            if (_on_tile_use_length > 0)
            {
                for (var i = 0; i < _on_tile_use_length; ++i)
                {
                    function_execute(_on_tile_use[i], _x * TILE_SIZE, _y * TILE_SIZE, _z_int, 1, 1, id, _item, _tile_at);
                }
                
                cooldown_build = 0.15;
                exit;
            }
        }
    }
    
    if (_item == INVENTORY_EMPTY) exit;
    
    var _id = _item.get_id();
    var _data = _item_data[$ _id];
    
    // Check for item on_use functions (e.g., buckets, tools with special use)
    var _on_item_use = _data.get_on_item_use();
    var _on_item_use_length = _data.get_on_item_use_length() ?? 0;
    
    if (_on_item_use_length > 0)
    {
        for (var i = 0; i < _on_item_use_length; ++i)
        {
            function_execute(_on_item_use[i], _x * TILE_SIZE, _y * TILE_SIZE, CHUNK_DEPTH_DEFAULT, 1, 1, id, _item);
            
            event_emit(new EventDataItemUse(_item, id, _x, _y));
        }
        
        cooldown_build = 0.15;
        
        exit; // Item on_use handled, don't continue with tile placement
    }
    
    var _z = CHUNK_DEPTH_DEFAULT;
    
    if (_data.has_type(ITEM_TYPE_BIT.UNTOUCHABLE))
    {
        if (_data.is_wall())
        {
            _z = CHUNK_DEPTH_WALL;
        }
        else if (_data.is_foliage())
        {
            if (tile_get(_x, _y, CHUNK_DEPTH_DEFAULT) != TILE_EMPTY) || (tile_get(_x, _y, CHUNK_DEPTH_FOLIAGE_BACK) != TILE_EMPTY) || (tile_get(_x, _y, CHUNK_DEPTH_FOLIAGE_FRONT) != TILE_EMPTY) exit;
            
            _z = choose(CHUNK_DEPTH_FOLIAGE_BACK, CHUNK_DEPTH_FOLIAGE_FRONT);
        }
    }
    else if !(_data.has_type(ITEM_TYPE_BIT.SOLID | ITEM_TYPE_BIT.PLATFORM)) exit;
    
    if (tile_get(_x, _y, _z) != TILE_EMPTY) || (!tile_placement_condition(_x, _y, _z, _item)) exit;
    
    var _tile = new Tile(_data.get_placement_id() ?? _id);
    
    if (_data.is_foliage())
    {
        _tile.set_xscale((xorshift(round(global.world_save_data.time)) & 1) ? -1 : 1);
    }
    
    tile_place(_x, _y, _z, _tile);
    
    falling_tile_check(_x, _y, _z);
    
    tile_update_surrounding(_x, _y, _z, 1, 1);
    
    tile_instance_create(_x, _y, _z, _tile);
    
    var _on_place = _data.get_on_place();
    var _on_place_length = _data.get_on_place_length();
    
    for (var i = 0; i < _on_place_length; ++i)
    {
        function_execute(_on_place[i], _x * TILE_SIZE, _y * TILE_SIZE, _z, 1, 1);
    }
    
    if (_data.has_light())
    {
        obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.LIGHTING;
    }
    
    inventory_item_decrement("base", _inventory_selected_hotbar);
    
    obj_Game_Control.surface_refresh |= ((obj_Game_Control.is_opened & IS_OPENED_BOOLEAN.INVENTORY) ? SURFACE_REFRESH_BOOLEAN.INVENTORY_BACKPACK : SURFACE_REFRESH_BOOLEAN.INVENTORY_HOTBAR);
    
    var _sfx = _data.get_tile_sfx().get_build().get_id();
    
    if (_sfx != undefined)
    {
        sfx_diegetic_play(audio_emitter, _x * TILE_SIZE, _y * TILE_SIZE, _sfx, global.settings.audio_tile);
    }
    
    cooldown_build = 0.15;
}