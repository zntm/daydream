function player_harvest(_dt, _x, _y)
{
    var _tile = TILE_EMPTY;
    
    var _z = CHUNK_DEPTH - 1;
    
    for (; _z >= 0; --_z)
    {
        _tile = tile_get(_x, _y, _z);
        
        if (_tile == TILE_EMPTY) continue;
        
        if (_x != tile_harvest_x) || (_y != tile_harvest_y) || (_z != tile_harvest_z)
        {
            obj_Player.timer_sfx_harvest = 0.28;
            
            timer_harvest = 0;
            
            cooldown_harvest = 0.1;
        }
        
        tile_harvest_x = _x;
        tile_harvest_y = _y;
        tile_harvest_z = _z;
        
        break;
    }
    
    if (_z < 0) exit;
    
    var _item_data = global.item_data;
    
    var _data = _item_data[$ _tile.get_id()];
    
    var _harvest_hardness = _data.get_tile_harvest_hardness();
    
    if (_harvest_hardness < 0) exit;
    
    var _data2 = undefined;
    
    var _inventory_selected_hotbar = global.inventory_selected_hotbar;
    var _item = global.inventory.base[_inventory_selected_hotbar];
    
    var _id = undefined;
    
    var _item_type = 0;
    
    var _item_hardness = 1;
    var _item_level = 0;
    
    if (_item != INVENTORY_EMPTY)
    {
        _id = _item.get_id();
        
        _data2 = _item_data[$ _id];
        
        _item_type = _data2.get_type();
        
        _item_hardness = _data2.get_item_harvest_hardness() ?? 1;
        _item_level = _data2.get_item_harvest_level();
        
        var _harvest_condition_id = _data.get_tile_harvest_condition_id();
        
        if (_harvest_condition_id != undefined) && (!array_contains(_harvest_condition_id, _id)) exit;
    }
    
    if (_data.get_tile_harvest_level() > _item_level) exit;
    
    timer_harvest += _item_hardness * _dt;
    
    obj_Player.timer_sfx_harvest += _dt;
    
    if (obj_Player.timer_sfx_harvest > 0.28)
    {
        obj_Player.timer_sfx_harvest %= 0.28;
        
        sfx_diegetic_play(obj_Player.audio_emitter, _x * TILE_SIZE, _y * TILE_SIZE, _data.get_sfx_harvest());
        
        var _particle_colour = _data.get_tile_harvest_particle_colour();
        
        repeat (round(smart_value(_data.get_tile_harvest_particle_frequency()) / 2))
        {
            spawn_particle(_x * TILE_SIZE, _y * TILE_SIZE, "phantasia:tile/harvest", is_array_choose(_particle_colour));
        }
    }
    
    if (timer_harvest >= _harvest_hardness)
    {
        tile_harvest_drop(_x, _y, _z, _tile);
        
        tile_place(_x, _y, _z, TILE_EMPTY);
        
        tile_update_surrounding(_x, _y, _z, 1, 1);
        
        if (_data.has_light())
        {
            obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.LIGHTING;
        }
        
        sfx_diegetic_play(obj_Player.audio_emitter, _x * TILE_SIZE, _y * TILE_SIZE, _data.get_sfx_harvest());
        
        if (_item != INVENTORY_EMPTY) && (_data2.get_item_durability_amount() > 0)
        {
            _item.add_durability(-1);
            
            if (_item.get_item_durability() <= 0)
            {
                inventory_delete("base", _inventory_selected_hotbar);
            }
            
            surface_refresh |= ((is_opened & IS_OPENED_BOOLEAN.INVENTORY) ? SURFACE_REFRESH_BOOLEAN.INVENTORY_BACKPACK : SURFACE_REFRESH_BOOLEAN.INVENTORY_HOTBAR);
        }
        
        var _particle_colour = _data.get_tile_harvest_particle_colour();
        
        repeat (smart_value(_data.get_tile_harvest_particle_frequency()))
        {
            spawn_particle(_x * TILE_SIZE, _y * TILE_SIZE, "phantasia:tile/harvest", is_array_choose(_particle_colour));
        }
        
        timer_harvest = 0;
        
        if (_item_hardness < _harvest_hardness)
        {
            cooldown_harvest = 0.1;
        }
    }
}