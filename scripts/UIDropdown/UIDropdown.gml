/// @desc UI Dropdown Element - expandable option selector
/// @param {Real} _x X position
/// @param {Real} _y Y position
/// @param {Real} _width Dropdown width
/// @param {Real} _height Collapsed height (single row)
function UIDropdown(_x, _y, _width, _height) : UIElement(_x, _y, _width, _height) constructor {
    options = [];              // Array of display strings
    selected_index = 0;        // Currently selected option index
    is_open = false;           // Whether dropdown list is expanded
    
    // Collapsed height (stored separately so height can expand)
    collapsed_height = _height;
    option_height = _height;   // Height of each option row
    
    // Visual styling
    dropdown_color = #2a2a3a;
    hover_color = #3a3a5a;
    text_color = c_white;
    arrow_color = #aaaaaa;
    border_color = #4a4a6a;
    
    // Interaction state
    hovered_option = -1;
    
    /// @desc Set options array
    static set_options = function(_value) {
        if (is_array(_value)) {
            options = _value;
        }
    }
    
    /// @desc Set the selected index
    static set_selected = function(_value) {
        selected_index = clamp(floor(_value), 0, max(0, array_length(options) - 1));
    }
    
    /// @desc Toggle the dropdown open/closed
    static toggle_open = function() {
        is_open = !is_open;
        
        if (is_open) {
            height = collapsed_height + array_length(options) * option_height;
        } else {
            height = collapsed_height;
            hovered_option = -1;
        }
        
        // Reflow sibling layout if parent uses vertical layout
        if (parent != undefined && struct_exists(parent, "layout_children")) {
            parent.layout_children();
        }
    }
    
    static update = function() {
        if (!visible) return;
        
        var _base_scale = ui_get_base_scale();
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _mx = (window_mouse_get_x() / global.window_width) * global.gui_width;
        var _my = (window_mouse_get_y() / global.window_height) * global.gui_height;
        
        var _left = _abs_x * _base_scale.x;
        var _top = _abs_y * _base_scale.y;
        var _right = _left + (width * _base_scale.x);
        var _header_bottom = _top + (collapsed_height * _base_scale.y);
        
        hovered_option = -1;
        
        if (mouse_check_button_pressed(mb_left)) {
            // Check if clicking the header (toggle area)
            if (_mx >= _left && _mx <= _right && _my >= _top && _my <= _header_bottom) {
                toggle_open();
            }
            // Check if clicking an option
            else if (is_open) {
                var _opt_count = array_length(options);
                
                for (var i = 0; i < _opt_count; ++i) {
                    var _opt_top = _header_bottom + (i * option_height * _base_scale.y);
                    var _opt_bottom = _opt_top + (option_height * _base_scale.y);
                    
                    if (_mx >= _left && _mx <= _right && _my >= _opt_top && _my <= _opt_bottom) {
                        selected_index = i;
                        toggle_open(); // Close after selecting
                        emit_event("on_change", { value: selected_index, option: options[i] });
                        
                        break;
                    }
                }
                
                // If clicked outside dropdown area entirely, close it
                var _full_bottom = _header_bottom + (_opt_count * option_height * _base_scale.y);
                
                if (_my < _top || _my > _full_bottom || _mx < _left || _mx > _right) {
                    toggle_open();
                }
            }
        }
        
        // Track hover for highlighting
        if (is_open) {
            var _opt_count = array_length(options);
            
            for (var i = 0; i < _opt_count; ++i) {
                var _opt_top = _header_bottom + (i * option_height * _base_scale.y);
                var _opt_bottom = _opt_top + (option_height * _base_scale.y);
                
                if (_mx >= _left && _mx <= _right && _my >= _opt_top && _my <= _opt_bottom) {
                    hovered_option = i;
                    
                    break;
                }
            }
        }
        
        update_bindings();
    }
    
    static draw_content = function() {
        var _base_scale = ui_get_base_scale();
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _x1 = _abs_x * _base_scale.x;
        var _y1 = _abs_y * _base_scale.y;
        var _x2 = _x1 + (width * _base_scale.x);
        var _header_y2 = _y1 + (collapsed_height * _base_scale.y);
        
        // Draw header background
        draw_rectangle_colour(_x1, _y1, _x2, _header_y2,
            dropdown_color, dropdown_color, dropdown_color, dropdown_color, false);
        
        // Draw header border
        draw_rectangle_colour(_x1, _y1, _x2, _header_y2,
            border_color, border_color, border_color, border_color, true);
        
        // Draw selected text
        var _text_x = _x1 + (4 * _base_scale.x);
        var _text_y = _y1 + (collapsed_height * _base_scale.y / 2);
        var _selected_text = "";
        
        if (selected_index >= 0 && selected_index < array_length(options)) {
            _selected_text = string(options[selected_index]);
        }
        
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);
        draw_set_colour(text_color);
        draw_text(_text_x, _text_y, _selected_text);
        
        // Draw arrow indicator
        var _arrow_x = _x2 - (12 * _base_scale.x);
        
        draw_set_colour(arrow_color);
        draw_text(_arrow_x, _text_y, is_open ? "▲" : "▼");
        
        // Draw expanded options
        if (is_open) {
            var _opt_count = array_length(options);
            
            for (var i = 0; i < _opt_count; ++i) {
                var _opt_top = _header_y2 + (i * option_height * _base_scale.y);
                var _opt_bottom = _opt_top + (option_height * _base_scale.y);
                
                // Background (highlighted if hovered)
                var _bg = (i == hovered_option) ? hover_color : dropdown_color;
                
                draw_rectangle_colour(_x1, _opt_top, _x2, _opt_bottom,
                    _bg, _bg, _bg, _bg, false);
                
                // Border
                draw_rectangle_colour(_x1, _opt_top, _x2, _opt_bottom,
                    border_color, border_color, border_color, border_color, true);
                
                // Text
                var _opt_text_y = _opt_top + (option_height * _base_scale.y / 2);
                
                draw_set_colour(text_color);
                draw_text(_text_x, _opt_text_y, string(options[i]));
            }
        }
        
        // Reset draw state
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_colour(c_white);
    }
}
