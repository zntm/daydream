/* layout mode enum for UI containers */
enum UI_LAYOUT
{
    NONE,
    VERTICAL,
    HORIZONTAL,
    GRID
}


/* base UI element - extends GUIComponent with declarative features */
/* all declarative UI elements inherit from this */
/* @param {real} _x x position */
/* @param {real} _y y position  */
/* @param {real} _width element width */
/* @param {real} _height element height */
function UIElement(_x, _y, _width, _height) constructor
{
    /* core properties */
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


    /* element identification */
    element_name = "";
    element_type = "";
    
    
    /* state bitmask */
    boolean = 0;
    
    
    /* data bindings: property_name -> binding_name */
    bindings = {}
    
    
    /* event handlers: event_name -> script_id */
    event_handlers = {}
    
    
    /* link context (provided by proglang at spawn time) */
    link_context = undefined;
    
    
    /* layout properties */
    layout = UI_LAYOUT.NONE;
    
    spacing = 0;
    
    padding_top = 0;
    padding_right = 0;
    padding_bottom = 0;
    padding_left = 0;
    
    grid_columns = 10;  /* default columns for grid layout */
    
    
    /* visual properties */
    background_color = undefined;
    background_alpha = 1;
    
    border_color = undefined;
    border_width = 1;
    
    
    on_draw = undefined;
    
    
    /* =============================================================================
       binding system
       ============================================================================= */
    
    /* register a data binding for a property */
    /* @param {string} _property property name */
    /* @param {string} _binding_name name in link context */
    static add_binding = function(_property, _binding_name)
    {
        bindings[$ _property] = _binding_name;
        
        return self;
    }
    
    
    /* update all bound properties from link context */
    static update_bindings = function()
    {
        if (link_context == undefined)
        {
             exit;
        }
        
        
        var _names = struct_get_names(bindings);
        var _count = array_length(_names);
        
        
        for (var i = _count - 1; i >= 0; --i)
        {
            var _property = _names[i];
            var _binding_name = bindings[$ _property];
            var _resolver = link_context[$ _binding_name];
            
            
            if (_resolver != undefined)
            {
                var _value = undefined;
                
                
                /* if resolver is a function, call it to get value */
                if (is_method(_resolver))
                {
                    _value = _resolver();
                }
                else if (is_array(_resolver))
                {
                    /* it might be a proglang closure/function */
                    _value = proglang_runtime_call(_resolver);
                }
                else
                {
                    _value = _resolver;
                }
                
                
                /* set the property value via setter if it exists, otherwise directly */
                if (_value == undefined)
                {
                    PRINT($"[UI Runtime] warning: binding '{_binding_name}' for property '{_property}' in element '{element_name}' resolved to undefined.");
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
        
        
        /* propagate to children */
        var _child_count = array_length(children);
        
        
        for (var i = _child_count - 1; i >= 0; --i)
        {
            if (struct_exists(children[i], "update_bindings"))
            {
                children[i].update_bindings();
            }
        }
    }
    
    
    /* add a child element */
    /* @param {struct.UIElement} _child child element to add */
    static add_child = function(_child)
    {
        _child.parent = self;
        
        array_push(children, _child);
        
        _child.recalculate_layout();
        
        return _child;
    }
    
    
    /* remove a child element */
    /* @param {struct.UIElement} _child child element to remove */
    static remove_child = function(_child)
    {
        var _count = array_length(children);
        
        
        for (var i = _count - 1; i >= 0; --i)
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
    
    
    /* set anchors and update layout */
    static set_anchor = function(_anchor_x, _anchor_y)
    {
        anchor_x = _anchor_x;
        anchor_y = _anchor_y;
        
        recalculate_layout();
        
        return self;
    }
    
    
    /* recalculate position based on anchors */
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
                case "left":
                    x = offset_x;
                    break;
                    
                case "center":
                    x = (parent.width / 2) - (width / 2) + offset_x;
                    break;
                    
                case "right":
                    x = parent.width - width + offset_x;
                    break;
            }
        }
        
        
        if (anchor_y != undefined)
        {
            switch (anchor_y)
            {
                case "top":
                    y = offset_y;
                    break;
                    
                case "middle":
                    y = (parent.height / 2) - (height / 2) + offset_y;
                    break;
                    
                case "bottom":
                    y = parent.height - height + offset_y;
                    break;
            }
        }
        
        
        var _length = array_length(children);
        
        
        for (var i = _length - 1; i >= 0; --i)
        {
            children[i].recalculate_layout();
        }
    }


    /* set the link context for data binding */
    /* @param {struct} _context link context from proglang */
    static set_link_context = function(_context)
    {
        link_context = _context;
        
        
        /* propagate to children */
        var _child_count = array_length(children);
        
        
        for (var i = _child_count - 1; i >= 0; --i)
        {
            if (struct_exists(children[i], "set_link_context"))
            {
                children[i].set_link_context(_context);
            }
        }
        
        return self;
    }
    
    
    /* =============================================================================
       event system
       ============================================================================= */
    
    /* register an event handler */
    /* @param {string} _event event name (on_click, on_select_release, etc.) */
    /* @param {string} _script_id proglang script id to execute */
    static add_event_handler = function(_event, _script_id)
    {
        event_handlers[$ _event] = _script_id;
        
        return self;
    }
    
    
    /* emit an event, executing the registered handler */
    /* @param {string} _event event name */
    /* @param {struct} _data optional event data */
    static emit_event = function(_event, _data = {})
    {
        var _script_id = event_handlers[$ _event];
        
        
        if (_script_id != undefined)
        {
            /* handle gml methods directly (registered via add_event_handler) */
            if (is_method(_script_id))
            {
                _script_id(_data);
            }
            /* handle proglang closures (registered via .ui event syntax) */
            else
            {
                var _context = {
                    element: self,
                    element_name: element_name,
                    event: _event,
                    data: _data
                }
                
                
                /* merge with link context */
                if (link_context != undefined)
                {
                    var _link_names = struct_get_names(link_context);
                    var _link_count = array_length(_link_names);
                    
                    
                    for (var i = _link_count - 1; i >= 0; --i)
                    {
                        _context[$ _link_names[i]] = link_context[$ _link_names[i]];
                    }
                }
                
                
                proglang_runtime_call(_script_id, [], _context);
            }
        }
    }
    
    
    /* =============================================================================
       layout system
       ============================================================================= */
    
    /* set padding (single value or individual sides) */
    /* @param {real|struct} _padding padding value or struct with top/right/bottom/left */
    static set_padding = function(_padding)
    {
        if (is_struct(_padding))
        {
            padding_top = _padding[$ "top"] ?? 0;
            padding_right = _padding[$ "right"] ?? 0;
            padding_bottom = _padding[$ "bottom"] ?? 0;
            padding_left = _padding[$ "left"] ?? 0;
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
    
    
    /* layout children based on layout mode */
    static layout_children = function()
    {
        if (array_length(children) == 0)
        {
             exit;
        }
        
        
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
            
            
            if !(_child.visible) continue;
            
            
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
            
            
            if !(_child.visible) continue;
            
            
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
            
            
            if !(_child.visible) continue;
            
            
            _child.x = padding_left + (_col * (_child.width + spacing));
            _child.y = padding_top + (_row * (_child.height + spacing));
            
            
            ++_col;
            
            if (_col >= grid_columns)
            {
                _col = 0;
                
                ++_row;
            }
        }
    }
    
    
    /* =============================================================================
       override GUIComponent methods
       ============================================================================= */
    
    /* get absolute x position in logical units (960-based) */
    static get_absolute_x = function()
    {
        if (parent != undefined)
        {
            return parent.get_absolute_x() + x;
        }
        
        return x;
    }
    
    
    /* get absolute y position in logical units (960-based) */
    static get_absolute_y = function()
    {
        if (parent != undefined)
        {
            return parent.get_absolute_y() + y;
        }
        
        return y;
    }
    
    
    /* get physics/interaction y position, factoring in scroll offsets */
    static get_interaction_y = function()
    {
        var _scroll_offset = 0;
        
        if (parent != undefined)
        {
            if (instanceof(parent) == "UIScrollArea")
            {
                _scroll_offset = parent.scroll_offset;
            }
            
            return parent.get_interaction_y() + y - _scroll_offset;
        }
        
        return y - _scroll_offset;
    }
    
    
    static update = function()
    {
        if !(visible) exit;
        
        
        /* update children */
        var _child_count = array_length(children);
        
        for (var i = _child_count - 1; i >= 0; --i)
        {
            children[i].update();
        }
        
        
        /* update bindings each frame */
        update_bindings();
    }
    
    
    /* custom drawing for the element. overridden by subclasses. */
    static draw_content = function()
    {
        /* default implementation does nothing */
    }
    
    
    static draw = function()
    {
        if !(visible) exit;
        
        
        var _base_scale = ui_get_base_scale();
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        
        var _x1 = _abs_x * _base_scale.x;
        var _y1 = _abs_y * _base_scale.y;
        
        var _x2 = _x1 + (width * _base_scale.x);
        var _y2 = _y1 + (height * _base_scale.y);


        /* draw background if set */
        if (background_color != undefined)
        {
            draw_set_alpha(background_alpha);
            
            draw_rectangle_colour(_x1, _y1, _x2, _y2, background_color, background_color, background_color, background_color, false);
            
            draw_set_alpha(1);
        }
        
        
        /* draw border if set */
        if (border_color != undefined && border_width > 0)
        {
            draw_rectangle_colour(_x1, _y1, _x2, _y2, border_color, border_color, border_color, border_color, true);
        }
        
        
        /* draw content */
        draw_content();
        
        
        /* execute custom draw callback if set */
        if (on_draw != undefined)
        {
            on_draw(_x1, _y1, _base_scale.x, _base_scale.y);
        }
        
        
        /* draw children */
        var _child_count = array_length(children);
        
        
        for (var i = _child_count - 1; i >= 0; --i)
        {
            children[i].draw();
        }
    }
}
