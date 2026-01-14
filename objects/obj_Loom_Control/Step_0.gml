/// @desc Loom editor step - handle input

var _mx = mouse_x;
var _my = mouse_y;
var _ctrl = keyboard_check(vk_control);
var _shift = keyboard_check(vk_shift);

// Transform mouse to graph space
var _graph_mx = (_mx / view_scale) + view_x;
var _graph_my = (_my / view_scale) + view_y;

// --- Spline Editor Interaction ---
if (spline_edit_active && spline_edit_node != undefined)
{
    var _gx = device_mouse_x_to_gui(0);
    var _gy = device_mouse_y_to_gui(0);
    var _sx = spline_edit_area_x;
    var _sy = spline_edit_area_y;
    var _sw = spline_edit_area_w;
    var _sh = spline_edit_area_h;
    
    // Normalize mouse to 0-1 within editor area
    var _nmx = clamp((_gx - _sx) / _sw, 0, 1);
    var _nmy = clamp(1.0 - ((_gy - _sy) / _sh), 0, 1);
    
    if (keyboard_check_pressed(vk_escape))
    {
        spline_edit_active = false;
        spline_edit_node = undefined;
        return;
    }
    
    var _points = spline_edit_node.points;
    
    // Check points hover
    var _hover_idx = -1;
    for (var i = 0; i < array_length(_points); ++i)
    {
        var _p = _points[i];
        var _px = _sx + _p.position * _sw;
        var _py = _sy + _sh - (_p.value * _sh);
        if (point_distance(_gx, _gy, _px, _py) < 10)
        {
            _hover_idx = i;
            break;
        }
    }
    
    // Left Click: Select/Drag or Add
    if (mouse_check_button_pressed(mb_left))
    {
        // Check Min/Max boxes
        if (point_in_rectangle(_gx, _gy, _sx, _sy + _sh + 5, _sx + 100, _sy + _sh + 25))
        {
            editing_attr_node = spline_edit_node;
            editing_attr_name = "min_x";
            editing_attr_text = string(spline_edit_node.get_attribute("min_x"));
            keyboard_string = "";
            return;
        }
        if (point_in_rectangle(_gx, _gy, _sx + _sw - 100, _sy + _sh + 5, _sx + _sw, _sy + _sh + 25))
        {
            editing_attr_node = spline_edit_node;
            editing_attr_name = "max_x";
            editing_attr_text = string(spline_edit_node.get_attribute("max_x"));
            keyboard_string = "";
            return;
        }

        if (_hover_idx != -1)
        {
            spline_edit_selected_point = _hover_idx;
        }
        else if (point_in_rectangle(_gx, _gy, _sx, _sy, _sx + _sw, _sy + _sh))
        {
            // Add point
            var _new_p = { position: _nmx, value: _nmy, easing: "linear" };
            array_push(_points, _new_p);
            // Sort points by position
            array_sort(_points, function(_a, _b) { 
                if (_a.position < _b.position) return -1;
                if (_a.position > _b.position) return 1;
                return 0;
            });
            // Find new index
            for(var k=0; k<array_length(_points); ++k) { if (_points[k] == _new_p) { spline_edit_selected_point = k; break; } }
            loom_trigger_refresh(spline_edit_node);
        }
        else
        {
            spline_edit_selected_point = -1;
        }
    }
    
    // Drag selected point
    if (mouse_check_button(mb_left) && spline_edit_selected_point != -1)
    {
        var _p = _points[spline_edit_selected_point];
        _p.position = clamp(_nmx, 0, 1);
        _p.value = clamp(_nmy, 0, 1);
        loom_trigger_refresh(spline_edit_node);
    }
    
    if (mouse_check_button_released(mb_left))
    {
        array_sort(_points, function(_a, _b) { 
            if (_a.position < _b.position) return -1;
            if (_a.position > _b.position) return 1;
            return 0;
        });
        spline_edit_selected_point = -1; 
        loom_trigger_refresh(spline_edit_node);
    }
    
    // Right Click: Easing Context Menu
    if (mouse_check_button_pressed(mb_right) && _hover_idx != -1)
    {
        spline_edit_selected_point = _hover_idx;
        var _p = _points[_hover_idx];
        // Cycle easing for now
        var _easings = ["linear", "ease_in", "ease_out", "ease_in_out", "ease_in_cubic", "ease_out_cubic", "ease_in_out_cubic", "step"];
        var _curr = 0;
        for(var k=0; k<array_length(_easings); ++k) { if (_easings[k] == _p.easing) { _curr = k; break; } }
        _p.easing = _easings[(_curr + 1) % array_length(_easings)];
        loom_trigger_refresh(spline_edit_node);
    }
    
    // Delete Point
    if (keyboard_check_pressed(vk_delete) && spline_edit_selected_point != -1)
    {
        if (array_length(_points) > 2) // Keep at least 2 points
        {
            array_delete(_points, spline_edit_selected_point, 1);
            spline_edit_selected_point = -1;
            loom_trigger_refresh(spline_edit_node);
        }
    }
    
    // Block other input if clicking within or near editor
    if (mouse_check_button_pressed(mb_left) || mouse_check_button_pressed(mb_right)) return;
    return; 
}

