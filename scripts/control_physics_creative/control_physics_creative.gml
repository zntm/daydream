function control_physics_creative(_dt, _id)
{
    with (_id)
    {
        xvelocity = lerp_delta(xvelocity, (input_right      - input_left)     * 0.8 * _dt, 0.55, _dt);
        yvelocity = lerp_delta(yvelocity, (input_climb_down - input_climb_up) * 0.8 * _dt, 0.55, _dt);
        
        var _xsign = sign(xvelocity);
        var _ysign = sign(yvelocity);
        
        for (var i = abs(xvelocity); i > 0; i -= 1)
        {
            var _offset = min(i, 1) * _xsign;
            
            if (tile_meeting(x + _offset, y)) break;
            
            x += _offset;
        }
        
        for (var i = abs(yvelocity); i > 0; i -= 1)
        {
            var _offset = min(i, 1) * _ysign;
            
            if (tile_meeting(x, y + _offset)) break;
            
            y += _offset;
        }
        
        var _collision_box = entity_value.collision_box;
        
        var _collision_box_width  = _collision_box.width;
        var _collision_box_height = _collision_box.height;
        
        for (var i = abs(xvelocity * _collision_box_width); i > 0; i -= _collision_box_width)
        {
            var _offset = min(i, _collision_box_width) * _xsign;
            
            if (tile_meeting(x + _offset, y)) break;
            
            x += _offset;
        }
        
        for (var i = abs(yvelocity * _collision_box_height); i > 0; i -= _collision_box_height)
        {
            var _offset = min(i, _collision_box_height) * _ysign;
            
            if (tile_meeting(x, y + _offset)) break;
            
            y += _offset;
        }
    }
}