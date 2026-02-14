/// @desc Layout mode enum for UI containers
enum UI_LAYOUT {
    NONE,
    VERTICAL,
    HORIZONTAL,
    GRID
}

/// @desc Base UI Element - extends GUIComponent with declarative features
/// All declarative UI elements inherit from this
/// @param {Real} _x X position
/// @param {Real} _y Y position  
/// @param {Real} _width Element width
/// @param {Real} _height Element height
function UIElement(_x, _y, _width, _height) : GUIComponent(_x, _y, _width, _height) constructor {
    // Element identification
    element_name = "";
    element_type = "";
    
    // Data bindings: property_name -> binding_name
    bindings = {};
    
    // Event handlers: event_name -> script_id
    event_handlers = {};
    
    // Link context (provided by Proglang at spawn time)
    link_context = undefined;
    
    // Layout properties
    layout = UI_LAYOUT.NONE;
    spacing = 0;
    padding_top = 0;
    padding_right = 0;
    padding_bottom = 0;
    padding_left = 0;
    grid_columns = 10;  // Default columns for grid layout
    
    // Visual properties
    background_color = undefined;
    background_alpha = 1;
    border_color = undefined;
    border_width = 0;
    
    // =============================================================================
    // Binding System
    // =============================================================================
    
    /// @desc Register a data binding for a property
    /// @param {String} _property Property name
    /// @param {String} _binding_name Name in link context
    static add_binding = function(_property, _binding_name) {
        bindings[$ _property] = _binding_name;
        return self;
    }
    
    /// @desc Update all bound properties from link context
    static update_bindings = function() {
        if (link_context == undefined) return;
        
        var _names = struct_get_names(bindings);
        var _count = array_length(_names);
        
        for (var i = 0; i < _count; i++) {
            var _property = _names[i];
            var _binding_name = bindings[$ _property];
            var _resolver = link_context[$ _binding_name];
            
            if (_resolver != undefined) {
                var _value = undefined;
                
                // If resolver is a function, call it to get value
                if (is_method(_resolver)) {
                    _value = _resolver();
                } else if (is_array(_resolver)) {
                    // It might be a Proglang closure/function
                    _value = proglang_runtime_call(_resolver);
                } else {
                    _value = _resolver;
                }
                
                // Set the property value via setter if it exists, otherwise directly
                if (_value == undefined) {
                    show_debug_message($"[UI Runtime] Warning: Binding '{_binding_name}' for property '{_property}' in element '{element_name}' resolved to undefined.");
                }
                
                var _setter_name = "set_" + _property;
                if (variable_struct_exists(self, _setter_name)) {
                    var _setter = self[$ _setter_name];
                    if (is_callable(_setter)) {
                        var _m = method(self, _setter);
                        _m(_value);
                    }
                } else {
                    self[$ _property] = _value;
                }
            }
        }
        
        // Propagate to children
        var _child_count = array_length(children);
        for (var i = 0; i < _child_count; i++) {
            if (variable_struct_exists(children[i], "update_bindings")) {
                children[i].update_bindings();
            }
        }
    }
    
    /// @desc Set the link context for data binding
    /// @param {Struct} _context Link context from Proglang
    static set_link_context = function(_context) {
        link_context = _context;
        
        // Propagate to children
        var _child_count = array_length(children);
        for (var i = 0; i < _child_count; i++) {
            if (variable_struct_exists(children[i], "set_link_context")) {
                children[i].set_link_context(_context);
            }
        }
        
        return self;
    }
    
    // =============================================================================
    // Event System
    // =============================================================================
    
    /// @desc Register an event handler
    /// @param {String} _event Event name (on_click, on_select_release, etc.)
    /// @param {String} _script_id Proglang script ID to execute
    static add_event_handler = function(_event, _script_id) {
        event_handlers[$ _event] = _script_id;
        return self;
    }
    
    /// @desc Emit an event, executing the registered handler
    /// @param {String} _event Event name
    /// @param {Struct} _data Optional event data
    static emit_event = function(_event, _data = {}) {
        var _script_id = event_handlers[$ _event];
        
        if (_script_id != undefined) {
            // Execute via Proglang
            var _context = {
                element: self,
                element_name: element_name,
                event: _event,
                data: _data
            };
            
            // Merge with link context
            if (link_context != undefined) {
                var _link_names = struct_get_names(link_context);
                var _link_count = array_length(_link_names);
                for (var i = 0; i < _link_count; i++) {
                    _context[$ _link_names[i]] = link_context[$ _link_names[i]];
                }
            }
            
            proglang_runtime_call(_script_id, [], _context);
        }
    }
    
    // =============================================================================
    // Layout System
    // =============================================================================
    
    /// @desc Set padding (single value or individual sides)
    /// @param {Real|Struct} _padding Padding value or struct with top/right/bottom/left
    static set_padding = function(_padding) {
        if (is_struct(_padding)) {
            padding_top = _padding[$ "top"] ?? 0;
            padding_right = _padding[$ "right"] ?? 0;
            padding_bottom = _padding[$ "bottom"] ?? 0;
            padding_left = _padding[$ "left"] ?? 0;
        } else {
            padding_top = _padding;
            padding_right = _padding;
            padding_bottom = _padding;
            padding_left = _padding;
        }
        layout_children();
        return self;
    }
    
    /// @desc Layout children based on layout mode
    static layout_children = function() {
        if (array_length(children) == 0) return;
        
        switch (layout) {
            case UI_LAYOUT.VERTICAL:
                layout_vertical();
                break;
            case UI_LAYOUT.HORIZONTAL:
                layout_horizontal();
                break;
            case UI_LAYOUT.GRID:
                layout_grid();
                break;
        }
    }
    
    static layout_vertical = function() {
        var _y = padding_top;
        var _child_count = array_length(children);
        
        for (var i = 0; i < _child_count; i++) {
            var _child = children[i];
            if (!_child.visible) continue;
            
            _child.x = padding_left;
            _child.y = _y;
            
            _y += _child.height + spacing;
        }
    }
    
    static layout_horizontal = function() {
        var _x = padding_left;
        var _child_count = array_length(children);
        
        for (var i = 0; i < _child_count; i++) {
            var _child = children[i];
            if (!_child.visible) continue;
            
            _child.x = _x;
            _child.y = padding_top;
            
            _x += _child.width + spacing;
        }
    }
    
    static layout_grid = function() {
        var _col = 0;
        var _row = 0;
        var _child_count = array_length(children);
        
        for (var i = 0; i < _child_count; i++) {
            var _child = children[i];
            if (!_child.visible) continue;
            
            _child.x = padding_left + (_col * (_child.width + spacing));
            _child.y = padding_top + (_row * (_child.height + spacing));
            
            _col++;
            if (_col >= grid_columns) {
                _col = 0;
                _row++;
            }
        }
    }
    
    // =============================================================================
    // Override GUIComponent methods
    // =============================================================================
    
    /// @desc Get absolute X position in logical units (960-based)
    static get_absolute_x = function() {
        if (parent != undefined) {
            return parent.get_absolute_x() + x;
        }
        return x;
    }
    
    /// @desc Get absolute Y position in logical units (960-based)
    static get_absolute_y = function() {
        if (parent != undefined) {
            return parent.get_absolute_y() + y;
        }
        return y;
    }
    
    static update = function() {
        if (!visible) return;
        
        // Update bindings each frame
        update_bindings();
        
        // Update children
        var _child_count = array_length(children);
        for (var i = 0; i < _child_count; i++) {
            children[i].update();
        }
    }
    
    static draw = function() {
        if (!visible) return;
        
        var _base_scale = ui_get_base_scale();
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _x1 = _abs_x * _base_scale.x;
        var _y1 = _abs_y * _base_scale.y;
        var _x2 = _x1 + (width * _base_scale.x);
        var _y2 = _y1 + (height * _base_scale.y);

        // Draw background if set
        if (background_color != undefined) {
            draw_set_alpha(background_alpha);
            draw_rectangle_colour(_x1, _y1, _x2, _y2,
                background_color, background_color, background_color, background_color, false);
            draw_set_alpha(1);
        }
        
        // Draw border if set
        if (border_color != undefined && border_width > 0) {
            draw_rectangle_colour(_x1, _y1, _x2, _y2,
                border_color, border_color, border_color, border_color, true);
        }
        
        // Draw content
        draw_content();
        
        // Draw children
        var _child_count = array_length(children);
        for (var i = 0; i < _child_count; i++) {
            children[i].draw();
        }
    }
}