// --- Text Editing for Constant Nodes ---
if (editing_constant_node != undefined)
{
    if (keyboard_check_pressed(vk_escape))
    {
        editing_constant_node = undefined;
        keyboard_string = "";
    }
    else if (keyboard_check_pressed(vk_enter))
    {
        // Try parse
        try {
            var _val = real(editing_constant_text);
            editing_constant_node.constant_value = _val;
            loom_trigger_refresh(editing_constant_node);
        } catch(_e) {
            // Invalid number, just ignore or revert
        }
        editing_constant_node = undefined;
        keyboard_string = "";
    }
    else
    {
        // Handle text input
        if (keyboard_check_pressed(vk_backspace))
        {
            editing_constant_text = string_copy(editing_constant_text, 1, string_length(editing_constant_text) - 1);
        }
        else if (keyboard_string != "")
        {
            // Filter only allowed characters (0-9, ., -)
            var _char = string_char_at(keyboard_string, string_length(keyboard_string));
            if (string_digits(_char) != "" || _char == "." || _char == "-")
            {
                editing_constant_text += _char;
            }
            keyboard_string = "";
        }
    }
    
    return; // Block other interaction
}

// --- Attribute Text Editing ---
if (editing_attr_node != undefined)
{
    if (keyboard_check_pressed(vk_escape))
    {
        editing_attr_node = undefined;
        keyboard_string = "";
    }
    else if (keyboard_check_pressed(vk_enter))
    {
        var _attr = editing_attr_node.attributes[$ editing_attr_name];
        if (_attr != undefined)
        {
            if (_attr.type == "value")
            {
                try {
                    _attr.value = real(editing_attr_text);
                } catch(_e) {}
            }
            else
            {
                _attr.value = editing_attr_text;
            }
            loom_trigger_refresh(editing_attr_node);
        }
        editing_attr_node = undefined;
        keyboard_string = "";
    }
    else
    {
        if (keyboard_check_pressed(vk_backspace))
        {
            editing_attr_text = string_copy(editing_attr_text, 1, string_length(editing_attr_text) - 1);
        }
        else if (keyboard_string != "")
        {
            var _attr = editing_attr_node.attributes[$ editing_attr_name];
            var _char = string_char_at(keyboard_string, string_length(keyboard_string));
            
            if (_attr.type == "value")
            {
                if (string_digits(_char) != "" || _char == "." || _char == "-")
                {
                    editing_attr_text += _char;
                }
            }
            else
            {
                editing_attr_text += _char;
            }
            keyboard_string = "";
        }
    }
    return;
}

