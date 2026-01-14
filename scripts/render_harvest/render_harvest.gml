#macro RENDER_HARVEST_OFFSET 2
#macro RENDER_HARVEST_PADDING 16

function render_harvest(_camera_x, _camera_y, _camera_width, _camera_height)
{
    var _lp = noone;
    with (obj_Player) { if (is_local) { _lp = id; break; } }
    if (_lp == noone) exit;
    
    var _keys = struct_get_names(_lp.harvest_progress);
    var _keys_length = array_length(_keys);
    if (_keys_length == 0) exit;

    static __index_max = sprite_get_number(spr_Harvest) - 1;
    var _item_data = global.item_data;

    for (var k = 0; k < _keys_length; k++)
    {
        var _key = _keys[k];
        var _parts = string_split(_key, "_");
        if (array_length(_parts) < 3) continue;
        
        var _tx = real(_parts[0]);
        var _ty = real(_parts[1]);
        var _tz = real(_parts[2]);
        var _timer_harvest = _lp.harvest_progress[$ _key];
        
        var _tile = tile_get(_tx, _ty, _tz);
        if (_tile == TILE_EMPTY) continue;
        
        var _data = _item_data[$ _tile.get_id()];
        var _sprite = global.sprite_asset[$ _data.get_sprite()];
        
        var _width  = ceil(_sprite.get_width()  / TILE_SIZE);
        var _height = ceil(_sprite.get_height() / TILE_SIZE);
        
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
        
        var _progress = normalize(_timer_harvest, 0, _data.get_tile_harvest().get_hardness());
        
        var _offset = RENDER_HARVEST_OFFSET * _progress;
        
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
        
        var _xoffset = _sprite.get_xoffset() * abs(_xscale);
        var _yoffset = _sprite.get_yoffset() * abs(_yscale);
        
        var _xstart = _xoffset - (TILE_SIZE / 2) + RENDER_HARVEST_PADDING + random_range(-_offset, _offset);
        var _ystart = _yoffset - (TILE_SIZE / 2) + RENDER_HARVEST_PADDING + random_range(-_offset, _offset);
        
        var _rotation = _tile.get_rotation();
        
        draw_sprite_ext(_sprite.get_sprite(), _index, _xstart + _xoffset, _ystart + _yoffset, _xscale, _yscale, _rotation, c_white, 1);
        
        gpu_set_colourwriteenable(true, true, true, false);
        
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
        
        gpu_set_colourwriteenable(true, true, true, true);
        
        surface_reset_target();
        
        draw_surface(surface_harvest, (_tx * TILE_SIZE) - RENDER_HARVEST_PADDING - _xoffset, (_ty * TILE_SIZE) - RENDER_HARVEST_PADDING - _yoffset);
    }
}