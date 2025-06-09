function spawn_floating_text(_x, _y, _text, _xvelocity = 0, _yvelocity = 0, _xscale = 0.5, _yscale = 0.5, _rotation = 0, _colour = c_white)
{
    var _camera_x = global.camera_x;
    var _camera_y = global.camera_y;
    
    var _camera_width  = global.camera_width;
    var _camera_height = global.camera_height;
    
    var _string_width  = string_width(_text) / 2;
    var _string_height = string_height(_text);
    
    if (!rectangle_in_rectangle(_x - _string_width, _y - _string_height, _x + _string_width, _y, _camera_x, _camera_y, _camera_x + _camera_width, _camera_y + _camera_height))
    {
        instance_destroy();
        
        exit;
    }
    
    with (instance_create_layer(_x, _y, "Instances", obj_Floating_Text))
    {
        image_xscale = _xscale;
        image_yscale = _yscale;
        
        image_blend = _colour;
        
        text = _text;
        
        xvelocity = _xvelocity;
        yvelocity = _yvelocity;
        
        rotation = _rotation;
        
        timer_life = 0.56;
    }
}