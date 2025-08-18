function control_player(_dt)
{
    if (hp <= 0) exit;
    
    audio_listener_position(x, y, 0);
    
    control_physics_input(_dt, id);
    
    var _on_ground = tile_meeting(x, y + 1);
    
    control_physics_creative(_dt, id);
    
    if (timer_attack <= 0) && (mouse_check_button(mb_left))
    {
        timer_attack = 0.3;
        
        var _item = global.inventory.base[global.inventory_selected_hotbar];
        
        if (_item != INVENTORY_EMPTY)
        {
            var _id = _item.get_id();
            
            var _data = global.item_data[$ _id];
            
            var _inst = id;
            
            if (!instance_exists(inst_item))
            {
                inst_item = instance_create_layer(x, y, "Instances", obj_Tool);
                
                inst_item._id = _id;
                
                inst_item.sprite_index = _data.get_sprite();
                
                inst_item.inst_owner = _inst;
            }
        }
    }
    
    if (timer_attack > 0)
    {
        timer_attack = max(0, timer_attack - (_dt / GAME_TICK));
    }
    
    if (timer_attack <= 0)
    {
        var _direction = input_right - input_left;
        
        if (_direction != 0)
        {
            image_xscale = abs(image_xscale) * _direction;
        }
        
        if (instance_exists(inst_item))
        {
            instance_destroy(inst_item);
        }
    }
    else if (instance_exists(inst_item))
    {
        var _x = x;
        var _y = y;
        
        var _direction = sign(image_xscale);
        
        var _t = (0.3 - timer_attack) / 0.3;
        
        var _angle = (45 * cos(_t * pi)) + 15;
        
        with (inst_item)
        {
            var _sprite_width  = sprite_get_width(sprite_index);
            var _sprite_height = sprite_get_height(sprite_index);
            
            x = _x - 0  + (lengthdir_x(_sprite_width,  _angle) * _direction);
            y = _y - 24 + (lengthdir_y(_sprite_height, _angle));
            
            image_angle = _angle * _direction;
        }
    }
    
    if (y > ylast)
    {
        if (!_on_ground) && (tile_meeting(x, y + 1))
        {
            var _difference = max(0, y - ylast - 10);
            
            var _value = floor(power(floor(_difference / TILE_SIZE) * 0.62, 1.25));
            
            if (_value > 0)
            {
                obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.HP;
                
                hp -= _value;
                
                ylast = y;
                
                spawn_floating_text(x, y, _value, 0, -3.9);
                
                if (hp <= 0)
                {
                    obj_Game_Control.timer_respawn = 3;
                    
                    exit;
                }
            }
        }
    }
    else
    {
        ylast = y;
    }
    
    var _refresh = (xvelocity != 0) || (yvelocity != 0);
    
    control_entity_sfx(_dt);
    
    control_physics_input_after(_dt, id);
    
    control_camera_pos(x - (global.camera_width / 2), y - (global.camera_height / 2), false, _dt);
    
    var _is_regenerated = false;
    
    if (attribute.has_boolean(ATTRIBUTE_BOOLEAN.HAS_REGENERATION))
    {
        _is_regenerated = control_entity_regeneration(_dt / GAME_TICK);
    }
    
    if (_is_regenerated)
    {
        obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.HP;
    }
    
    if (_refresh)
    {
        obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.LIGHTING;
        
        var _camera_x = global.camera_x;
        var _camera_y = global.camera_y;
        
        var _camera_width  = global.camera_width;
        var _camera_height = global.camera_height;
        
        var _xstart = round((_camera_x + (_camera_width  / 2)) / CHUNK_SIZE_DIMENSION) * CHUNK_SIZE_DIMENSION;
        var _ystart = round((_camera_y + (_camera_height / 2)) / CHUNK_SIZE_DIMENSION) * CHUNK_SIZE_DIMENSION;
        
        if (_xstart != obj_Game_Control.chunk_in_view_x) || (_ystart != obj_Game_Control.chunk_in_view_y)
        {
            obj_Game_Control.chunk_in_view_x = _xstart;
            obj_Game_Control.chunk_in_view_y = _ystart;
            
            control_update_chunk_in_view();
        }
    }
}