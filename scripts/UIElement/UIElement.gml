/* Layout mode enum for UI containers */
enum UI_LAYOUT
{
    NONE,
    VERTICAL,
    HORIZONTAL,
    GRID
}

/* Base UI Element - extends GUIComponent with declarative features
   All declarative UI elements inherit from this
   @param {Real} _x X position
   @param {Real} _y Y position  
   @param {Real} _width Element width
   @param {Real} _height Element height */
function UIElement(_x, _y, _width, _height) constructor
{
    /* Core properties (formerly from GUIComponent) */
    x = _x;
    y = _y;
    width = _width;
    height = _height;
    
    visible = true;
    parent = undefined;
    children = [];
    
    anchor_x = undefined; /* "left", "center", "right" */
    anchor_y = undefined; /* "top", "middle", "bottom" */
    offset_x = _x;
    offset_y = _y;
    
    scale = 1.0; 

    /* Element identification */
    element_name = "";
    element_type = "";
    
    /* Data bindings: property_name -> binding_name */
    bindings = {};
    
    /* Event handlers: event_name -> script_id */
    event_handlers = {};
    
    /* Link context (provided by Proglang at spawn time) */
    link_context = undefined;
    
    /* Layout properties */
    layout = UI_LAYOUT.NONE;
    spacing = 0;
    padding_top = 0;
    padding_right = 0;
    padding_bottom = 0;
    padding_left = 0;
    grid_columns = 10;  /* Default columns for grid layout */
    auto_height = false; /* When true, height is recalculated from children during layout refresh */
    
    /* Visual properties */
    background_color = undefined;
    background_alpha = 1;
    border_color = undefined;
    border_width = 0;
    
    /* =============================================================================
       Binding System
       ============================================================================= */
    
    /* Register a data binding for a property
       @param {String} _property Property name
       @param {String} _binding_name Name in link context */
    static add_binding = function(_property, _binding_name)
    {
        bindings[$ _property] = _binding_name;
        
        return self;
    }
    
    /* Update all bound properties from link context */
    static update_bindings = function()
    {
        if (link_context == undefined) exit;
        
        var _names = struct_get_names(bindings);
        var _count = array_length(_names);
        
        for (var i = 0; i < _count; ++i)
        {
            var _property = _names[i];
            var _binding_name = bindings[$ _property];
            var _resolver = link_context[$ _binding_name];
            
            if (_resolver != undefined)
            {
                var _value = undefined;
                
                /* If resolver is a function, call it to get value */
                if (is_method(_resolver))
                {
                    _value = _resolver();
                }
                else if (is_array(_resolver))
                {
                    /* It might be a Proglang closure/function */
                    _value = proglang_runtime_call(_resolver);
                }
                else
                {
                    _value = _resolver;
                }
                
                /* Set the property value via setter if it exists, otherwise directly */
                if (_value == undefined)
                {
                    show_debug_message($"[UI Runtime] Warning: Binding '{_binding_name}' for property '{_property}' in element '{element_name}' resolved to undefined.");
                }
                
                var _setter_name = "set_" + _property;
                
                if (struct_exists(self, _setter_name))
                {
                    var _setter = self[$ _setter_name];
                    
                    if (is_callable(_setter))
                    {
                        var _m = method(self, _setter);
                        _m(_value);
                    }
                }
                else
                {
                    self[$ _property] = _value;
                }
            }
        }
        
        /* Propagate to children */
        var _child_count = array_length(children);
        
        for (var i = 0; i < _child_count; ++i)
        {
            if (struct_exists(children[i], "update_bindings"))
            {
                children[i].update_bindings();
            }
        }
    }
    
    /* Add a child element
       @param {Struct.UIElement} _child Child element to add */
    static add_child = function(_child)
    {
        _child.parent = self;
        array_push(children, _child);
        _child.recalculate_layout();
        
        return _child;
    }
    
    /* Remove a child element
       @param {Struct.UIElement} _child Child element to remove */
    static remove_child = function(_child)
    {
        var _count = array_length(children);
        
        for (var i = 0; i < _count; ++i)
        {
            if (children[i] == _child)
            {
                array_delete(children, i, 1);
                _child.parent = undefined;
                recalculate_layout();
                
                return true;
            }
        }
        
        return false;
    }
    
    /* Set anchors and update layout */
    static set_anchor = function(_anchor_x, _anchor_y)
    {
        anchor_x = _anchor_x;
        anchor_y = _anchor_y;
        recalculate_layout();
        
        return self;
    }
    
    /* Recalculate position based on anchors */
    static recalculate_layout = function()
    {
        if (parent == undefined)
        {
             exit;
        }
        
        if (anchor_x != undefined)
        {
            switch (anchor_x)
            {
                case "left":   x = offset_x; break;
                case "center": x = (parent.width / 2) - (width / 2) + offset_x; break;
                case "right":  x = parent.width - width - offset_x; break;
            }
        }
        
        if (anchor_y != undefined)
        {
            switch (anchor_y)
            {
                case "top":    y = offset_y; break;
                case "middle": y = (parent.height / 2) - (height / 2) + offset_y; break;
                case "bottom": y = parent.height - height - offset_y; break;
            }
        }
        
        var _length = array_length(children);
        
        for (var i = 0; i < _length; ++i)
        {
            children[i].recalculate_layout();
        }
    }

    /* Set the link context for data binding
       @param {Struct} _context Link context from Proglang */
    static set_link_context = function(_context)
    {
        link_context = _context;
        
        /* Propagate to children */
        var _child_count = array_length(children);
        
        for (var i = 0; i < _child_count; ++i)
        {
            if (struct_exists(children[i], "set_link_context"))
            {
                children[i].set_link_context(_context);
            }
        }
        
        return self;
    }
    
    /* =============================================================================
       Event System
       ============================================================================= */
    
    /* Register an event handler
       @param {String} _event Event name (on_click, on_select_release, etc.)
       @param {String} _script_id Proglang script ID to execute */
    static add_event_handler = function(_event, _script_id)
    {
        event_handlers[$ _event] = _script_id;
        
        return self;
    }
    
    /* Emit an event, executing the registered handler
       @param {String} _event Event name
       @param {Struct} _data Optional event data */
    static emit_event = function(_event, _data = {})
    {
        var _script_id = event_handlers[$ _event];
        
        if (_script_id != undefined)
        {
            /* Execute via Proglang */
            var _context = {
                element: self,
                element_name: element_name,
                event: _event,
                data: _data
            }
            
            /* Merge with link context */
            if (link_context != undefined)
            {
                var _link_names = struct_get_names(link_context);
                var _link_count = array_length(_link_names);
                
                for (var i = 0; i < _link_count; ++i)
                {
                    _context[$ _link_names[i]] = link_context[$ _link_names[i]];
                }
            }
            
            proglang_runtime_call(_script_id, [], _context);
        }
    }
    
    /* =============================================================================
       Layout System
       ============================================================================= */
    
    /* Set padding (single value or individual sides)
       @param {Real|Struct} _padding Padding value or struct with top/right/bottom/left */
    static set_padding = function(_padding)
    {
        if (is_struct(_padding))
        {
            padding_top = _padding[$ "top"] ?? 0;
            padding_right = _padding[$ "right"] ?? 0;
            padding_bottom = _padding[$ "bottom"] ?? 0;
            padding_left = _padding[$ "left"] ?? 0;
        }
        else if (is_array(_padding))
        {
            var _len = array_length(_padding);
            
            switch (_len)
            {
                case 1:
                    padding_top = _padding[0];
                    padding_right = _padding[0];
                    padding_bottom = _padding[0];
                    padding_left = _padding[0];
                    break;
                case 2:
                    padding_top = _padding[0];
                    padding_right = _padding[1];
                    padding_bottom = _padding[0];
                    padding_left = _padding[1];
                    break;
                case 4:
                    padding_top = _padding[0];
                    padding_right = _padding[1];
                    padding_bottom = _padding[2];
                    padding_left = _padding[3];
                    break;
                default:
                    show_debug_message($"[UI Runtime] Warning: Unsupported padding array length ({_len}) in '{element_name}'. Expected 1, 2, or 4.");
                    break;
            }
        }
        else
        {
            padding_top = _padding;
            padding_right = _padding;
            padding_bottom = _padding;
            padding_left = _padding;
        }
        
        layout_children();
        
        return self;
    }
    
    /* Layout children based on layout mode */
    static layout_children = function()
    {
        if (array_length(children) == 0) exit;
        
        switch (layout)
        {
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
    
    static layout_vertical = function()
    {
        var _y = padding_top;
        var _child_count = array_length(children);
        
        for (var i = 0; i < _child_count; ++i)
        {
            var _child = children[i];
            
            if (!_child.visible)
            {
                 continue;
            }
            
            _child.x = padding_left;
            _child.y = _y;
            
            _y += _child.height + spacing;
        }
    }
    
    static layout_horizontal = function()
    {
        var _x = padding_left;
        var _child_count = array_length(children);
        
        for (var i = 0; i < _child_count; ++i)
        {
            var _child = children[i];
            
            if (!_child.visible)
            {
                 continue;
            }
            
            _child.x = _x;
            _child.y = padding_top;
            
            _x += _child.width + spacing;
        }
    }
    
    static layout_grid = function()
    {
        var _col = 0;
        var _row = 0;
        var _child_count = array_length(children);
        
        for (var i = 0; i < _child_count; ++i)
        {
            var _child = children[i];
            
            if (!_child.visible)
            {
                 continue;
            }
            
            _child.x = padding_left + (_col * (_child.width + spacing));
            _child.y = padding_top + (_row * (_child.height + spacing));
            
            _col++;
            
            if (_col >= grid_columns)
            {
                _col = 0;
                _row++;
            }
        }
    }
    
    /* =============================================================================
       Override GUIComponent methods
       ============================================================================= */
    
    /* Get absolute X position in logical units (960-based) */
    static get_absolute_x = function()
    {
        if (parent != undefined)
        {
            return parent.get_absolute_x() + x;
        }
        
        return x;
    }
    
    /* Get absolute Y position in logical units (960-based) */
    static get_absolute_y = function()
    {
        if (parent != undefined)
        {
            return parent.get_absolute_y() + y;
        }
        
        return y;
    }
    
    static update = function()
    {
        if (!visible) exit;
        
        /* Update bindings each frame */
        update_bindings();
        
        /* Update children */
        var _child_count = array_length(children);
        
        for (var i = 0; i < _child_count; ++i)
        {
            children[i].update();
        }
    }
    
    /* Custom drawing for the element. Overridden by subclasses. */
    static draw_content = function()
    {
        /* Default implementation does nothing */
    }
    
    static draw = function()
    {
        if (!visible) exit;
        
        var _base_scale = ui_get_base_scale();
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _x1 = floor(_abs_x * _base_scale.x);
        var _y1 = floor(_abs_y * _base_scale.y);
        var _x2 = floor(_x1 + (width * _base_scale.x));
        var _y2 = floor(_y1 + (height * _base_scale.y));

        /* Draw background if set */
        if (background_color != undefined)
        {
            draw_set_alpha(background_alpha);
            draw_rectangle_colour(_x1, _y1, _x2, _y2,
                background_color, background_color, background_color, background_color, false);
            draw_set_alpha(1);
        }
        
        /* Draw border if set */
        if (border_color != undefined && border_width > 0)
        {
            draw_rectangle_colour(_x1, _y1, _x2, _y2,
                border_color, border_color, border_color, border_color, true);
        }
        
        /* Draw content */
        draw_content();
        
        /* Draw children */
        var _child_count = array_length(children);
        
        for (var i = 0; i < _child_count; ++i)
        {
            children[i].draw();
        }
    }
}
