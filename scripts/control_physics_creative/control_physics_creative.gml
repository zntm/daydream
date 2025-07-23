function control_physics_creative(_dt, _id)
{
    with (_id)
    {
        xvelocity = lerp_delta(xvelocity, (input_right      - input_left)     * 8.65, 0.25, _dt);
        yvelocity = lerp_delta(yvelocity, (input_climb_down - input_climb_up) * 8.65, 0.25, _dt);
        
        var _xsign = sign(xvelocity);
        var _ysign = sign(yvelocity);
        
        var _collision_box_width  = attribute.get_collision_box_width();
        var _collision_box_height = attribute.get_collision_box_height();
        
        for (var i = abs(xvelocity); i > 0; i -= _collision_box_width)
        {
            var _offset = min(i, _collision_box_width) * _xsign;
            
            if (tile_meeting(x + _offset, y))
            {
                for (var j = abs(_offset); j > 0; j -= 1)
                {
                    var _offset2 = min(j, 1) * _xsign;
                    
                    // if (tile_meeting(x + _offset2, y)) break;
                    
                    x += _offset2;
                }
                
                break;
            }
            
            x += _offset;
        }
        
        for (var i = abs(yvelocity); i > 0; i -= _collision_box_height)
        {
            var _offset = min(i, _collision_box_height) * _ysign;
            
            if (tile_meeting(x, y + _offset))
            {
                for (var j = abs(_offset); j > 0; j -= 1)
                {
                    var _offset2 = min(j, 1) * _ysign;
                    
                    // if (tile_meeting(x, y + _offset2)) break;
                    
                    y += _offset2;
                }
                
                break;
            }
            
            y += _offset;
        }
    }
}