// --- Color Picker ---
if (color_picker_open)
{
    var _gx = device_mouse_x_to_gui(0);
    var _gy = device_mouse_y_to_gui(0);
    var _picker_w = 200;
    var _picker_h = 180;
    var _picker_x = display_get_gui_width() / 2 - _picker_w / 2;
    var _picker_y = display_get_gui_height() / 2 - _picker_h / 2;
    
    // Handle HSV sliders
    if (mouse_check_button(mb_left))
    {
        if (point_in_rectangle(_gx, _gy, _picker_x + 10, _picker_y + 30, _picker_x + _picker_w - 10, _picker_y + 50))
        {
            color_picker_hue = clamp((_gx - (_picker_x + 10)) / (_picker_w - 20), 0, 1);
        }
        if (point_in_rectangle(_gx, _gy, _picker_x + 10, _picker_y + 70, _picker_x + _picker_w - 10, _picker_y + 90))
        {
            color_picker_sat = clamp((_gx - (_picker_x + 10)) / (_picker_w - 20), 0, 1);
        }
        if (point_in_rectangle(_gx, _gy, _picker_x + 10, _picker_y + 110, _picker_x + _picker_w - 10, _picker_y + 130))
        {
            color_picker_val = clamp((_gx - (_picker_x + 10)) / (_picker_w - 20), 0, 1);
        }
    }
    
    // OK button
    if (mouse_check_button_pressed(mb_left))
    {
        if (point_in_rectangle(_gx, _gy, _picker_x + 10, _picker_y + 145, _picker_x + 95, _picker_y + 170))
        {
            var _col = make_color_hsv(color_picker_hue * 255, color_picker_sat * 255, color_picker_val * 255);
            if (color_picker_node != undefined)
            {
                color_picker_node.set_attribute(color_picker_attr, _col);
                loom_trigger_refresh(color_picker_node);
            }
            color_picker_open = false;
        }
        // Cancel button
        if (point_in_rectangle(_gx, _gy, _picker_x + 105, _picker_y + 145, _picker_x + 190, _picker_y + 170))
        {
            color_picker_open = false;
        }
    }
    
    if (keyboard_check_pressed(vk_escape))
    {
        color_picker_open = false;
    }
    return;
}

if (context_menu_open)
{
    var _cat_names = struct_get_names(node_categories);
    var _menu_x = context_menu_x;
    var _menu_y = context_menu_y;
    var _item_h = 24;
    
    // Check Categories Hover
    for (var i = 0; i < array_length(_cat_names); ++i)
    {
        if (point_in_rectangle(_mx, _my, _menu_x, _menu_y + i*_item_h, _menu_x + context_menu_width, _menu_y + (i+1)*_item_h))
        {
            context_menu_active_category = _cat_names[i];
            break;
        }
    }
    
    // Check Click
    if (mouse_check_button_pressed(mb_left))
    {
        // Check Items in Active Category or Top Level Items (like Disconnect/Delete for node menu)
        
        // Is this a regular menu or node menu?
        // Reuse the same structure? Or distinct?
        // Let's check active category items first
        if (context_menu_active_category != undefined)
        {
            var _items = node_categories[$ context_menu_active_category];
            // ... (rest of item click logic)
            if (_items != undefined) {
                 var _sub_x = _menu_x + context_menu_width;
                 var _cat_idx = 0;
                 for(var k=0; k<array_length(_cat_names); ++k) { if (_cat_names[k] == context_menu_active_category) { _cat_idx = k; break; } }
                 var _sub_y = _menu_y + _cat_idx * _item_h;
                
                for (var j = 0; j < array_length(_items); ++j)
                {
                    if (point_in_rectangle(_mx, _my, _sub_x, _sub_y + j*_item_h, _sub_x + context_menu_width, _sub_y + (j+1)*_item_h))
                    {
                        var _type = _items[j];
                        var _new_node = loom_create_node(_type);
                        if (_new_node != undefined)
                        {
                            _new_node.set_position(_graph_mx, _graph_my);
                            graph.add_node(_new_node);
                        }
                        context_menu_open = false;
                        return;
                    }
                }
            }
        }
        
        // Node Context Menu Logic (if categories are not standard)
        // If we are showing "Node Options", check clicks there
        if (context_menu_active_category == "Node Options")
        {
             // handled below by reusing the active category logic if we add "Node Options" to categories dynamically
             // But simpler: Handle click on top-level items if they exist
        }
        
        // Click outside closes menu
        context_menu_open = false;
    }
    
    return; // Block other input
}

// --- Preview Resizing ---
var _gx = device_mouse_x_to_gui(0);
var _gy = device_mouse_y_to_gui(0);
var _pw = preview_width;
var _ph = preview_height;
var _px = display_get_gui_width() - _pw - 20;
var _py = display_get_gui_height() - _ph - 20; // Anchor Bottom Right

if (mouse_check_button_pressed(mb_left))
{
    // Handle at Top-Left of preview box
    if (point_distance(_gx, _gy, _px, _py) < 15)
    {
        preview_resizing = true;
        return; // Block selection box
    }
}

if (preview_resizing)
{
    if (mouse_check_button(mb_left))
    {
        var _new_w = max(64, display_get_gui_width() - _gx - 20);
        var _new_h = max(64, display_get_gui_height() - _gy - 20);
        
        preview_width = _new_w;
        preview_height = _new_h;
        preview_dirty = true;
        biome_preview_dirty = true;
    }
    else
    {
        preview_resizing = false;
    }
    return; // Block other input
}

