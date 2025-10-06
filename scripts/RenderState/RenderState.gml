global.render_state = {}

global.render_state[$ "phantasia:blueprint/structure"] = function(_x, _y, _z)
{
    var _tile = tile_get(_x, _y, _z);
    
    var _xoffset = _tile.get_component("xoffset");
    var _yoffset = _tile.get_component("yoffset");
    
    var _xscale = _tile.get_component("xscale");
    var _yscale = _tile.get_component("yscale");
    
    var _x1 = ((_x + _xoffset) * TILE_SIZE) - (TILE_SIZE / 2);
    var _y1 = ((_y + _yoffset) * TILE_SIZE) - (TILE_SIZE / 2);
    
    var _x2 = ((_x + _xoffset + _xscale) * TILE_SIZE) - (TILE_SIZE / 2) - 1;
    var _y2 = ((_y + _yoffset + _yscale) * TILE_SIZE) - (TILE_SIZE / 2) - 1;
    
    draw_rectangle_colour(_x1, _y1, _x2, _y2, #EA4152, #F7C94A, #97FF87, #59DBFF, true);
    
    var _halign = draw_get_halign();
    var _valign = draw_get_valign();
    
    draw_set_align(fa_center, fa_middle);
    
    draw_circle_colour((_x + _xoffset) * TILE_SIZE, (_y + _yoffset) * TILE_SIZE, 2, #EA4152, #EA4152, false);
    render_text((_x + _xoffset) * TILE_SIZE, (_y + _yoffset - 1) * TILE_SIZE, $"({_x + _xoffset}, {_y + _yoffset})", 0.5, 0.5, 0, #EA4152);
    
    draw_circle_colour((_x + _xoffset + _xscale - 1) * TILE_SIZE, (_y + _yoffset + _yscale - 1) * TILE_SIZE, 2, #97FF87, #97FF87, false);
    render_text((_x + _xoffset + _xscale - 1) * TILE_SIZE, (_y + _yoffset + _yscale - 1 - 1) * TILE_SIZE, $"({_x + _xoffset + _xscale - 1}, {_y + _yoffset + _yscale - 1 - 1})", 0.5, 0.5, 0, #97FF87);
    
    draw_set_align(_halign, _valign);
}

global.render_state[$ "phantasia:blueprint/id"] = function(_x, _y, _z)
{
    var _tile = tile_get(_x, _y, _z);
    
    var _halign = draw_get_halign();
    var _valign = draw_get_valign();
    
    draw_set_align(fa_center, fa_middle);
    
    render_text(_x * TILE_SIZE, (_y - 1) * TILE_SIZE, _tile.get_component("id"), 0.5, 0.5);
    
    draw_set_align(_halign, _valign);
}