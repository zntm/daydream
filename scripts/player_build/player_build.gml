function player_build(_dt, _x, _y)
{
    var _item_data = global.item_data;
    
    var _inventory_selected_hotbar = global.inventory_selected_hotbar;
    var _item = global.inventory.base[_inventory_selected_hotbar];
    
    if (_item == INVENTORY_EMPTY) exit;
    
    var _id = _item.get_id();
    
    var _data = _item_data[$ _id];
    
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
    
    tile_update_surrounding(_x, _y, _z, 1, 1);
    
    tile_instance_create(_x, _y, _z, _tile);
    
    if (_data.has_light())
    {
        obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.LIGHTING;
    }
    
    inventory_item_decrement("base", _inventory_selected_hotbar);
    
    surface_refresh |= ((is_opened & IS_OPENED_BOOLEAN.INVENTORY) ? SURFACE_REFRESH_BOOLEAN.INVENTORY_BACKPACK : SURFACE_REFRESH_BOOLEAN.INVENTORY_HOTBAR);
    
    var _sfx = _data.get_sfx_build();
    
    if (_sfx != undefined)
    {
        sfx_diegetic_play(obj_Player.audio_emitter, _x * TILE_SIZE, _y * TILE_SIZE, _sfx);
    }
    
    cooldown_build = 0.15;
}