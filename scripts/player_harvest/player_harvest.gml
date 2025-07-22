function player_harvest(_dt, _x, _y)
{
    var _tile = TILE_EMPTY;
    
    var _z = CHUNK_DEPTH - 1;
    
    for (; _z >= 0; --_z)
    {
        _tile = tile_get(_x, _y, _z);
        
        if (_tile == TILE_EMPTY) continue;
        
        if (_x != harvest_x) || (_y != harvest_y) || (_z != harvest_z)
        {
            obj_Player.timer_sfx_harvest = 0.28;
            
            harvest_amount = 0;
            
            cooldown_harvest = 0.1;
        }
        
        harvest_x = _x;
        harvest_y = _y;
        harvest_z = _z;
        
        break;
    }
    
    if (_z < 0) exit;
    
    var _item_data = global.item_data;
    
    var _data = _item_data[$ _tile.get_id()];
    
    var _harvest_hardness = _data.get_harvest_hardness();
    
    if (_harvest_hardness == undefined) exit;
    
    var _harvest_type = _data.get_harvest_type();
    
    var _data2 = undefined;
    
    var _inventory_selected_hotbar = global.inventory_selected_hotbar;
    var _item = global.inventory.base[_inventory_selected_hotbar];
    
    var _item_type = 0;
    
    var _item_hardness = 1;
    var _item_level = 0;
    
    if (_item != INVENTORY_EMPTY)
    {
        _data2 = _item_data[$ _item.get_id()];
        
        _item_type = _data2.get_type();
        
        _item_hardness = _data2.get_harvest_hardness();
        _item_level = _data2.get_harvest_level();
        
        if (_harvest_type) && (!_data.has_harvest_type(_item_type)) exit;
    }
    
    if (_data.get_harvest_level() > _item_level) exit;
    
    harvest_amount += _item_hardness * _dt;
    
    obj_Player.timer_sfx_harvest += _dt;
    
    if (obj_Player.timer_sfx_harvest > 0.28)
    {
        obj_Player.timer_sfx_harvest %= 0.28;
        
        sfx_diegetic_play(obj_Player.audio_emitter, _x * TILE_SIZE, _y * TILE_SIZE, _data.get_sfx_harvest());
        
        var _particle_colour = _data.get_harvest_particle_colour();
        
        repeat (round(smart_value(_data.get_harvest_particle_frequency()) / 2))
        {
            spawn_particle(_x * TILE_SIZE, _y * TILE_SIZE, "phantasia:tile/harvest", is_array_choose(_particle_colour));
        }
    }
    
    if (harvest_amount >= _harvest_hardness)
    {
        tile_place(_x, _y, _z, TILE_EMPTY);
        
        tile_update_surrounding(_x, _y, _z, 1, 1);
        
        sfx_diegetic_play(obj_Player.audio_emitter, _x * TILE_SIZE, _y * TILE_SIZE, _data.get_sfx_harvest());
        
        if (_item != INVENTORY_EMPTY) && (_data2.get_durability_amount() > 0)
        {
            _item.add_durability(-1);
            
            if (_item.get_durability() <= 0)
            {
                inventory_delete("base", _inventory_selected_hotbar);
            }
            
            surface_refresh |= ((is_opened & IS_OPENED_BOOLEAN.INVENTORY) ? SURFACE_REFRESH_BOOLEAN.INVENTORY_BACKPACK : SURFACE_REFRESH_BOOLEAN.INVENTORY_HOTBAR);
        }
        
        var _drop_length = _data.get_drop_length();
        
        for (var i = 0; i < _drop_length; ++i)
        {
            var _drop_item = _data.get_drop(i);
            
            var _chance = _drop_item[$ "chance"];
            
            if (_chance != undefined) && (!chance(_chance)) continue;
            
            var _condition = _drop_item[$ "condition"];
            
            if (_condition != undefined)
            {
                var _tool = _condition[$ "tool"];
                
                if (_tool != undefined) && ((_item == INVENTORY_EMPTY) || !(_tool & _data2.get_type())) continue;
                
                var _index = _condition[$ "index"];
                
                if (_index != undefined) && (_tile.get_index() != _index) continue;
            }
            
            spawn_item_drop(_x * TILE_SIZE, _y * TILE_SIZE, new Inventory(_drop_item.id, _drop_item[$ "amount"] ?? 1));
        }
        
        var _particle_colour = _data.get_harvest_particle_colour();
        
        repeat (smart_value(_data.get_harvest_particle_frequency()))
        {
            spawn_particle(_x * TILE_SIZE, _y * TILE_SIZE, "phantasia:tile/harvest", is_array_choose(_particle_colour));
        }
        
        harvest_amount = 0;
        
        if (_item_hardness < _harvest_hardness)
        {
            cooldown_harvest = 0.1;
        }
    }
}