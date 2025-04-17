function carbasa_sort(_page)
{
    var _data = global.carbasa_page_position[$ _page];
    
    array_sort(_data, function(a, b)
    {
        return b.get_height() - a.get_height();
    });
    
    var _length = array_length(_data);
    
    var current_x = 0;
    var current_y = 0;
    var current_row_height = 0;
    
    var _width = 64;
    var _height = 64;
    
    for (var i = 0; i < _length; ++i)
    {
        var sprite = _data[i];
        
        var w = sprite.get_width();
        var h = sprite.get_height();
        
        // Check if we need to move to a new row
        if (current_x + w >= 2048)
        {
            current_y += current_row_height;
            current_x = 0;
            current_row_height = 0;
        }
        
        global.carbasa_page[$ _page][$ sprite.get_name()].sprite[@ sprite.get_index()] = i;
        
        _data[@ i].set_position(current_x, current_y);
        
        // Update current position
        current_x += w + 1;
        if (h + 1 > current_row_height)
        {
            current_row_height = h + 1;
        }
        
        _width  = max(_width,  current_x + w);
        _height = max(_height, current_y + h);
        
        if (current_y + h >= 2048)
        {
            throw "Too much textures"
        }
    }
    
    global.carbasa_surface_size[$ _page] = (power(2, ceil(log2(_height))) << 16) | power(2, ceil(log2(_width)));
}