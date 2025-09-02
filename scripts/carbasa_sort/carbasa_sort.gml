function carbasa_sort(_page)
{
    static __sort = function(_a, _b)
    {
        var _a_height = _a.get_height();
        var _b_height = _b.get_height();
        
        var _a_position_index = _a.get_position_index();
        var _b_position_index = _b.get_position_index();
        
        var _a_index = _a.get_index();
        var _b_index = _b.get_index();
        
        var _a_a = (_a_height * 0xffffff) + ((_a_position_index - _a_index + 1) * 0xfff);
        var _b_a = (_b_height * 0xffffff) + ((_b_position_index - _b_index + 1) * 0xfff);
        
        if (_a_a == _b_a)
        {
            return _a_index - _b_index;
        }
        
        return
            ((_b_height * 0xffffff) + ((_b_position_index + 1) * 0xfff) + ((_b.get_number() - _b_index) * 0xff)) -
            ((_a_height * 0xffffff) + ((_a_position_index + 1) * 0xfff) + ((_a.get_number() - _a_index) * 0xff));
        
    }
    
    array_sort(global.carbasa_page_position[$ _page], __sort);
    
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
        
        var _name = _sprite.get_name();
        var _index = _sprite.get_index();
        
        if (_current_x + ((_sprite.get_number() - _index) * _w) >= CARBASA_PAGE_MAX_SIZE)
        {
            if (_current_y + _h >= CARBASA_PAGE_MAX_SIZE)
            {
                throw "Too much textures";
            }
            
            _current_x = 0;
            _current_y += _current_row_height;
            
            _current_row_height = _h;
        }
        else if (_h >= _current_row_height)
        {
            _current_row_height = _h;
        }
        
        global.carbasa_page[$ _page][$ _name].sprite[@ _index] = i;
        
        _sprite.set_position(_current_x, _current_y);
        
        _current_x += _w;
        
        _width  = max(_width,  _current_x + _w);
        _height = max(_height, _current_y + _h);
    }
    
    global.carbasa_surface_size[$ _page] = (power(2, ceil(log2(_height))) << 16) | power(2, ceil(log2(_width)));
}