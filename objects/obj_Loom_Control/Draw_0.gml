/// @desc Loom editor draw

draw_clear(background_color);

// Apply view transformation
var _view_matrix = matrix_build(-view_x * view_scale, -view_y * view_scale, 0, 0, 0, 0, view_scale, view_scale, 1);
matrix_set(matrix_world, _view_matrix);

// --- Draw Grid ---
var _grid_start_x = floor(view_x / grid_size) * grid_size;
var _grid_start_y = floor(view_y / grid_size) * grid_size;
var _grid_end_x = view_x + (window_get_width() / view_scale);
var _grid_end_y = view_y + (window_get_height() / view_scale);

draw_set_color(grid_color);
draw_set_alpha(0.5);
for (var _gx = _grid_start_x; _gx < _grid_end_x; _gx += grid_size)
{
    draw_line(_gx, view_y, _gx, _grid_end_y);
}
for (var _gy = _grid_start_y; _gy < _grid_end_y; _gy += grid_size)
{
    draw_line(view_x, _gy, _grid_end_x, _gy);
}
draw_set_alpha(1);

// --- Draw Connections ---
draw_set_color(connection_color);
// Increase line width for better visibility? draw_line_width is not standard in GML but we use draw_line.
// Bezier curve drawing...
for (var i = 0; i < array_length(graph.connections); ++i)
{
    var _conn = graph.connections[i];
    var _from_pin = _conn.from_pin;
    var _to_pin = _conn.to_pin;
    
    // Find positions
    var _from_x = 0, _from_y = 0, _to_x = 0, _to_y = 0;
    
    // This lookup is inefficient but fine for editor
    for (var j = 0; j < array_length(graph.nodes); ++j)
    {
        var _node = graph.nodes[j];
        var _out_names = struct_get_names(_node.outputs);
        for (var k = 0; k < array_length(_out_names); ++k)
        {
            if (_node.outputs[$ _out_names[k]] == _from_pin)
            {
                var _idx = -1; // Find index in order for Y pos
                for(var m=0; m<array_length(_node.output_order); ++m) if(_node.output_order[m] == _out_names[k]) { _idx = m; break; }
                if(_idx != -1) {
                    _from_x = _node.x + _node.width;
                    _from_y = _node.y + 30 + _idx * 20;
                }
            }
        }
        var _in_names = struct_get_names(_node.inputs);
        for (var k = 0; k < array_length(_in_names); ++k)
        {
            if (_node.inputs[$ _in_names[k]] == _to_pin)
            {
                var _idx = -1;
                for(var m=0; m<array_length(_node.input_order); ++m) if(_node.input_order[m] == _in_names[k]) { _idx = m; break; }
                if(_idx != -1) {
                    _to_x = _node.x;
                    _to_y = _node.y + 30 + _idx * 20;
                }
            }
        }
    }
    
    // Draw Bezier
    var _mid_x = (_from_x + _to_x) / 2;
    var _steps = 20;
    var _px = _from_x, _py = _from_y;
    for (var t = 0; t <= _steps; ++t)
    {
        var _t = t / _steps;
        var _inv_t = 1 - _t;
        var _ctrl_x1 = _from_x + 50;
        var _ctrl_x2 = _to_x - 50;
        
        var _nx = _inv_t*_inv_t*_inv_t*_from_x + 3*_inv_t*_inv_t*_t*_ctrl_x1 + 3*_inv_t*_t*_t*_ctrl_x2 + _t*_t*_t*_to_x;
        var _ny = _inv_t*_inv_t*_inv_t*_from_y + 3*_inv_t*_inv_t*_t*_from_y + 3*_inv_t*_t*_t*_to_y + _t*_t*_t*_to_y;
        
        if (t > 0) draw_line(_px, _py, _nx, _ny);
        _px = _nx;
        _py = _ny;
    }
}

// --- Draw Active Connection ---
if (connecting_from_pin != undefined)
{
    var _from_x = 0, _from_y = 0;
    // Find source pos
    var _node = connecting_from_node;
    for (var k = 0; k < array_length(_node.output_order); ++k)
    {
        if (_node.outputs[$ _node.output_order[k]] == connecting_from_pin)
        {
            _from_x = _node.x + _node.width;
            _from_y = _node.y + 30 + k * 20;
            break;
        }
    }
    
    var _to_x = (mouse_x / view_scale) + view_x;
    var _to_y = (mouse_y / view_scale) + view_y;
    
    draw_line(_from_x, _from_y, _to_x, _to_y);
}

