function carbasa_sort(_page)
{
    var _data = global.carbasa_page_position[$ _page];
    
    var _length = array_length(_data);
    
    var _current_x = 0;
    var _current_y = 0;
    var _current_row_height = 0;
    
    var _width = 64;
    var _height = 64;
    
    for (var i = 0; i < _length; ++i)
    {
        var _sprite = _data[i];
        
        var _w = _sprite.get_width();
        var _h = _sprite.get_height();
        
        if (_current_x + (_w * _sprite.get_number()) >= CARBASA_PAGE_MAX_SIZE)
        {
            _current_x = 0;
            _current_y += _current_row_height;
            
            _current_row_height = 0;
        }
        
        global.carbasa_page[$ _page][$ _sprite.get_name()].sprite[@ _sprite.get_index()] = i;
        
        _data[@ i].set_position(_current_x, _current_y);
        
        _current_x += _w;
        
        if (_h >= _current_row_height)
        {
            _current_row_height = _h;
        }
        
        _width  = max(_width,  _current_x + _w);
        _height = max(_height, _current_y + _h);
        
        if (_current_y + _h >= CARBASA_PAGE_MAX_SIZE)
        {
            throw "Too much textures";
        }
    }
    
    global.carbasa_surface_size[$ _page] = (power(2, ceil(log2(_height))) << 16) | power(2, ceil(log2(_width)));
}
