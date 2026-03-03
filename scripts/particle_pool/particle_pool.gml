#macro PARTICLE_POOL_SIZE 2000
#macro PARTICLE_POOL_GROWTH 500

function ParticlePool() : Pool() constructor
{
    active = array_create(PARTICLE_POOL_SIZE, false);
    
    px = array_create(PARTICLE_POOL_SIZE, 0);
    py = array_create(PARTICLE_POOL_SIZE, 0);
    xvelocity = array_create(PARTICLE_POOL_SIZE, 0);
    yvelocity = array_create(PARTICLE_POOL_SIZE, 0);
    
    speed = array_create(PARTICLE_POOL_SIZE, 0);
    direction = array_create(PARTICLE_POOL_SIZE, 0);
    speed_increment = array_create(PARTICLE_POOL_SIZE, 0);
    speed_wiggle = array_create(PARTICLE_POOL_SIZE, 0);
    direction_increment = array_create(PARTICLE_POOL_SIZE, 0);
    direction_wiggle = array_create(PARTICLE_POOL_SIZE, 0);
    
    particle_id = array_create(PARTICLE_POOL_SIZE, "");
    image_index = array_create(PARTICLE_POOL_SIZE, 0);
    
    xscale = array_create(PARTICLE_POOL_SIZE, 1);
    yscale = array_create(PARTICLE_POOL_SIZE, 1);
    xscale_increment = array_create(PARTICLE_POOL_SIZE, 0);
    yscale_increment = array_create(PARTICLE_POOL_SIZE, 0);
    xscale_wiggle = array_create(PARTICLE_POOL_SIZE, 0);
    yscale_wiggle = array_create(PARTICLE_POOL_SIZE, 0);
    
    rotation = array_create(PARTICLE_POOL_SIZE, 0);
    rotation_increment = array_create(PARTICLE_POOL_SIZE, 0);
    rotation_wiggle = array_create(PARTICLE_POOL_SIZE, 0);
    rotation_relative = array_create(PARTICLE_POOL_SIZE, false);
    
    colour1 = array_create(PARTICLE_POOL_SIZE, c_white);
    colour2 = array_create(PARTICLE_POOL_SIZE, c_white);
    colour3 = array_create(PARTICLE_POOL_SIZE, c_white);
    alpha1 = array_create(PARTICLE_POOL_SIZE, 1);
    alpha2 = array_create(PARTICLE_POOL_SIZE, 1);
    alpha3 = array_create(PARTICLE_POOL_SIZE, 1);
    colour = array_create(PARTICLE_POOL_SIZE, c_white);
    alpha = array_create(PARTICLE_POOL_SIZE, 1);
    
    timer_life = array_create(PARTICLE_POOL_SIZE, 0);
    timer_life_max = array_create(PARTICLE_POOL_SIZE, 0);
    
    has_collision = array_create(PARTICLE_POOL_SIZE, false);
    gravity_amount = array_create(PARTICLE_POOL_SIZE, 0);
    gravity_direction = array_create(PARTICLE_POOL_SIZE, 270);
    gravity_point_x = array_create(PARTICLE_POOL_SIZE, undefined);
    gravity_point_y = array_create(PARTICLE_POOL_SIZE, undefined);
    gravity_point_function = array_create(PARTICLE_POOL_SIZE, undefined);
    
    wind_factor = array_create(PARTICLE_POOL_SIZE, 0);
    
    is_additive = array_create(PARTICLE_POOL_SIZE, false);
    can_destroy_on_tile_collision = array_create(PARTICLE_POOL_SIZE, false);
    
    active_count = 0;
    pool_size = PARTICLE_POOL_SIZE;
    
    collision_indices = [];
    collision_count = 0;
    
    free_stack = array_create(PARTICLE_POOL_SIZE);
    free_stack_top = PARTICLE_POOL_SIZE - 1;
    
    for (var i = 0; i < PARTICLE_POOL_SIZE; ++i)
    {
        free_stack[@ i] = i;
    }
    
    static allocate = function()
    {
        if (free_stack_top < 0)
        {
            return undefined;
        }
        
        var _index = free_stack[free_stack_top];
        
        --free_stack_top;
        ++active_count;
        
        return _index;
    }
    
    static release = function(_index)
    {
        if (!active[_index]) || (_index < 0) || (_index >= pool_size) exit;
        
        if (has_collision[_index])
        {
            var _coll_index = array_get_index(collision_indices, _index);
            
            if (_coll_index >= 0)
            {
                array_delete(collision_indices, _coll_index, 1);
                
                --collision_count;
            }
        }
        
        active[@ _index] = false;
        
        free_stack[@ ++free_stack_top] = _index;
        
        --active_count;
    }
    
    /// @function clear_all()
    /// @desc Clear all active particles and reset the pool
    static clear_all = function()
    {
        active_count = 0;
        collision_count = 0;
        collision_indices = [];
        
        for (var i = 0; i < pool_size; ++i)
        {
            active[@ i] = false;
            free_stack[@ i] = i;
        }
        
        free_stack_top = pool_size - 1;
        
        PRINT($"[PARTICLE_POOL] Cleared all particles");
    }
    
    static spawn = function(_x, _y, _particle_id, _tint = c_white)
    {
        var _data = global.particle_data[$ _particle_id];
        
        if (_data == undefined) exit;
        
        var _index = allocate();
        
        if (_index == undefined) exit;
        
        active[@ _index] = true;
        
        px[@ _index] = _x;
        py[@ _index] = _y;
        
        var _speed_min = smart_value(_data.get_speed_min());
        var _speed_max = smart_value(_data.get_speed_max());
        
        speed[@ _index] = random_range(_speed_min, _speed_max);
        speed_increment[@ _index] = smart_value(_data.get_speed_increment());
        speed_wiggle[@ _index] = smart_value(_data.get_speed_wiggle());
        
        var _direction_min = smart_value(_data.get_direction_min());
        var _direction_max = smart_value(_data.get_direction_max());
        
        direction[@ _index] = random_range(_direction_min, _direction_max);
        
        direction_increment[@ _index] = smart_value(_data.get_direction_increment());
        direction_wiggle[@ _index] = smart_value(_data.get_direction_wiggle());
        
        var _speed = speed[_index] * GAME_TICK;
        var _direction = direction[_index];
        
        xvelocity[@ _index] = lengthdir_x(_speed, _direction);
        yvelocity[@ _index] = lengthdir_y(_speed, _direction);
        
        particle_id[@ _index] = _particle_id;
        image_index[@ _index] = 0;
        
        var _xscale_min = smart_value(_data.get_xscale_min());
        var _xscale_max = smart_value(_data.get_xscale_max());
        
        xscale[@ _index] = random_range(_xscale_min, _xscale_max);
        xscale_increment[@ _index] = smart_value(_data.get_xscale_increment());
        xscale_wiggle[@ _index] = smart_value(_data.get_xscale_wiggle());
        
        var _yscale_min = smart_value(_data.get_yscale_min());
        var _yscale_max = smart_value(_data.get_yscale_max());
        
        yscale[@ _index] = random_range(_yscale_min, _yscale_max);
        yscale_increment[@ _index] = smart_value(_data.get_yscale_increment());
        yscale_wiggle[@ _index] = smart_value(_data.get_yscale_wiggle());
        
        var _angle_min = smart_value(_data.get_angle_min());
        var _angle_max = smart_value(_data.get_angle_max());
        
        rotation[@ _index] = random_range(_angle_min, _angle_max);
        rotation_increment[@ _index] = smart_value(_data.get_angle_increment());
        rotation_wiggle[@ _index] = smart_value(_data.get_angle_wiggle());
        rotation_relative[@ _index] = _data.get_angle_relative();
        
        var _c1 = _data.get_colour1();
        var _c2 = _data.get_colour2();
        var _c3 = _data.get_colour3();
        
        colour1[@ _index] = ((_c1 != undefined) ? hex_parse(_c1) : _tint);
        colour2[@ _index] = ((_c2 != undefined) ? hex_parse(_c2) : _tint);
        colour3[@ _index] = ((_c3 != undefined) ? hex_parse(_c3) : _tint);
        
        alpha1[@ _index] = smart_value(_data.get_alpha1());
        alpha2[@ _index] = (_data.get_alpha2() != undefined) ? smart_value(_data.get_alpha2()) : alpha1[_index];
        alpha3[@ _index] = (_data.get_alpha3() != undefined) ? smart_value(_data.get_alpha3()) : alpha2[_index];
        
        colour[@ _index] = colour1[_index];
        alpha[@ _index] = alpha1[_index];
        
        var _lifetime = smart_value(_data.get_lifetime());
        
        timer_life[@ _index] = _lifetime;
        timer_life_max[@ _index] = _lifetime;
        
        gravity_amount[@ _index] = smart_value(_data.get_gravity_amount()) * GAME_TICK;
        gravity_direction[@ _index] = smart_value(_data.get_gravity_direction());
        
        var _gravity_point_x = _data.get_gravity_point_x();
        var _gravity_point_y = _data.get_gravity_point_y();
        
        gravity_point_x[@ _index] = (_gravity_point_x != undefined) ? smart_value(_gravity_point_x) : undefined;
        gravity_point_y[@ _index] = (_gravity_point_y != undefined) ? smart_value(_gravity_point_y) : undefined;
        
        gravity_point_function[@ _index] = _data.get_gravity_point_function();
        
        wind_factor[@ _index] = smart_value(_data.get_wind_factor());
        
        has_collision[@ _index] = _data.has_collision();
        can_destroy_on_tile_collision[@ _index] = _data.can_destroy_on_tile_collision();
        
        if (has_collision[_index])
        {
            array_push(collision_indices, _index);
            
            ++collision_count;
        }
        
        is_additive[@ _index] = _data.is_additive();
        
        return _index;
    }
    
    static update_visuals = function(_dt)
    {
        if (active_count <= 0) exit;
        
        var _camera_x = global.camera_x;
        var _camera_y = global.camera_y;
        var _camera_width = global.camera_width;
        var _camera_height = global.camera_height;
        var _camera_x2 = _camera_x + _camera_width;
        var _camera_y2 = _camera_y + _camera_height;
        
        for (var i = 0; i < pool_size; ++i)
        {
            if (!active[i]) continue;
            
            timer_life[@ i] -= _dt;
            
            if (timer_life[i] <= 0)
            {
                release(i);
                
                continue;
            }
            
            var _life_progress = 1 - (timer_life[i] / timer_life_max[i]);
            
            if (_life_progress < 0.5)
            {
                var _t = _life_progress * 2;
                
                colour[@ i] = merge_colour(colour1[i], colour2[i], _t);
                alpha[@ i] = lerp(alpha1[i], alpha2[i], _t);
            }
            else
            {
                var _t = (_life_progress - 0.5) * 2;
                
                colour[@ i] = merge_colour(colour2[i], colour3[i], _t);
                alpha[@ i] = lerp(alpha2[i], alpha3[i], _t);
            }
            
            xscale[@ i] += xscale_increment[i] * _dt;
            yscale[@ i] += yscale_increment[i] * _dt;
            
            if (xscale_wiggle[i] != 0)
            {
                xscale[@ i] += sin(timer_life[i] * xscale_wiggle[i]) * xscale_wiggle[i] * 0.1;
            }
            
            if (yscale_wiggle[i] != 0)
            {
                yscale[@ i] += sin(timer_life[i] * yscale_wiggle[i]) * yscale_wiggle[i] * 0.1;
            }
            
            rotation[@ i] += rotation_increment[i] * _dt;
            
            if (rotation_wiggle[i] != 0)
            {
                rotation[@ i] += sin(timer_life[i] * rotation_wiggle[i]) * rotation_wiggle[i] * 0.1;
            }
            
            if (rotation_relative[i])
            {
                rotation[@ i] = point_direction(0, 0, xvelocity[i], yvelocity[i]);
            }
            
            var _old_speed = speed[i];
            var _old_direction = direction[i];
            
            speed[@ i] += speed_increment[i] * _dt;
            
            if (speed_wiggle[i] != 0)
            {
                speed[@ i] += sin(timer_life[i] * speed_wiggle[i]) * speed_wiggle[i] * 0.1;
            }
            
            direction[@ i] += direction_increment[i] * _dt;
            
            if (direction_wiggle[i] != 0)
            {
                direction[@ i] += sin(timer_life[i] * direction_wiggle[i]) * direction_wiggle[i] * 0.1;
            }
            
            if (!has_collision[i])
            {
                if (gravity_amount[i] != 0)
                {
                    var _speed_delta = (speed[i] - _old_speed) * GAME_TICK;
                    var _direction_delta = direction[i] - _old_direction;
                    
                    if (_speed_delta != 0) || (_direction_delta != 0)
                    {
                        if (_direction_delta != 0)
                        {
                            var _current_speed = point_distance(0, 0, xvelocity[i], yvelocity[i]);
                            var _current_direction = point_direction(0, 0, xvelocity[i], yvelocity[i]) + _direction_delta;
                            
                            xvelocity[@ i] = lengthdir_x(_current_speed + _speed_delta, _current_direction);
                            yvelocity[@ i] = lengthdir_y(_current_speed + _speed_delta, _current_direction);
                        }
                        else
                        {
                            
                            var _current_speed = point_distance(0, 0, xvelocity[i], yvelocity[i]);
                            
                            if (_current_speed > 0)
                            {
                                var _scale = (_current_speed + _speed_delta) / _current_speed;
                                xvelocity[@ i] *= _scale;
                                yvelocity[@ i] *= _scale;
                            }
                        }
                    }
                    
                    xvelocity[@ i] += lengthdir_x(gravity_amount[i], gravity_direction[i]) * _dt;
                    yvelocity[@ i] += lengthdir_y(gravity_amount[i], gravity_direction[i]) * _dt;
                }
                else
                {
                    var _current_speed = speed[i] * GAME_TICK;
                    
                    xvelocity[@ i] = lengthdir_x(_current_speed, direction[i]);
                    yvelocity[@ i] = lengthdir_y(_current_speed, direction[i]);
                }
                
                var _gravity_point_x = gravity_point_x[i];
                var _gravity_point_y = gravity_point_y[i];
                
                var _gravity_point_function = gravity_point_function[i];
                
                if (_gravity_point_function != undefined)
                {
                    try
                    {
                        var _result = proglang_execute(_gravity_point_function);
                        
                        if (is_struct(_result))
                        {
                            _gravity_point_x = _result[$ "x"] ?? _gravity_point_x;
                            _gravity_point_y = _result[$ "y"] ?? _gravity_point_y;
                        }
                    }
                    catch (e)
                    {
                    }
                }
                
                if (_gravity_point_x != undefined) && (_gravity_point_y != undefined)
                {
                    var _dist = point_distance(px[i], py[i], _gravity_point_x, _gravity_point_y);
                    
                    if (_dist > 1)
                    {
                        var _force = gravity_amount[i] / max(1, _dist * 0.1);
                        var _gravity_point_direction = point_direction(px[i], py[i], _gravity_point_x, _gravity_point_y);
                        
                        xvelocity[@ i] += lengthdir_x(_force, _gravity_point_direction) * _dt;
                        yvelocity[@ i] += lengthdir_y(_force, _gravity_point_direction) * _dt;
                    }
                }
                
                var _wind = global.current_world.weather.wind;
                
                if (_wind != 0) && (wind_factor[i] != 0)
                {
                    xvelocity[@ i] += _wind * wind_factor[i] * _dt;
                }
                
                px[@ i] += xvelocity[i] * _dt;
                py[@ i] += yvelocity[i] * _dt;
            }
        }
    }
    
    static update_physics = function()
    {
        if (collision_count <= 0) exit;
        
        // NOTE: No delta time scaling needed here - we're inside control_gametick's fixed tick loop
        // and velocities/gravity already have GAME_TICK baked in from spawn()
        var _sprite_asset = global.sprite_asset;
        
        for (var j = 0; j < collision_count; ++j)
        {
            var i = collision_indices[j];
            
            if (!active[i]) continue;
            
            if (gravity_amount[i] != 0)
            {
                xvelocity[@ i] += lengthdir_x(gravity_amount[i], gravity_direction[i]);
                yvelocity[@ i] += lengthdir_y(gravity_amount[i], gravity_direction[i]);
            }
            
            var _wind = global.current_world.weather.wind;
            
            if (_wind != 0) && (wind_factor[i] != 0)
            {
                var _target_wind_vel = _wind * wind_factor[i] * 5; // Target horizontal speed from wind
                xvelocity[@ i] += (_target_wind_vel - xvelocity[i]) * 0.1; 
            }
            
            // Apply general air resistance/damping
            xvelocity[@ i] *= 0.98;
            yvelocity[@ i] *= 0.99;
            
            var _particle_data = global.particle_data[$ particle_id[i]];
            var _sprite_name = _particle_data.get_sprite();
            var _sprite = _sprite_asset[$ _sprite_name].get_sprite();
            
            var _xoffset = sprite_get_xoffset(_sprite);
            var _yoffset = sprite_get_yoffset(_sprite);
            
            var _xscale = xscale[i];
            var _yscale = yscale[i];
            
            var _bbox_l = (sprite_get_bbox_left(_sprite)   - _xoffset) * _xscale;
            var _bbox_r = (sprite_get_bbox_right(_sprite)  - _xoffset) * _xscale;
            var _bbox_t = (sprite_get_bbox_top(_sprite)    - _yoffset) * _yscale;
            var _bbox_b = (sprite_get_bbox_bottom(_sprite) - _yoffset) * _yscale;
            
            var _xvelocity = xvelocity[i];
            
            if (_xvelocity != 0)
            {
                var _new_x = px[i] + _xvelocity;
                
                var _x1 = _new_x + min(_bbox_l, _bbox_r);
                var _y1 = py[i]  + min(_bbox_t, _bbox_b);
                var _x2 = _new_x + max(_bbox_l, _bbox_r);
                var _y2 = py[i]  + max(_bbox_t, _bbox_b);
                
                var _hit_tile = tile_rectangle_meeting(_x1, _y1, _x2, _y2);
                if (_hit_tile != false)
                {
                    if (can_destroy_on_tile_collision[i])
                    {
                        release(i);
                        continue;
                    }
                    
                    // Snap to wall
                    if (_xvelocity > 0)
                    {
                        var _collision_x = floor(_x2 / TILE_SIZE) * TILE_SIZE;
                        px[@ i] = _collision_x - max(_bbox_l, _bbox_r) - 0.01;
                    }
                    else
                    {
                        var _collision_x = ceil(_x1 / TILE_SIZE) * TILE_SIZE;
                        px[@ i] = _collision_x - min(_bbox_l, _bbox_r) + 0.01;
                    }
                    
                    xvelocity[@ i] = 0;
                }
                else
                {
                    px[@ i] = _new_x;
                }
            }
            
            var _yvelocity = yvelocity[i];
            
            if (_yvelocity != 0)
            {
                var _new_y = py[i] + _yvelocity;
                
                var _x1 = px[i]  + min(_bbox_l, _bbox_r);
                var _y1 = _new_y + min(_bbox_t, _bbox_b);
                var _x2 = px[i]  + max(_bbox_l, _bbox_r);
                var _y2 = _new_y + max(_bbox_t, _bbox_b);
                
                var _hit_tile = tile_rectangle_meeting(_x1, _y1, _x2, _y2);
                if (_hit_tile != false)
                {
                    if (can_destroy_on_tile_collision[i])
                    {
                        release(i);
                        continue;
                    }
                    
                    // Snap to floor/ceiling
                    if (_yvelocity > 0)
                    {
                        var _collision_y = floor(_y2 / TILE_SIZE) * TILE_SIZE;
                        py[@ i] = _collision_y - max(_bbox_t, _bbox_b) - 0.01;
                        
                        // Apply ground friction
                        xvelocity[@ i] *= 0.5;
                    }
                    else
                    {
                        var _collision_y = ceil(_y1 / TILE_SIZE) * TILE_SIZE;
                        py[@ i] = _collision_y - min(_bbox_t, _bbox_b) + 0.01;
                    }
                    
                    yvelocity[@ i] = 0;
                }
                else
                {
                    py[@ i] = _new_y;
                }
            }
        }
    }
}

global.particle_pool = new ParticlePool();
