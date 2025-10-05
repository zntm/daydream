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
    
    var _x2 = ((_x + _xoffset + _xscale) * TILE_SIZE) - (TILE_SIZE / 2);
    var _y2 = ((_y + _yoffset + _yscale) * TILE_SIZE) - (TILE_SIZE / 2);
    
    draw_rectangle_colour(_x1, _y1, _x2, _y2, c_red, c_yellow, c_lime, c_aqua, true);
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