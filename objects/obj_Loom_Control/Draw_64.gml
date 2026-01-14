/// @desc Draw GUI - Render overlays (Spline, Color Picker)

// --- Color Picker Popup ---
if (color_picker_open)
{
    var _picker_w = 200;
    var _picker_h = 180;
    var _picker_x = display_get_gui_width() / 2 - _picker_w / 2;
    var _picker_y = display_get_gui_height() / 2 - _picker_h / 2;
    
    // Background
    draw_set_color(make_color_rgb(40, 40, 50));
    draw_rectangle(_picker_x, _picker_y, _picker_x + _picker_w, _picker_y + _picker_h, false);
    draw_set_color(c_white);
    draw_rectangle(_picker_x, _picker_y, _picker_x + _picker_w, _picker_y + _picker_h, true);
    
    // Title
    render_text(_picker_x + 10, _picker_y + 5, "Color Picker", 0.8, 0.8, 0, c_white, 1);
    
    // Hue slider
    render_text(_picker_x + 10, _picker_y + 30, "Hue", 0.6, 0.6, 0, c_ltgray, 1);
    for (var i = 0; i < _picker_w - 20; ++i)
    {
        draw_set_color(make_color_hsv((i / (_picker_w - 20)) * 255, 255, 255));
        draw_line(_picker_x + 10 + i, _picker_y + 42, _picker_x + 10 + i, _picker_y + 50);
    }
    draw_set_color(c_white);
    var _hue_x = _picker_x + 10 + color_picker_hue * (_picker_w - 20);
    draw_rectangle(_hue_x - 2, _picker_y + 40, _hue_x + 2, _picker_y + 52, true);
    
    // Saturation slider
    render_text(_picker_x + 10, _picker_y + 60, "Sat", 0.6, 0.6, 0, c_ltgray, 1);
    for (var i = 0; i < _picker_w - 20; ++i)
    {
        draw_set_color(make_color_hsv(color_picker_hue * 255, (i / (_picker_w - 20)) * 255, 255));
        draw_line(_picker_x + 10 + i, _picker_y + 72, _picker_x + 10 + i, _picker_y + 90);
    }
    draw_set_color(c_white);
    var _sat_x = _picker_x + 10 + color_picker_sat * (_picker_w - 20);
    draw_rectangle(_sat_x - 2, _picker_y + 70, _sat_x + 2, _picker_y + 92, true);
    
    // Value slider
    render_text(_picker_x + 10, _picker_y + 100, "Val", 0.6, 0.6, 0, c_ltgray, 1);
    for (var i = 0; i < _picker_w - 20; ++i)
    {
        draw_set_color(make_color_hsv(color_picker_hue * 255, color_picker_sat * 255, (i / (_picker_w - 20)) * 255));
        draw_line(_picker_x + 10 + i, _picker_y + 112, _picker_x + 10 + i, _picker_y + 130);
    }
    draw_set_color(c_white);
    var _val_x = _picker_x + 10 + color_picker_val * (_picker_w - 20);
    draw_rectangle(_val_x - 2, _picker_y + 110, _val_x + 2, _picker_y + 132, true);
    
    // Preview swatch
    var _preview_col = make_color_hsv(color_picker_hue * 255, color_picker_sat * 255, color_picker_val * 255);
    draw_set_color(_preview_col);
    draw_rectangle(_picker_x + 150, _picker_y + 60, _picker_x + 190, _picker_y + 100, false);
    draw_set_color(c_white);
    draw_rectangle(_picker_x + 150, _picker_y + 60, _picker_x + 190, _picker_y + 100, true);
    
    // OK button
    draw_set_color(make_color_rgb(50, 120, 50));
    draw_rectangle(_picker_x + 10, _picker_y + 145, _picker_x + 95, _picker_y + 170, false);
    draw_set_color(c_white);
    render_text(_picker_x + 40, _picker_y + 150, "OK", 0.8, 0.8, 0, c_white, 1);
    
    // Cancel button
    draw_set_color(make_color_rgb(120, 50, 50));
    draw_rectangle(_picker_x + 105, _picker_y + 145, _picker_x + 190, _picker_y + 170, false);
    draw_set_color(c_white);
    render_text(_picker_x + 125, _picker_y + 150, "Cancel", 0.8, 0.8, 0, c_white, 1);
}

