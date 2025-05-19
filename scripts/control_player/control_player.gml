function control_player(_dt)
{
    control_physics(_dt, id);
    /*
    xvelocity = lerp(xvelocity, (keyboard_check(ord("D")) - keyboard_check(ord("A"))) * 4 * _dt, 0.05);
    yvelocity = lerp(yvelocity, (keyboard_check(ord("S")) - keyboard_check(ord("W"))) * 4 * _dt, 0.05);
    
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
    
    /*
    for (var i = abs(xvelocity * (image_xscale / 8)); i > 0; i -= entity_value.collision_box.width)
    {
        var _offset = min(i, entity_value.collision_box.width) * _xsign;
        
        if (tile_meeting(x + _offset, y)) break;
        
        x += _offset;
    }
    
    for (var i = abs(yvelocity * (image_yscale / 8)); i > 0; i -= entity_value.collision_box.height)
    {
        var _offset = min(i, entity_value.collision_box.height) * _ysign;
        
        if (tile_meeting(x, y + _offset)) break;
        
        y += _offset;
    }
    *\/
    x += xvelocity;
    y += yvelocity;
    */
    control_camera_pos(x - (global.camera_width / 2), y - (global.camera_height / 2), false, _dt);
}