// --- Draw Nodes ---
for (var i = 0; i < array_length(graph.nodes); ++i)
{
    var _node = graph.nodes[i];
    var _is_selected = false;
    for(var k=0; k<array_length(selected_nodes); ++k) { if(selected_nodes[k] == _node) { _is_selected = true; break; } }
    
    // Node body
    draw_set_color(_is_selected ? node_selected_color : node_body_color);
    draw_roundrect(_node.x, _node.y, _node.x + _node.width, _node.y + _node.height, false);
    
    // Selection outline
    if (_is_selected)
    {
        draw_set_color(c_white);
        draw_roundrect(_node.x - 2, _node.y - 2, _node.x + _node.width + 2, _node.y + _node.height + 2, true);
    }
    
    // Node header
    draw_set_color(node_header_color);
    draw_roundrect(_node.x, _node.y, _node.x + _node.width, _node.y + 24, false);
    
    // Constant Value Display
    if (_node.type == "Constant")
    {
        draw_set_halign(fa_center);
        
        if (editing_constant_node == _node)
        {
            var _cursor = (current_time % 500 < 250) ? "|" : "";
            render_text(_node.x + _node.width/2, _node.y + 35, editing_constant_text + _cursor, 0.7, 0.7, 0, c_yellow, 1);
        }
        else
        {
            render_text(_node.x + _node.width/2, _node.y + 35, string(_node.constant_value), 0.7, 0.7, 0, c_white, 1);
        }
        draw_set_halign(fa_left);
    }
    
    // Node Title (Using render_text)
    draw_set_halign(fa_center);
    render_text(_node.x + _node.width/2, _node.y + 4, _node.display_name, 0.8, 0.8, 0, c_white, 1); // Scaled text (doubled)
    draw_set_halign(fa_left);
    
    // Pins
    var _text_scale = 0.7; // Doubled from 0.35
    
    // Outputs
    for (var j = 0; j < array_length(_node.output_order); ++j)
    {
        var _pin_name = _node.output_order[j];
        var _pin = _node.outputs[$ _pin_name];
        var _pin_x = _node.x + _node.width;
        var _pin_y = _node.y + 30 + j * 20;
        
        // Debug Hitbox
        if (IS_DEVELOPER_MODE)
        {
            draw_set_color(c_red);
            draw_rectangle(_pin_x - 12, _pin_y - 12, _pin_x + 12, _pin_y + 12, true);
        }
        
        switch (_pin.type) {
            case "value": draw_set_color(pin_color_value); break;
            case "bool": draw_set_color(pin_color_bool); break;
            case "struct": draw_set_color(pin_color_struct); break;
            case "color": draw_set_color(pin_color_color); break;
            case "string": draw_set_color(pin_color_string); break;
            case "spline": draw_set_color(pin_color_spline); break;
            default: draw_set_color(pin_color_any); break;
        }
        draw_circle(_pin_x, _pin_y, 4, false);
        
        draw_set_halign(fa_right);
        render_text(_pin_x - 8, _pin_y - 8, _pin_name, _text_scale, _text_scale, 0, c_white, 1);
    }
    
    // Inputs
    for (var j = 0; j < array_length(_node.input_order); ++j)
    {
        var _pin_name = _node.input_order[j];
        var _pin = _node.inputs[$ _pin_name];
        var _pin_x = _node.x;
        var _pin_y = _node.y + 30 + j * 20;
        
        // Debug Hitbox
        if (IS_DEVELOPER_MODE)
        {
            draw_set_color(c_red);
            draw_rectangle(_pin_x - 12, _pin_y - 12, _pin_x + 12, _pin_y + 12, true);
        }
        
        switch (_pin.type) {
            case "value": draw_set_color(pin_color_value); break;
            case "bool": draw_set_color(pin_color_bool); break;
            case "struct": draw_set_color(pin_color_struct); break;
            case "color": draw_set_color(pin_color_color); break;
            case "string": draw_set_color(pin_color_string); break;
            case "spline": draw_set_color(pin_color_spline); break;
            default: draw_set_color(pin_color_any); break;
        }
        
        draw_circle(_pin_x, _pin_y, 4, _pin.is_connected() ? false : true);
        
        draw_set_halign(fa_left);
        render_text(_pin_x + 8, _pin_y - 8, _pin_name, _text_scale, _text_scale, 0, c_white, 1);
    }
    
    // Attributes (inline editable values)
    var _attr_start_y = _node.y + 30 + max(array_length(_node.input_order), array_length(_node.output_order)) * 20;
    for (var j = 0; j < array_length(_node.attribute_order); ++j)
    {
        var _attr_name = _node.attribute_order[j];
        var _attr = _node.attributes[$ _attr_name];
        var _attr_y = _attr_start_y + j * 24;
        var _attr_x = _node.x + 8;
        var _attr_w = _node.width - 16;
        
        // Draw attribute label
        draw_set_halign(fa_left);
        render_text(_attr_x, _attr_y, _attr_name + ":", _text_scale, _text_scale, 0, c_ltgray, 1);
        
        // Draw value based on type
        var _val_x = _attr_x + 50;
        switch (_attr.type)
        {
            case "color":
                // Color swatch
                var _col = _attr.value ?? c_white;
                draw_set_color(_col);
                draw_rectangle(_val_x, _attr_y, _val_x + 40, _attr_y + 16, false);
                draw_set_color(c_white);
                draw_rectangle(_val_x, _attr_y, _val_x + 40, _attr_y + 16, true);
                break;
                
            case "string":
                // String display
                var _str = string(_attr.value ?? "");
                var _active = (editing_attr_node == _node && editing_attr_name == _attr_name);
                if (_active) _str = editing_attr_text + ((current_time % 1000 < 500) ? "|" : "");
                render_text(_val_x, _attr_y, _str, _text_scale, _text_scale, 0, _active ? c_white : pin_color_string, 1);
                break;
                
            case "bool":
                // Checkbox-style toggle
                draw_set_color(_attr.value ? c_lime : c_gray);
                draw_rectangle(_val_x, _attr_y + 2, _val_x + 12, _attr_y + 14, !_attr.value);
                break;
                
            default: // "value" - numeric
                var _val = is_real(_attr.value) ? string_format(_attr.value, 1, 3) : string(_attr.value ?? "0");
                var _active = (editing_attr_node == _node && editing_attr_name == _attr_name);
                if (_active) _val = editing_attr_text + ((current_time % 1000 < 500) ? "|" : "");
                render_text(_val_x, _attr_y, _val, _text_scale, _text_scale, 0, _active ? c_white : pin_color_value, 1);
                break;
        }
    }
}

