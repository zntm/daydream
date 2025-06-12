function player_build(_x, _y)
{
    var _item_data = global.item_data;
    
    var _inventory_selected_hotbar = global.inventory_selected_hotbar;
    var _item = global.inventory.base[_inventory_selected_hotbar];
    
    if (_item == INVENTORY_EMPTY) exit;
    
    var _item_id = _item.get_item_id();
    
    var _data = _item_data[$ _item_id];
    
    var _z = -1;
    
    if (_data.has_type(ITEM_TYPE_BIT.SOLID | ITEM_TYPE_BIT.PLATFORM))
    {
        _z = CHUNK_DEPTH_DEFAULT;
    }
    else if (_data.has_type(ITEM_TYPE_BIT.UNTOUCHABLE))
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
        else
        {
            _z = CHUNK_DEPTH_DEFAULT;
        }
    }
    else exit;
    
    if (tile_get(_x, _y, _z) != TILE_EMPTY) exit;
    
    var _requirements = _data.get_placement_requirement();
    
    if (_requirements == undefined)
    {
        if (_z != CHUNK_DEPTH_DEFAULT)
        {
            if (
                (tile_get(_x - 1, _y, _z) == TILE_EMPTY) &&
                (tile_get(_x, _y - 1, _z) == TILE_EMPTY) &&
                (tile_get(_x + 1, _y, _z) == TILE_EMPTY) &&
                (tile_get(_x, _y + 1, _z) == TILE_EMPTY)
            ) exit;
        }
        
        if (
            (tile_get(_x - 1, _y, CHUNK_DEPTH_DEFAULT) == TILE_EMPTY) &&
            (tile_get(_x, _y - 1, CHUNK_DEPTH_DEFAULT) == TILE_EMPTY) &&
            (tile_get(_x + 1, _y, CHUNK_DEPTH_DEFAULT) == TILE_EMPTY) &&
            (tile_get(_x, _y + 1, CHUNK_DEPTH_DEFAULT) == TILE_EMPTY)
        ) exit;
    }
    else
    {
        static __z = {
            "wall": CHUNK_DEPTH_WALL,
            "default": CHUNK_DEPTH_DEFAULT
        }
        
        static __item_type = global.item_type;
        
        var _length = array_length(_requirements);
        
        for (var i = 0; i < _length; ++i)
        {
            var _requirement = _requirements[i];
            
            var _tile = tile_get(_x + _requirement.xoffset, _y + _requirement.yoffset, __z[$ _requirement.z]);
            
            var _id = _requirement[$ "id"];
            
            if (_tile == TILE_EMPTY)
            {
                if (_id == "air") continue;
                
                exit;
            }
            
            _tile = _tile.get_item_id();
            
            if (_id != undefined)
            {
                if (is_array(_id)) ? (!array_contains(_id, _tile)) : (_id != _tile) exit;
            }
            
            var _types = _requirement[$ "type"];
            
            if (_types != undefined)
            {
                var _tile_data = _item_data[$ _tile];
                
                if (is_array(_types))
                {
                    var _types_length = array_length(_types);
                    
                    for (var j = 0; j < _types_length; ++j)
                    {
                        if (!_tile_data.has_type(__item_type[$ _types[j]])) exit;
                    }
                }
                else if (!_tile_data.has_type(__item_type[$ _types])) exit;
            }
        }
    }
    
    var _tile = new Tile(_item_id);
    
    if (_data.is_foliage())
    {
        _tile.set_xscale((xorshift(round(global.world.time)) & 1) ? -1 : 1);
    }
    
    tile_place(_x, _y, _z, _tile);
    
    inventory_item_decrement("base", _inventory_selected_hotbar);
    
    surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY;
    
    var _sfx = _data.get_sfx_build();
    
    if (_sfx != undefined)
    {
        sfx_diegetic_play(_x * TILE_SIZE, _y * TILE_SIZE, _sfx);
    }
    
    cooldown_build = 0.15;
}