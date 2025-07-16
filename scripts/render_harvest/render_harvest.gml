#macro RENDER_HARVEST_OFFSET 2
#macro RENDER_HARVEST_PADDING 16

function render_harvest(_camera_x, _camera_y, _camera_width, _camera_height)
{
    static __index_max = (sprite_get_number(spr_Harvest) - 1);
    
    var _tile = tile_get(harvest_x, harvest_y, harvest_z);
    var _data = global.item_data[$ _tile.get_id()];
    
    var _width  = ceil(_data.get_sprite_width()  / TILE_SIZE);
    var _height = ceil(_data.get_sprite_height() / TILE_SIZE);
    
    var _surface_width  = (_width  * TILE_SIZE) + (RENDER_HARVEST_PADDING * 2);
    var _surface_height = (_height * TILE_SIZE) + (RENDER_HARVEST_PADDING * 2);
    
    if (!surface_exists(surface_harvest))
    {
        surface_harvest = surface_create(_surface_width, _surface_height);
    }
    else if (surface_get_width(surface_harvest) != _surface_width) || (surface_get_height(surface_harvest) != _surface_height)
    {
        surface_resize(surface_harvest, _surface_width, _surface_height);
    }
    
    surface_set_target(surface_harvest);
    draw_clear_alpha(c_black, 0);
    
    var _progress = normalize(harvest_amount, 0, _data.get_harvest_hardness());
    
    var _offset = RENDER_HARVEST_OFFSET * _progress
    
    var _sprite = _data.get_sprite();
    
    var _index = 0;
    
    if (_data.is_tile())
    {
        _index = _data.get_inventory_index();
    }
    else
    {
    	_index = _tile.get_index() + _tile.get_index_offset();
    }
    
    var _xscale = _tile.get_xscale();
    var _yscale = _tile.get_yscale();
    
    var _xoffset = _data.get_sprite_xoffset() * abs(_xscale);
    var _yoffset = _data.get_sprite_yoffset() * abs(_yscale);
    
    var _xstart = _xoffset - (TILE_SIZE / 2) + RENDER_HARVEST_PADDING + random_range(-_offset, _offset);
    var _ystart = _yoffset - (TILE_SIZE / 2) + RENDER_HARVEST_PADDING + random_range(-_offset, _offset);
    
    var _rotation = _tile.get_rotation();
    
    draw_sprite_ext(_sprite, _index, _xstart + _xoffset, _ystart + _yoffset, _xscale, _yscale, _rotation, c_white, 1);
    
    gpu_set_colorwriteenable(true, true, true, false);
    
    var _index_harvest = round(__index_max * _progress);
    
    var _harvest_width  = ceil(_width  / 2);
    var _harvest_height = ceil(_height / 2);
    
    for (var i = -_harvest_width; i <= _harvest_width; ++i)
    {
        var _x = _xstart + (i * TILE_SIZE);
        
        for (var j = -_harvest_height; j <= _harvest_height; ++j)
        {
            var _y = _ystart + (j * TILE_SIZE);
            
            draw_sprite_ext(spr_Harvest, _index_harvest, _x, _y, 1, 1, 0, c_white, 1);
        }
    }
    
    gpu_set_colorwriteenable(true, true, true, true);
    
    surface_reset_target();
    
    draw_surface(surface_harvest, (harvest_x * TILE_SIZE) - RENDER_HARVEST_PADDING - _xoffset, (harvest_y * TILE_SIZE) - RENDER_HARVEST_PADDING - _yoffset);
}