global.carbasa_page          = {}
global.carbasa_page_position = {}

#macro CARBASA_PAGE_INIT_SIZE 256
#macro CARBASA_PAGE_MAX_SIZE  4096

global.carbasa_surface         = {}
global.carbasa_surface_texture = {}
global.carbasa_surface_uv      = {}
global.carbasa_surface_size    = {}
global.carbasa_surface_buffer  = {}

function carbasa_sprite_add(_page, _sprite, _name)
{
    if (global.carbasa_page[$ _page] == undefined)
    {
        global.carbasa_page[$ _page] = {}
        global.carbasa_page_position[$ _page] = [];
        global.carbasa_surface_size[$ _page] = (CARBASA_PAGE_INIT_SIZE << 16) | CARBASA_PAGE_INIT_SIZE;
    }
    else if (global.carbasa_page[$ _page][$ _name] != undefined) exit;
    
    var _xoffset = sprite_get_xoffset(_sprite);
    var _yoffset = sprite_get_yoffset(_sprite);
    
    var _width  = sprite_get_width(_sprite);
    var _height = sprite_get_height(_sprite);
    var _number = sprite_get_number(_sprite);
    
    global.carbasa_page[$ _page][$ _name] = {
        sprite: [],
        xoffset: _xoffset,
        yoffset: _yoffset,
        width: _width,
        height: _height,
        number: _number
    }
    
    for (var i = 0; i < _number; ++i)
    {
        array_push(global.carbasa_page_position[$ _page], new CarbasaSprite(_page, _name, _sprite, array_length(global.carbasa_page_position[$ _page]), i, _number, _xoffset, _yoffset, _width, _height));
    }
    
    carbasa_sort(_page);
    
    var _surface = global.carbasa_surface[$ _page];
    
    var _surface_size = global.carbasa_surface_size[$ _page];
    
    var _surface_width  = (_surface_size >>  0) & 0xffff;
    var _surface_height = (_surface_size >> 16) & 0xffff;
    
    if (!surface_exists(_surface))
    {
        _surface = surface_create(_surface_width, _surface_height);
        
        global.carbasa_surface[$ _page] = _surface;
    }
    else if (surface_get_width(_surface) != _surface_width) || (surface_get_height(_surface) != _surface_height)
    {
        var _temp = surface_create(_surface_width, _surface_height);
        
        surface_set_target(_temp);
        
        draw_surface(_surface, 0, 0);
        
        surface_reset_target();
        
        surface_free(_surface);
        
        _surface = _temp;
        
        global.carbasa_surface[$ _page] = _surface;
    }
    
    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0);
    
    var _data = global.carbasa_page_position[$ _page];
    
    var _length = array_length(_data);
    
    for (var i = 0; i < _length; ++i)
    {
        var _ = _data[i];
        
        var _sprite2 = _.get_sprite();
        var _index   = _.get_index();
        
        var _x = _.get_x() + _.get_xoffset();
        var _y = _.get_y() + _.get_yoffset();
        
        draw_sprite(_sprite2, _index, _x, _y);
    }
    
    surface_reset_target();
    
    global.carbasa_surface_texture[$ _page] = surface_get_texture(_surface);
    global.carbasa_surface_uv[$ _page] = texture_get_uvs(global.carbasa_surface_texture[$ _page]); 
    
    if (!buffer_exists(global.carbasa_surface_buffer))
    {
        global.carbasa_surface_buffer[$ _page] = buffer_create(0xff, buffer_grow, 1);
    }
    
    buffer_get_surface(global.carbasa_surface_buffer[$ _page], global.carbasa_surface[$ _page], 0);
}