// --- Draw Selection Box ---
if (selection_box_active)
{
    draw_set_color(c_white);
    draw_set_alpha(0.2);
    var _mx = (mouse_x / view_scale) + view_x;
    var _my = (mouse_y / view_scale) + view_y;
    draw_rectangle(selection_box_start_x, selection_box_start_y, _mx, _my, false);
    draw_set_alpha(1);
    draw_rectangle(selection_box_start_x, selection_box_start_y, _mx, _my, true);
}

// Reset Matrix
matrix_set(matrix_world, matrix_build_identity());

// --- Draw Context Menu (Screen Space) ---
if (context_menu_open)
{
    var _menu_x = context_menu_x;
    var _menu_y = context_menu_y;
    var _cat_names = struct_get_names(node_categories);
    var _item_h = 24;
    var _menu_h = array_length(_cat_names) * _item_h;
    
    // Draw Categories
    draw_set_color(node_body_color);
    draw_rectangle(_menu_x, _menu_y, _menu_x + context_menu_width, _menu_y + _menu_h, false);
    draw_set_color(c_white);
    draw_rectangle(_menu_x, _menu_y, _menu_x + context_menu_width, _menu_y + _menu_h, true);
    
    for (var i = 0; i < array_length(_cat_names); ++i)
    {
        var _cy = _menu_y + i * _item_h;
        var _cat = _cat_names[i];
        
        if (point_in_rectangle(mouse_x, mouse_y, _menu_x, _cy, _menu_x + context_menu_width, _cy + _item_h) || context_menu_active_category == _cat)
        {
            draw_set_color(node_header_color);
            draw_rectangle(_menu_x, _cy, _menu_x + context_menu_width, _cy + _item_h, false);
            draw_set_color(c_white);
            
            // Open submenu on hover/click (handled in step, but we define active cat there)
            if (context_menu_active_category == undefined) context_menu_active_category = _cat; 
        }
        
        draw_set_halign(fa_left);
        render_text(_menu_x + 8, _cy + 4, _cat, 0.8, 0.8, 0, c_white, 1);
        render_text(_menu_x + context_menu_width - 20, _cy + 4, ">", 0.8, 0.8);
    }
    
    // Draw Submenu
    if (context_menu_active_category != undefined)
    {
        var _items = node_categories[$ context_menu_active_category];
        var _sub_x = _menu_x + context_menu_width;
        
        // Align to category
        var _cat_idx = 0;
        for(var k=0; k<array_length(_cat_names); ++k) { if(_cat_names[k] == context_menu_active_category) { _cat_idx = k; break; } }
        var _sub_y = _menu_y + _cat_idx * _item_h;
        
        var _sub_h = array_length(_items) * _item_h;
        
        draw_set_color(node_body_color);
        draw_rectangle(_sub_x, _sub_y, _sub_x + context_menu_width, _sub_y + _sub_h, false);
        draw_set_color(c_white);
        draw_rectangle(_sub_x, _sub_y, _sub_x + context_menu_width, _sub_y + _sub_h, true);
        
        for (var j = 0; j < array_length(_items); ++j)
        {
            var _sy = _sub_y + j * _item_h;
            if (point_in_rectangle(mouse_x, mouse_y, _sub_x, _sy, _sub_x + context_menu_width, _sy + _item_h))
            {
                draw_set_color(node_header_color);
                draw_rectangle(_sub_x, _sy, _sub_x + context_menu_width, _sy + _item_h, false);
                draw_set_color(c_white);
            }
            render_text(_sub_x + 8, _sy + 4, _items[j], 0.8, 0.8, 0, c_white, 1);
        }
    }
}