// --- Middle-click: Pan view ---
if (mouse_check_button(mb_middle) || (keyboard_check(vk_space) && mouse_check_button(mb_left)))
{
    view_x -= (mouse_x - mouse_last_x) / view_scale;
    view_y -= (mouse_y - mouse_last_y) / view_scale;
}

// --- Scroll: Zoom or Edit Constant ---
var _scroll = mouse_wheel_down() - mouse_wheel_up();
if (_scroll != 0)
{
    // Check if hovering a Constant node
    var _hover_node = graph.get_node_at(_graph_mx, _graph_my);
    var _handled = false;
    
    if (_hover_node != undefined)
    {
        if (_hover_node.type == "Constant")
        {
            var _delta = _scroll * (_shift ? 0.01 : 0.1);
            _hover_node.constant_value -= _delta;
            loom_trigger_refresh(_hover_node);
            _handled = true;
        }
        else
        {
            // Check if hovering any numeric attribute
            var _attr_start_y = _hover_node.y + 30 + max(array_length(_hover_node.input_order), array_length(_hover_node.output_order)) * 20;
            for (var i = 0; i < array_length(_hover_node.attribute_order); ++i)
            {
                var _attr_name = _hover_node.attribute_order[i];
                var _attr = _hover_node.attributes[$ _attr_name];
                var _attr_y = _attr_start_y + i * 24;
                
                if (_graph_my >= _attr_y && _graph_my < _attr_y + 20 && _attr.type == "value")
                {
                    var _delta = _scroll * (_shift ? 0.01 : (_ctrl ? 10 : 1));
                    _attr.value -= _delta;
                    loom_trigger_refresh(_hover_node);
                    _handled = true;
                    break;
                }
            }
        }
    }
    
    if (!_handled)
    {
        var _old_scale = view_scale;
        view_scale = clamp(view_scale - _scroll * 0.1, 0.25, 2.0);
        
        // Zoom towards mouse position
        var _scale_change = view_scale / _old_scale;
        view_x += (_graph_mx - view_x) * (1 - 1/_scale_change);
        view_y += (_graph_my - view_y) * (1 - 1/_scale_change);
    }
}

// --- Right-click: Context Menu ---
if (mouse_check_button_pressed(mb_right))
{
    var _clicked_node = graph.get_node_at(_graph_mx, _graph_my);
    
    if (_clicked_node != undefined)
    {
        // If node clicked, show Node Context Menu
        // We can use the same menu system but temporarily swap categories or handling
        // For now, let's just do immediate actions if right-clicking node?
        // User asked for "Detach connections by right clicking a node".
        // Let's make right-clicking a node disconnect all pins.
        
        // Wait, context menu is better.
        // Let's implement a simple immediate "Disconnect All" if user holds Shift? 
        // Or better: Just check if we clicked a pin first (handled below).
        // If we clicked the BODY, open a specific menu.
        
        var _pin_clicked = false;
        var _pin_radius = 12; // Increased radius
        
        // Check pins... (existing logic)
        // Check inputs
        for (var i = 0; i < array_length(_clicked_node.input_order); ++i)
        {
            var _pin_name = _clicked_node.input_order[i];
            var _pin_x = _clicked_node.x;
            var _pin_y = _clicked_node.y + 30 + i * 20;
            
            if (point_distance(_graph_mx, _graph_my, _pin_x, _pin_y) <= _pin_radius)
            {
                var _pin = _clicked_node.inputs[$ _pin_name];
                if (_pin.is_connected())
                {
                    graph.disconnect_pin(_pin);
                    loom_trigger_refresh(_clicked_node);
                    _pin_clicked = true;
                }
                break;
            }
        }
        
        // Check outputs (start new connection or nothing?)
         for (var i = 0; i < array_length(_clicked_node.output_order); ++i)
        {
            var _pin_x = _clicked_node.x + _clicked_node.width;
            var _pin_y = _clicked_node.y + 30 + i * 20;
             if (point_distance(_graph_mx, _graph_my, _pin_x, _pin_y) <= _pin_radius)
            {
                // Should we allow disconnecting outputs? Usually disconnecting input is enough.
                _pin_clicked = true; // Block menu
                break;
            }
        }
        
        if (!_pin_clicked)
        {
            // Right-clicked Node Body -> Disconnect All
             var _in_names = struct_get_names(_clicked_node.inputs);
            for (var k = 0; k < array_length(_in_names); ++k)
            {
                var _pin = _clicked_node.inputs[$ _in_names[k]];
                if (_pin.is_connected()) graph.disconnect_pin(_pin);
            }
            preview_dirty = true;
            biome_preview_dirty = true;
            // Optionally also remove from graph logic? No just disconnects.
        }
    }
    else
    {
        context_menu_open = true;
        context_menu_x = _mx;
        context_menu_y = _my;
        context_menu_active_category = undefined;
    }
}

