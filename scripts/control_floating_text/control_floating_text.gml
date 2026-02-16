function control_floating_text(_dt)
{
    var _active = global.floating_text_active;
    var _pool = global.floating_text_pool;
    
    var _camera_x = global.camera_x;
    var _camera_y = global.camera_y;
    
    var _camera_width  = global.camera_width;
    var _camera_height = global.camera_height;
    
    for (var i = array_length(_active) - 1; i >= 0; --i)
    {
        var _inst = _active[i];
        
        with (_inst)
        {
            timer_life -= _dt / GAME_TICK;
            
            if (timer_life <= 0)
            {
                array_delete(_active, i, 1);
                
                _pool.release(_inst);
                
                break;
            }
            
            var _acceleration = 0.14 * _dt / 2;
            
            yvelocity = clamp(yvelocity + _acceleration, -PHYSICS_TERMINAL_VELOCITY, PHYSICS_TERMINAL_VELOCITY);
            
            y += yvelocity * _dt;
            
            yvelocity = clamp(yvelocity + _acceleration, -PHYSICS_TERMINAL_VELOCITY, PHYSICS_TERMINAL_VELOCITY);
            
            var _string_width  = string_width(text) / 2;
            var _string_height = string_height(text);
            
            if (!rectangle_in_rectangle(x - _string_width, y - _string_height, x + _string_width, y + _string_height, _camera_x, _camera_y, _camera_x + _camera_width, _camera_y + _camera_height))
            {
                array_delete(_active, i, 1);
                
                _pool.release(_inst);
            }
        }
    }
}