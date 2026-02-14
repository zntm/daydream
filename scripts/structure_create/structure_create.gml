function structure_create(_x, _y, _id, _seed)
{
    static __size = function(_v, _width, _height)
    {
        if (_v == "width")   return _width;
        if (_v == "-width")  return -_width;
        if (_v == "height")  return _height;
        if (_v == "-height") return -_height;
        return _v;
    }
    
    // Use tile coordinates directly
    var _tx = _x;
    var _ty = _y;
    
    var _structure_data = global.structure_data[$ _id];
    var _width  = smart_value(_structure_data.get_width());
    var _height = smart_value(_structure_data.get_height());
    
    var _xoffset = __size(_structure_data.get_placement_xoffset(), _width, _height);
    var _yoffset = __size(_structure_data.get_placement_yoffset(), _width, _height);
    
    // Top-left tile calculation (simplified)
    _tx += _xoffset;
    _ty += _yoffset;
    
    if (!structure_valid(_tx, _ty, _id, _seed)) exit;
    
    global.structure_pool.acquire(_tx, _ty, _width, _height, _id);
}