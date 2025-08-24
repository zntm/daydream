function control_creature(_dt)
{
    var _data = global.creature_data[$ _id];
    
    if (timer_immunity <= 0)
    {
        var _inst = instance_place(x, y, obj_Tool);
        
        if (instance_exists(_inst))
        {
            var _damage = global.item_data[$ _inst._id].get_item_damage();
                _damage = round(_damage * random_range(0.9, 1.1));
            
            repeat (irandom_range(8, 14))
            {
                spawn_particle(random_range(bbox_left, bbox_right), random_range(bbox_top, bbox_bottom), "phantasia:entity/damage");
            }
            
            hp -= _damage;
            
            spawn_floating_text(x, y, _damage, 0, -3.9);
            
            if (hp <= 0)
            {
                instance_destroy();
                
                exit;
            }
            
            timer_immunity = 1;
            
            inst_predator = _inst.inst_owner;
            
            xvelocity = sign(x - _inst.x) * 5.2;
            yvelocity = sign(y - _inst.y) * 0.6;
        }
    }
    
    if (timer_immunity > 0)
    {
        timer_immunity = max(0, timer_immunity - (_dt / GAME_TICK));
        
        if (timer_immunity <= 0)
        {
            inst_predator = noone;
        }
    }
    
    var _target = instance_nearest(x, y, obj_Player);
    
    if (_data.get_hostility_type() == CREATURE_HOSTILITY_TYPE.HOSTILE)
    {
        if (point_distance(x, y, _target.x, _target.y) <= (TILE_SIZE * 16))
        {
            var _direction = sign(_target.x - x);
            
            if (chance(0.1 * _dt))
            {
                if (_direction > 0)
                {
                    input_left  = false;
                    input_right = true;
                }
                else
                {
                    input_left  = true;
                    input_right = false;
                }
                
                if (_target.y < y) && (_direction != 0)
                {
                    image_xscale = abs(image_xscale) * _direction;
                    
                    if (!input_jump)
                    {
                        var _xto = x + (_direction * attribute.get_collision_box_width());
                        
                        if (tile_meeting(x, y + 1)) && (tile_meeting(_xto, y - 1)) && (entity_ai_fall_detection(_xto, y - (TILE_SIZE * 2), -attribute.get_collision_box_height(), 2) >= 2)
                        {
                            input_jump = true;
                            input_jump_pressed = true;
                        }
                    }
                }
            }
        }
        else if (chance(0.01 * _dt))
        {
            if (chance(0.2))
            {
                if (input_left) || (input_right)
                {
                    input_left = input_right;
                    input_right = !input_left;
                }
                else
                {
                    if (chance(0.5))
                    {
                        input_left = true;
                        input_right = false;
                    }
                    else
                    {
                        input_left = false;
                        input_right = true;
                    }
                }
            }
            else
            {
                input_left = false;
                input_right = false;
            }
            
            var _direction = input_right - input_left;
            
            if (_direction != 0)
            {
                image_xscale = abs(image_xscale) * _direction;
                
                if (!input_jump)
                {
                    var _xto = x + (_direction * attribute.get_collision_box_width());
                    
                    if (tile_meeting(x, y + 1)) && (tile_meeting(_xto, y - 1)) && (entity_ai_fall_detection(_xto, y - (TILE_SIZE * 2), -attribute.get_collision_box_height(), 2) >= 2)
                    {
                        input_jump = true;
                        input_jump_pressed = true;
                    }
                }
            }
        }
    }
    else
    {
        if (timer_immunity > 0)
        {
            var _direction = x - inst_predator.x;
            
            if (chance(0.1 * _dt))
            {
                if (_direction > 0)
                {
                    input_left  = false;
                    input_right = true;
                }
                else
                {
                    input_left  = true;
                    input_right = false;
                }
            }
        }
        else if (chance(0.01 * _dt))
        {
            if (chance(0.2))
            {
                if (input_left) || (input_right)
                {
                    input_left = input_right;
                    input_right = !input_left;
                }
                else
                {
                    if (chance(0.5))
                    {
                        input_left = true;
                        input_right = false;
                    }
                    else
                    {
                        input_left = false;
                        input_right = true;
                    }
                }
            }
            else
            {
                input_left = false;
                input_right = false;
            }
        }
        
        var _direction = input_right - input_left;
        
        if (_direction != 0)
        {
            image_xscale = abs(image_xscale) * _direction;
            
            if (!input_jump)
            {
                var _xto = x + (_direction * attribute.get_collision_box_width());
                
                if (tile_meeting(x, y + 1)) && (tile_meeting(_xto, y - 1)) && (entity_ai_fall_detection(_xto, y - (TILE_SIZE * 2), -attribute.get_collision_box_height(), 2) >= 2)
                {
                    input_jump = true;
                    input_jump_pressed = true;
                }
            }
        }
    }
    
    var _on_ground = tile_meeting(x, y + 1);
    
    control_physics_input(_dt, id, ((timer_panic > 0) ? 1.5 : 1));
    control_physics(_dt, id);
    
    if (y > ylast)
    {
        if (!_on_ground) && (tile_meeting(x, y + 1))
        {
            var _difference = max(0, y - ylast - 10);
            
            var _value = floor(power(floor(_difference / TILE_SIZE) * 0.62, 1.25));
            
            if (_value > 0)
            {
                hp -= _value;
                
                ylast = y;
                
                repeat (irandom_range(8, 14))
                {
                    spawn_particle(random_range(bbox_left, bbox_right), random_range(bbox_top, bbox_bottom), "phantasia:entity/damage");
                }
                
                spawn_floating_text(x, y, _value, 0, -3.9);
                
                if (hp <= 0)
                {
                    instance_destroy();
                    
                    exit;
                }
            }
        }
    }
    else
    {
        ylast = y;
    }
    
    control_entity_sfx(_dt);
    
    control_physics_input_after(_dt, id);
    
    if (attribute.has_boolean(ATTRIBUTE_BOOLEAN.HAS_REGENERATION))
    {
        control_entity_regeneration(_dt / GAME_TICK);
    }
    
    if (input_jump) && (chance(0.4 * _dt))
    {
        input_jump = false;
        input_jump_pressed = false;
    }
}