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

// --- Debug Info ---
render_text(10, 10, "Nodes: " + string(array_length(graph.nodes)), 0.5, 0.5);
// (Moved to Draw GUI)
// (Moved to Draw GUI)