// --- Spline Editor Overlay ---
if (spline_edit_active && spline_edit_node != undefined)
{
    var _sw = spline_edit_area_w;
    var _sh = spline_edit_area_h;
    var _sx = display_get_gui_width() / 2 - _sw / 2;
    var _sy = display_get_gui_height() / 2 - _sh / 2;
    spline_edit_area_x = _sx;
    spline_edit_area_y = _sy;
    
    // Dim background
    draw_set_alpha(0.5);
    draw_set_color(c_black);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1.0);
    
    // Editor Background
    draw_set_color(make_color_rgb(35, 35, 40));
    draw_rectangle(_sx, _sy, _sx + _sw, _sy + _sh, false);
    draw_set_color(c_white);
    draw_rectangle(_sx, _sy, _sx + _sw, _sy + _sh, true);
    
    // Title
    render_text(_sx + 10, _sy + 10, "Spline Editor: " + spline_edit_node.display_name, 1.0, 1.0, 0, c_white, 1);
    render_text(_sx + _sw - 80, _sy + 10, "[ESC] Close", 0.7, 0.7, 0, c_ltgray, 1);
    
    // Draw Grid
    draw_set_alpha(0.1);
    draw_set_color(c_white);
    for (var i = 0; i <= 10; ++i)
    {
        var _gx = _sx + (i/10)*_sw;
        var _gy = _sy + (i/10)*_sh;
        draw_line(_gx, _sy, _gx, _sy + _sh);
        draw_line(_sx, _gy, _sx + _sw, _gy);
    }
    draw_set_alpha(1.0);
    
    // Render Curve
    var _res = 100;
    var _points = spline_edit_node.points;
    draw_set_color(c_yellow);
    
    // Set scissor to prevent leaking outside the grid area
    gpu_set_scissor(_sx, _sy, _sw, _sh);
    
    for (var i = 0; i < _res; ++i)
    {
        var _t1 = i / _res;
        var _t2 = (i + 1) / _res;
        var _v1 = clamp(spline_evaluate(_points, _t1), 0, 1);
        var _v2 = clamp(spline_evaluate(_points, _t2), 0, 1);
        
        var _x1 = _sx + _t1 * _sw;
        var _y1 = _sy + _sh - (_v1 * _sh);
        var _x2 = _sx + _t2 * _sw;
        var _y2 = _sy + _sh - (_v2 * _sh);
        
        draw_line(_x1, _y1, _x2, _y2);
    }
    
    gpu_set_scissor(0, 0, display_get_gui_width(), display_get_gui_height());
    
    // Draw Points
    for (var i = 0; i < array_length(_points); ++i)
    {
        var _p = _points[i];
        var _px = _sx + _p.position * _sw;
        var _py = _sy + _sh - (_p.value * _sh);
        
        var _is_sel = (spline_edit_selected_point == i);
        draw_set_color(_is_sel ? c_aqua : c_white);
        draw_circle(_px, _py, 6, false);
        draw_set_color(c_black);
        draw_circle(_px, _py, 6, true);
        
        // Label easing if selected or just small label
        if (_is_sel)
        {
            render_text(_px + 8, _py - 12, _p.easing, 0.6, 0.6, 0, c_aqua, 1);
        }
    }
    
    // Min/Max Inputs (Bottom Left/Right)
    var _min = spline_edit_node.get_attribute("min_x");
    var _max = spline_edit_node.get_attribute("max_x");
    
    // Min box
    draw_set_color(make_color_rgb(50, 50, 60));
    draw_rectangle(_sx, _sy + _sh + 5, _sx + 100, _sy + _sh + 25, false);
    draw_set_color(c_white);
    draw_rectangle(_sx, _sy + _sh + 5, _sx + 100, _sy + _sh + 25, true);
    render_text(_sx + 5, _sy + _sh + 8, "Min: " + string(_min), 0.7, 0.7);
    
    // Max box
    draw_set_color(make_color_rgb(50, 50, 60));
    draw_rectangle(_sx + _sw - 100, _sy + _sh + 5, _sx + _sw, _sy + _sh + 25, false);
    draw_set_color(c_white);
    draw_rectangle(_sx + _sw - 100, _sy + _sh + 5, _sx + _sw, _sy + _sh + 25, true);
    render_text(_sx + _sw - 95, _sy + _sh + 8, "Max: " + string(_max), 0.7, 0.7);
    
    // Help text
    render_text(_sx + _sw/2, _sy + _sh + 10, "LMB: Add/Move  RMB: Easing  DEL: Delete", 0.6, 0.6, 0, c_ltgray, 1, true);
}