// --- Left-click: Select/Drag ---
if (mouse_check_button_pressed(mb_left))
{
    var _clicked_node = graph.get_node_at(_graph_mx, _graph_my);
    
    if (_clicked_node != undefined)
    {
        // Check Pins First
        var _pin_radius = 15; // Increased radius for selection too
        var _clicked_pin = undefined;
        
        // Output pins (start connection)
        for (var i = 0; i < array_length(_clicked_node.output_order); ++i)
        {
            var _pin_name = _clicked_node.output_order[i];
            var _pin_x = _clicked_node.x + _clicked_node.width;
            var _pin_y = _clicked_node.y + 30 + i * 20;
            
            if (point_distance(_graph_mx, _graph_my, _pin_x, _pin_y) < _pin_radius)
            {
                connecting_from_pin = _clicked_node.outputs[$ _pin_name];
                connecting_from_node = _clicked_node;
                _clicked_pin = true;
                break;
            }
        }

        if (connecting_from_pin == undefined)
        {
            // Double Click Check
            if (last_clicked_node == _clicked_node && current_time - last_click_time < 400)
            {
                if (_clicked_node.type == "Constant")
                {
                    editing_constant_node = _clicked_node;
                    editing_constant_text = string(_clicked_node.constant_value);
                    keyboard_string = "";
                    return;
                }
                if (_clicked_node.type == "Spline")
                {
                    spline_edit_active = true;
                    spline_edit_node = _clicked_node;
                    spline_edit_selected_point = -1;
                    return;
                }
                
                // Check attribute click for double-click editing
                var _attr_start_y = _clicked_node.y + 30 + max(array_length(_clicked_node.input_order), array_length(_clicked_node.output_order)) * 20;
                for (var i = 0; i < array_length(_clicked_node.attribute_order); ++i)
                {
                    var _attr_name = _clicked_node.attribute_order[i];
                    var _attr = _clicked_node.attributes[$ _attr_name];
                    var _attr_y = _attr_start_y + i * 24;
                    var _val_x = _clicked_node.x + 58;
                    
                    if (_graph_my >= _attr_y && _graph_my < _attr_y + 20)
                    {
                        if (_attr.type == "color")
                        {
                            // Open color picker
                            color_picker_open = true;
                            color_picker_node = _clicked_node;
                            color_picker_attr = _attr_name;
                            var _col = _attr.value ?? c_white;
                            color_picker_hue = color_get_hue(_col) / 255;
                            color_picker_sat = color_get_saturation(_col) / 255;
                            color_picker_val = color_get_value(_col) / 255;
                        }
                        else if (_attr.type == "bool")
                        {
                            // Toggle boolean
                            _attr.value = !_attr.value;
                            loom_trigger_refresh(_clicked_node);
                        }
                        else
                        {
                            // Start text editing for string/value
                            editing_attr_node = _clicked_node;
                            editing_attr_name = _attr_name;
                            editing_attr_text = string(_attr.value ?? "");
                            keyboard_string = "";
                        }
                        return;
                    }
                }
            }
            last_clicked_node = _clicked_node;
            last_click_time = current_time;

            // Node Selection Logic
            if (_shift)
            {
                // Toggle selection
                var _index = -1;
                for(var k=0; k<array_length(selected_nodes); ++k) { if (selected_nodes[k] == _clicked_node) { _index = k; break; } }
                
                if (_index != -1) array_delete(selected_nodes, _index, 1);
                else array_push(selected_nodes, _clicked_node);
            }
            else
            {
                // If not already selected, clear and select this
                var _is_selected = false;
                for(var k=0; k<array_length(selected_nodes); ++k) { if (selected_nodes[k] == _clicked_node) { _is_selected = true; break; } }
                
                if (!_is_selected)
                {
                    selected_nodes = [_clicked_node];
                }
            }
            
            // Start Dragging
            dragging_nodes = true;
            // Store offsets for all selected nodes relative to mouse
            for (var i = 0; i < array_length(selected_nodes); ++i)
            {
                var _n = selected_nodes[i];
                _n.___drag_anch_x = _n.x - _graph_mx;
                _n.___drag_anch_y = _n.y - _graph_my;
            }
        }
    }
    else
    {
        // Clicked empty space
        if (!_shift) selected_nodes = []; // Clear selection if not shift-clicking
        selection_box_active = true;
        selection_box_start_x = _graph_mx;
        selection_box_start_y = _graph_my;
    }
}