// --- Preview Window (Bottom Right) ---
var _pw = preview_width;
var _ph = preview_height;
var _px = window_get_width() - _pw - 20;
var _py = window_get_height() - _ph - 20;

// Update Preview Surface
// Update Preview Surface
// Update Preview Surface
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
        var _cols_to_render = 1; // Locked to 1 for smoothness as requested
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
                    // Draw span
                    if (_last_col != c_black) // Optimization: don't draw black over black surface
                    {
                        draw_set_color(_last_col);
                        draw_line(_ix, _start_y, _ix, _iy - 1);
                    }
                    _last_col = _current_col;
                    _start_y = _iy;
                }
            }
            
            // Draw final span
            if (_last_col != undefined && _last_col != c_black)
            {
                draw_set_color(_last_col);
                draw_line(_ix, _start_y, _ix, _ph - 1);
            }
            
            preview_current_col++; 
            _count++;
        }
    }
    else
    {
        // No result node, just finish
        preview_current_col = _pw; 
    }
    
    surface_reset_target();
}

// Draw Preview
draw_set_color(c_black);
draw_rectangle(_px - 2, _py - 2, _px + _pw + 2, _py + _ph + 2, false);
draw_set_color(c_white);
draw_rectangle(_px - 2, _py - 2, _px + _pw + 2, _py + _ph + 2, true);
if (surface_exists(preview_surface))
{
    draw_surface(preview_surface, _px, _py);
}

// Label using persistent variable to avoid crash
var _y_start = preview_view_offset_y;
var _y_end = _ph + preview_view_offset_y;
render_text(_px, _py - 20, "Density Preview (Y:" + string(_y_start) + "-" + string(_y_end) + ")", 0.5, 0.5);

// --- Biome Preview Window (Above Density Preview) ---
var _bpw = biome_preview_width;
var _bph = biome_preview_height;
var _bpx = window_get_width() - _bpw - 20;
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
                    // Draw span
                    if (_last_col != c_black)
                    {
                        draw_set_color(_last_col);
                        draw_line(_ix, _start_y, _ix, _iy - 1);
                    }
                    _last_col = _current_col;
                    _start_y = _iy;
                }
            }
            
            // Draw final span
            if (_last_col != undefined && _last_col != c_black)
            {
                draw_set_color(_last_col);
                draw_line(_ix, _start_y, _ix, _bph - 1);
            }
            
            biome_preview_current_col++;
        }
    }
    else
    {
        // No node found, stop trying to render
        biome_preview_current_col = _bpw;
    }
    surface_reset_target();
}

// Draw Biome Preview
draw_set_color(c_black);
draw_rectangle(_bpx - 2, _bpy - 2, _bpx + _bpw + 2, _bpy + _bph + 2, false);
draw_set_color(c_white);
draw_rectangle(_bpx - 2, _bpy - 2, _bpx + _bpw + 2, _bpy + _bph + 2, true);
if (surface_exists(biome_preview_surface))
{
    draw_surface(biome_preview_surface, _bpx, _bpy);
}
render_text(_bpx, _bpy - 20, "Biome Preview (X * 4, Y * 4)", 0.5, 0.5);

// --- Draw Resize Handle ---
var _handle_size = 10;
draw_set_color(c_white);
draw_triangle(_px, _py, _px + _handle_size, _py, _px, _py + _handle_size, false);

// --- Debug Info ---
render_text(10, 10, "Nodes: " + string(array_length(graph.nodes)), 0.5, 0.5);

// --- Color Picker Popup ---
if (color_picker_open)
{
    var _picker_w = 200;
    var _picker_h = 180;
    var _picker_x = window_get_width() / 2 - _picker_w / 2;
    var _picker_y = window_get_height() / 2 - _picker_h / 2;
    
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
