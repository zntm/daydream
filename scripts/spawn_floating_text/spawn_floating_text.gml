function spawn_floating_text(_x, _y, _text, _xvelocity = 0, _yvelocity = 0, _xscale = 0.5, _yscale = 0.5, _rotation = 0, _colour = c_white)
{
    _text = string(_text);
    
    var _camera_x = global.camera_x;
    var _camera_y = global.camera_y;
    
    var _camera_width  = global.camera_width;
    var _camera_height = global.camera_height;
    
    var _string_width  = string_width(_text) / 2;
    var _string_height = string_height(_text);
    
    if (!rectangle_in_rectangle(_x - _string_width, _y - _string_height, _x + _string_width, _y + _string_height, _camera_x, _camera_y, _camera_x + _camera_width, _camera_y + _camera_height)) exit;
    
    var _pool = global.floating_text_pool;
    var _active = global.floating_text_active;
    
    var _inst = _pool.get_free_item();
    
    _inst.x = _x;
    _inst.y = _y;
    
    _inst.image_xscale = _xscale;
    _inst.image_yscale = _yscale;
    
    _inst.image_blend = _colour;
    
    _inst.text = _text;
    
    _inst.xvelocity = _xvelocity;
    _inst.yvelocity = _yvelocity;
    
    _inst.rotation = _rotation;
    
    _inst.timer_life = 0.56;
    
    array_push(_active, _inst);
}