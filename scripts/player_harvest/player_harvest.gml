function player_harvest(_dt, _x, _y)
{
    var _tile = TILE_EMPTY;
    
    var _z = CHUNK_DEPTH - 1;
    
    for (; _z >= 0; --_z)
    {
        _tile = tile_get(_x, _y, _z);
        
        if (_tile == TILE_EMPTY) continue;
        
        break;
    }
    
    if (_z < 0) exit;
    
    var _key = string(_x) + "_" + string(_y) + "_" + string(_z);
    
    // Mark as active so it doesn't decay this tick
    harvest_current = _key;
    
    var _item_data = global.item_data;
    
    var _data = _item_data[$ _tile.get_id()];
    
    var _tile_harvest = _data.get_tile_harvest();
    
    if (_tile_harvest == undefined) exit;
    
    var _harvest_hardness = _tile_harvest.get_hardness();
    
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
        
        var _item_harvest = _data2.get_item_harvest();
        
        if (_item_harvest != undefined)
        {
            _item_hardness = _item_harvest.get_hardness() ?? 1;
            _item_level = _item_harvest.get_level() ?? 0;
        }
        
        var _condition = _tile_harvest.get_condition();
        
        if (_condition != undefined)
        {
            var _harvest_condition_id = _condition.get_id();
            
            if (_harvest_condition_id != undefined) && ((is_array(_harvest_condition_id)) ? !array_contains(_harvest_condition_id, _id) : (_harvest_condition_id != _id)) exit;
        }
    }
    
    if (_tile_harvest.get_level() > _item_level) exit;
    
    var _sfx = _data.get_tile_sfx().get_harvest().get_id();
    
    var _particle = _tile_harvest.get_particle();
    
    var _progress = harvest_progress[$ _key] ?? 0;
    _progress += _item_hardness * _dt;
    harvest_progress[$ _key] = _progress;
    
    timer_sfx_harvest += _dt;
    
    if (timer_sfx_harvest > 0.28)
    {
        timer_sfx_harvest %= 0.28;
        
        sfx_diegetic_play(audio_emitter, _x * TILE_SIZE, _y * TILE_SIZE, _sfx, global.settings.audio_tile);
        
        var _particle_colour = _particle.get_colours();
        
        repeat (round(smart_value(_particle.get_frequency()) / 2))
        {
            spawn_particle(_x * TILE_SIZE, _y * TILE_SIZE, "phantasia:tile/harvest", is_array_choose(_particle_colour));
        }
    }
    
    if (_progress >= _harvest_hardness)
    {
        tile_harvest_drop(_x, _y, _z, _tile);
        
        tile_place(_x, _y, _z, TILE_EMPTY);
        
        falling_tile_check(_x, _y - 1, _z);
        
        tile_update_surrounding(_x, _y, _z, 1, 1);
        
        if (_data.has_light())
        {
            obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOL.LIGHTING;
        }
        
        sfx_diegetic_play(audio_emitter, _x * TILE_SIZE, _y * TILE_SIZE, _sfx, global.settings.audio_tile);
        
        if (_item != INVENTORY_EMPTY) && (_data2.get_item_durability() != undefined)
        {
            _item.add_durability(-1);
            
            if (_item.get_item_durability() <= 0)
            {
                inventory_delete("base", _inventory_selected_hotbar);
            }
            
            obj_Game_Control.surface_refresh |= ((obj_Game_Control.is_opened & WORLD_OPENED_BOOL.INVENTORY) ? SURFACE_REFRESH_BOOL.INVENTORY_BACKPACK : SURFACE_REFRESH_BOOL.INVENTORY_HOTBAR);
        }
        
        var _particle_colour = _particle.get_colours();
        
        repeat (smart_value(_particle.get_frequency()))
        {
            spawn_particle(_x * TILE_SIZE, _y * TILE_SIZE, "phantasia:tile/harvest", is_array_choose(_particle_colour));
        }
        
        struct_remove(harvest_progress, _key);
        harvest_current = undefined;
        
        if (_item_hardness < _harvest_hardness)
        {
            cooldown_harvest = 0.1;
        }
        
        var _on_harvest = _data.get_on_harvest();
        var _on_harvest_length = _data.get_on_harvest_length();
        
        for (var i = 0; i < _on_harvest_length; ++i)
        {
            function_execute(_on_harvest[i], _x * TILE_SIZE, _y * TILE_SIZE, _z, 1, 1);
        }
    }
}