// --- Preview Window (Bottom Right) ---
var _pw = preview_width;
var _ph = preview_height;
var _px = display_get_gui_width() - _pw - 20;
var _py = display_get_gui_height() - _ph - 20;

if (preview_dirty)
{
    preview_current_col = 0;
    preview_dirty = false; 
}

if (!surface_exists(preview_surface) || surface_get_width(preview_surface) != _pw || surface_get_height(preview_surface) != _ph) 
{
    if (surface_exists(preview_surface)) surface_free(preview_surface);
    preview_surface = surface_create(_pw, _ph);
    preview_dirty = true;
    preview_current_col = 0;
}

if (preview_current_col < _pw)
{
    surface_set_target(preview_surface);
    if (preview_current_col == 0) draw_clear(c_black);
    
    // Evaluate for grid
    var _result_node = undefined;
    for (var i = 0; i < array_length(graph.nodes); ++i)
    {
        if (graph.nodes[i].type == "Result")
        {
            _result_node = graph.nodes[i];
            break;
        }
    }
    
    if (_result_node != undefined)
    {
        var _cols_to_render = 1;
        if (keyboard_check(vk_shift)) _cols_to_render = 16;
        
        var _count = 0;
        while (_count < _cols_to_render && preview_current_col < _pw)
        {
            var _ix = preview_current_col;
            var _start_y = 0;
            var _last_col = undefined;
            
            for (var _iy = 0; _iy < _ph; ++_iy)
            {
                var _ctx = { 
                    x: _ix * 1.0, 
                    y: _iy * 1.0 + preview_view_offset_y, 
                    z: 0, 
                    seed: 0, 
                    world_data: undefined 
                };
                graph.evaluate(_ctx);
                
                var _val = _result_node.get_input_value("value", _ctx);
                var _current_col = (is_real(_val) && _val > 0) ? c_white : c_black;
                
                if (_last_col == undefined) 
                {
                    _last_col = _current_col;
                    _start_y = _iy;
                }
                else if (_current_col != _last_col)
                {
                    if (_last_col != c_black)
                    {
                        draw_set_color(_last_col);
                        draw_line(_ix, _start_y, _ix, _iy - 1);
                    }
                    _last_col = _current_col;
                    _start_y = _iy;
                }
            }
            if (_last_col != undefined && _last_col != c_black)
            {
                draw_set_color(_last_col);
                draw_line(_ix, _start_y, _ix, _ph - 1);
            }
            preview_current_col++; 
            _count++;
        }
    }
    else { preview_current_col = _pw; }
    surface_reset_target();
}