// --- Dragging Nodes ---
if (dragging_nodes)
{
    if (mouse_check_button(mb_left))
    {
        for (var i = 0; i < array_length(selected_nodes); ++i)
        {
            var _n = selected_nodes[i];
            _n.x = _graph_mx + _n.___drag_anch_x;
            _n.y = _graph_my + _n.___drag_anch_y;
            
            if (_ctrl)
            {
                _n.x = round(_n.x / grid_size) * grid_size;
                _n.y = round(_n.y / grid_size) * grid_size;
            }
        }
    }
    else
    {
        dragging_nodes = false;
    }
}

// --- Selection Box ---
if (selection_box_active)
{
    if (mouse_check_button(mb_left))
    {
        // Just drawing, logic happens on release
    }
    else
    {
        // Apply selection
        var _l = min(selection_box_start_x, _graph_mx);
        var _r = max(selection_box_start_x, _graph_mx);
        var _t = min(selection_box_start_y, _graph_my);
        var _b = max(selection_box_start_y, _graph_my);
        
        for (var i = 0; i < array_length(graph.nodes); ++i)
        {
            var _n = graph.nodes[i];
            // Check basic overlap
            if (_n.x + _n.width > _l && _n.x < _r && _n.y + _n.height > _t && _n.y < _b)
            {
                // Add to selection if not present
                var _already = false;
                for(var k=0; k<array_length(selected_nodes); ++k) { if (selected_nodes[k] == _n) { _already = true; break; } }
                if (!_already) array_push(selected_nodes, _n);
            }
        }
        selection_box_active = false;
    }
}

// --- Connecting Pins ---
if (connecting_from_pin != undefined)
{
    if (!mouse_check_button(mb_left))
    {
        // Released - check target
        var _target_node = graph.get_node_at(_graph_mx, _graph_my);
        if (_target_node != undefined && _target_node != connecting_from_node)
        {
            var _pin_radius = 8;
            for (var i = 0; i < array_length(_target_node.input_order); ++i)
            {
                var _pin_name = _target_node.input_order[i];
                var _pin_x = _target_node.x;
                var _pin_y = _target_node.y + 30 + i * 20;
                
                if (point_distance(_graph_mx, _graph_my, _pin_x, _pin_y) < _pin_radius)
                {
                    var _target_pin = _target_node.inputs[$ _pin_name];
                    graph.connect(connecting_from_pin, _target_pin);
                    loom_trigger_refresh(_target_node);
                    break;
                }
            }
        }
        connecting_from_pin = undefined;
        connecting_from_node = undefined;
    }
}

// --- Delete ---
if (keyboard_check_pressed(vk_delete) && array_length(selected_nodes) > 0)
{
    var _any_connected_removed = false;
    for (var i = 0; i < array_length(selected_nodes); ++i)
    {
        var _n = selected_nodes[i];
        
        // Check input connections
        var _in_names = struct_get_names(_n.inputs);
        for (var k = 0; k < array_length(_in_names); ++k) {
            if (_n.inputs[$ _in_names[k]].is_connected()) { _any_connected_removed = true; break; }
        }
        if (_any_connected_removed) break;
        
        // Check output connections
        var _out_names = struct_get_names(_n.outputs);
        for (var k = 0; k < array_length(_out_names); ++k) {
            if (_n.outputs[$ _out_names[k]].is_connected()) { _any_connected_removed = true; break; }
        }
        if (_any_connected_removed) break;
    }

    for (var i = 0; i < array_length(selected_nodes); ++i)
    {
        graph.remove_node(selected_nodes[i]);
    }
    selected_nodes = [];
    
    if (_any_connected_removed)
    {
        preview_dirty = true;
    }
}

mouse_last_x = mouse_x;
mouse_last_y = mouse_y;