// Draw Previews
draw_set_color(c_black);
draw_rectangle(_px - 2, _py - 2, _px + _pw + 2, _py + _ph + 2, false);
draw_set_color(c_white);
draw_rectangle(_px - 2, _py - 2, _px + _pw + 2, _py + _ph + 2, true);
if (surface_exists(preview_surface))
{
    draw_surface(preview_surface, _px, _py);
}
render_text(_px, _py - 20, "Density Preview (Y:" + string(preview_view_offset_y) + "-" + string(_ph + preview_view_offset_y) + ")", 0.5, 0.5);

// Biome Preview
var _bpw = biome_preview_width;
var _bph = biome_preview_height;
var _bpx = display_get_gui_width() - _bpw - 20;
var _bpy = _py - _bph - 30;

if (biome_preview_dirty)
{
    biome_preview_current_col = 0;
    biome_preview_dirty = false;
}

if (!surface_exists(biome_preview_surface) || surface_get_width(biome_preview_surface) != _bpw || surface_get_height(biome_preview_surface) != _bph)
{
    if (surface_exists(biome_preview_surface)) surface_free(biome_preview_surface);
    biome_preview_surface = surface_create(_bpw, _bph);
    biome_preview_dirty = true;
    biome_preview_current_col = 0;
}

if (biome_preview_current_col < _bpw)
{
    surface_set_target(biome_preview_surface);
    if (biome_preview_current_col == 0) draw_clear(c_black);
    
    var _biome_result_node = undefined;
    for (var i = 0; i < array_length(graph.nodes); ++i)
    {
        if (graph.nodes[i].type == "ResultBiome")
        {
            _biome_result_node = graph.nodes[i];
            break;
        }
    }
    
    if (_biome_result_node != undefined)
    {
        var _cols = (keyboard_check(vk_shift)) ? 16 : 4;
        repeat(_cols)
        {
            if (biome_preview_current_col >= _bpw) break;
            var _ix = biome_preview_current_col;
            var _start_y = 0;
            var _last_col = undefined;
            
            for (var _iy = 0; _iy < _bph; ++_iy)
            {
                var _ctx = { x: _ix * 4.0, y: _iy * 4.0, z: 0, seed: 0, world_data: undefined };
                graph.evaluate(_ctx);
                var _bid = _biome_result_node.get_input_value("biome_id", _ctx);
                var _current_col = c_black;
                if (_bid != "" && _bid != undefined && struct_exists(global.biome_data, _bid))
                {
                    _current_col = global.biome_data[$ _bid].get_map_colour() ?? c_black;
                }
                
                if (_last_col == undefined) 
                {
                    _last_col = _current_col;
                    _start_y = _iy;
                }
                else if (_current_col != _last_col)
                {
                    if (_last_col != c_black)
                    {
                        draw_set_color(_last_col);
                        draw_line(_ix, _start_y, _ix, _iy - 1);
                    }
                    _last_col = _current_col;
                    _start_y = _iy;
                }
            }
            if (_last_col != undefined && _last_col != c_black)
            {
                draw_set_color(_last_col);
                draw_line(_ix, _start_y, _ix, _bph - 1);
            }
            biome_preview_current_col++;
        }
    }
    else { biome_preview_current_col = _bpw; }
    surface_reset_target();
}

draw_set_color(c_black);
draw_rectangle(_bpx - 2, _bpy - 2, _bpx + _bpw + 2, _bpy + _bph + 2, false);
draw_set_color(c_white);
draw_rectangle(_bpx - 2, _bpy - 2, _bpx + _bpw + 2, _bpy + _bph + 2, true);
if (surface_exists(biome_preview_surface))
{
    draw_surface(biome_preview_surface, _bpx, _bpy);
}
render_text(_bpx, _bpy - 20, "Biome Preview (X * 4, Y * 4)", 0.5, 0.5);

// Handle
var _handle_size = 10;
draw_set_color(c_white);
draw_triangle(_px, _py, _px + _handle_size, _py, _px, _py + _handle_size, false);
