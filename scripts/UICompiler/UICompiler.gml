/// @desc UI Compiler - compiles AST to UIDefinition
/// @param {Struct} _variables Optional pre-defined variables

function UICompiler(_variables = {}) constructor
{
    variables = _variables;   // Variable scope
    had_error = false;
    error = "";
    
    /// @desc Compile a UI AST file to definitions
    /// @param {Struct.UIASTFile} _ast The AST to compile
    /// @returns {Struct.UICompileResult} Compilation result
    static compile = function(_ast)
    {
        var _result = new UICompileResult();
        
        // First pass: compile variables
        for (var i = 0; i < array_length(_ast.variables); ++i)
        {
            var _var = _ast.variables[i];
            var _value = resolve_value(_var.value);
            variables[$ _var.name] = _value;
            _result.variables[$ _var.name] = _value;
        }
        
        // Second pass: compile elements
        for (var i = 0; i < array_length(_ast.elements); ++i)
        {
            var _element = _ast.elements[i];
            var _def = compile_element(_element);
            
            if (had_error)
            {
                _result.success = false;
                _result.error = error;
                return _result;
            }
            
            _result.definitions[$ _def.name] = _def;
        }
        
        return _result;
    }
    
    /// @desc Compile an element AST node to UIDefinition
    /// @param {Struct.UIASTElement} _ast The element AST
    /// @returns {Struct.UIDefinition} The compiled definition
    static compile_element = function(_ast)
    {
        var _element_type = map_element_type(_ast.element_type);
        var _def = new UIDefinition(_ast.name, _element_type);
        
        // Compile properties
        for (var i = 0; i < array_length(_ast.properties); ++i)
        {
            var _prop = _ast.properties[i];
            compile_property(_def, _prop);
            
            if (had_error) return _def;
        }
        
        // Compile children
        for (var i = 0; i < array_length(_ast.children); ++i)
        {
            var _child_ast = _ast.children[i];
            var _child_def = compile_element(_child_ast);
            
            if (had_error) return _def;
            
            array_push(_def.children, _child_def);
        }
        
        return _def;
    }
    
    /// @desc Map string element type to enum
    static map_element_type = function(_type_str)
    {
        switch (string_lower(_type_str))
        {
            case "area":    return UI_ELEMENT_TYPE.AREA;
            case "window":  return UI_ELEMENT_TYPE.WINDOW;
            case "popup":   return UI_ELEMENT_TYPE.POPUP;
            case "page":    return UI_ELEMENT_TYPE.PAGE;
            case "scroll":  return UI_ELEMENT_TYPE.SCROLL;
            case "text":    return UI_ELEMENT_TYPE.TEXT;
            case "button":  return UI_ELEMENT_TYPE.BUTTON;
            case "textbox": return UI_ELEMENT_TYPE.TEXTBOX;
            case "image":   return UI_ELEMENT_TYPE.IMAGE;
            case "bar":     return UI_ELEMENT_TYPE.BAR;
            case "slider":  return UI_ELEMENT_TYPE.SLIDER;
            default:        return UI_ELEMENT_TYPE.AREA;
        }
    }
    
    /// @desc Compile a property and apply it to the definition
    static compile_property = function(_def, _prop)
    {
        var _key = _prop.key;
        var _value_ast = _prop.value;
        
        // Check if this is a binding
        if (_value_ast.type == UI_AST.BINDING)
        {
            _def.bindings[$ _key] = _value_ast.name;
            return;
        }
        
        // Check if this is an event (script reference)
        if (_value_ast.type == UI_AST.SCRIPT_REF && is_event_property(_key))
        {
            _def.events[$ _key] = _value_ast.script_id;
            return;
        }
        
        // Resolve the value
        var _resolved = resolve_value(_value_ast);
        
        // Apply to definition based on property name
        switch (_key)
        {
            // Size properties
            case "width":
                _def.width = resolve_size_value(_value_ast);
                break;
            case "height":
                _def.height = resolve_size_value(_value_ast);
                break;
            case "size":
                if (_value_ast.type == UI_AST.TUPLE && array_length(_value_ast.values) >= 2)
                {
                    _def.width = resolve_size_value(_value_ast.values[0]);
                    _def.height = resolve_size_value(_value_ast.values[1]);
                }
                break;
            case "min_width":
                _def.min_width = _resolved;
                break;
            case "min_height":
                _def.min_height = _resolved;
                break;
            case "max_width":
                _def.max_width = _resolved;
                break;
            case "max_height":
                _def.max_height = _resolved;
                break;
            
            // Position
            case "x":
                _def.x = _resolved;
                break;
            case "y":
                _def.y = _resolved;
                break;
            
            // Layout
            case "layout":
                _def.layout = resolve_layout(_resolved);
                break;
            case "spacing":
                _def.spacing = _resolved;
                break;
            case "justify":
                _def.justify = resolve_align(_resolved);
                break;
            case "align":
                _def.align = resolve_align(_resolved);
                break;
            
            // Padding/Margin
            case "padding":
                _def.padding = resolve_spacing(_value_ast);
                break;
            case "margin":
                _def.margin = resolve_spacing(_value_ast);
                break;
            
            // Styling
            case "background":
                _def.background = resolve_color_value(_value_ast);
                break;
            case "border":
                _def.border = resolve_border_value(_value_ast);
                break;
            case "corner_radius":
                _def.corner_radius = _resolved;
                break;
            
            // Text
            case "text":
                if (_value_ast.type == UI_AST.LOCALE)
                {
                    _def.text = { type: "locale", key: _value_ast.key };
                }
                else if (_value_ast.type == UI_AST.BINDING)
                {
                    _def.bindings[$ "text"] = _value_ast.name;
                }
                else
                {
                    _def.text = _resolved;
                }
                break;
            case "text_colour":
            case "text_color":
                _def.text_colour = _resolved;
                break;
            case "text_scale":
                _def.text_scale = _resolved;
                break;
            case "text_align":
                _def.text_align = resolve_text_align(_resolved);
                break;
            
            // Image
            case "sprite":
                _def.sprite = _resolved;
                break;
            case "surface":
                if (_value_ast.type == UI_AST.BINDING)
                {
                    _def.surface_binding = _value_ast.name;
                }
                break;
            case "image_index":
                _def.image_index = _resolved;
                break;
            case "scale_mode":
                _def.scale_mode = resolve_scale_mode(_resolved);
                break;
            
            // Window
            case "movable":
                _def.movable = _resolved;
                break;
            case "resizable":
                _def.resizable = _resolved;
                break;
            case "title":
                if (_value_ast.type == UI_AST.LOCALE)
                {
                    _def.title = { type: "locale", key: _value_ast.key };
                }
                else
                {
                    _def.title = _resolved;
                }
                break;
            case "closable":
                _def.closable = _resolved;
                break;
            
            // Input
            case "placeholder":
                if (_value_ast.type == UI_AST.LOCALE)
                {
                    _def.placeholder = { type: "locale", key: _value_ast.key };
                }
                else
                {
                    _def.placeholder = _resolved;
                }
                break;
            case "max_length":
                _def.max_length = _resolved;
                break;
            case "mode":
                _def.input_mode = _resolved;
                break;
            case "allowed_chars":
                _def.allowed_chars = _resolved;
                break;
            
            // State
            case "visible":
                _def.visible = _resolved;
                break;
            case "enabled":
                _def.enabled = _resolved;
                break;
            case "flex":
                _def.flex = _resolved;
                break;
            case "anchor":
                _def.anchor = resolve_anchor(_value_ast);
                break;
            
            // Transitions
            case "transition_in":
                if (_value_ast.type == UI_AST.TRANSITION)
                {
                    _def.transition_in = {
                        type: _value_ast.transition_type,
                        duration: _value_ast.duration
                    };
                }
                break;
            case "transition_out":
                if (_value_ast.type == UI_AST.TRANSITION)
                {
                    _def.transition_out = {
                        type: _value_ast.transition_type,
                        duration: _value_ast.duration
                    };
                }
                break;
            
            // Generic property storage
            default:
                _def.properties[$ _key] = _resolved;
                break;
        }
    }
    
    /// @desc Check if a property name is an event handler
    static is_event_property = function(_name)
    {
        return string_pos("on_", _name) == 1;
    }
    
    /// @desc Resolve a size value (may be percentage)
    static resolve_size_value = function(_ast)
    {
        if (_ast.type == UI_AST.PERCENTAGE)
        {
            return new UISizeValue(_ast.value, true);
        }
        
        var _val = resolve_value(_ast);
        return new UISizeValue(_val, false);
    }
    
    /// @desc Resolve an AST value to a concrete value
    static resolve_value = function(_ast)
    {
        switch (_ast.type)
        {
            case UI_AST.VALUE:
                // If it's an identifier, look up in variables
                if (_ast.value_type == "identifier")
                {
                    var _var_val = variables[$ _ast.value];
                    if (_var_val != undefined)
                    {
                        return _var_val;
                    }
                    return _ast.value; // Return as string if not found
                }
                return _ast.value;
            
            case UI_AST.PERCENTAGE:
                return _ast.value; // Just the number, percentage flag handled elsewhere
            
            case UI_AST.CONSTANT:
                return _ast.name;
            
            case UI_AST.TUPLE:
                var _values = [];
                for (var i = 0; i < array_length(_ast.values); ++i)
                {
                    array_push(_values, resolve_value(_ast.values[i]));
                }
                return _values;
            
            case UI_AST.LOCALE:
                return { type: "locale", key: _ast.key };
            
            case UI_AST.SCRIPT_REF:
                return _ast.script_id;
            
            case UI_AST.TRANSITION:
                return { type: _ast.transition_type, duration: _ast.duration };
            
            case UI_AST.HEX_COLOR:
                return _ast.color;  // Already a GML color value
            
            default:
                return undefined;
        }
    }
    
    /// @desc Resolve layout constant to string
    static resolve_layout = function(_val)
    {
        if (is_string(_val))
        {
            switch (string_upper(_val))
            {
                case "LAYOUT_VERTICAL":   return "vertical";
                case "LAYOUT_HORIZONTAL": return "horizontal";
                case "LAYOUT_GRID":       return "grid";
                case "LAYOUT_BLOCK":      return "block";
            }
        }
        return _val;
    }
    
    /// @desc Resolve alignment constant
    static resolve_align = function(_val)
    {
        if (is_string(_val))
        {
            switch (string_upper(_val))
            {
                case "ALIGN_START":         return "start";
                case "ALIGN_CENTER":        return "center";
                case "ALIGN_END":           return "end";
                case "ALIGN_LEFT":          return "start";
                case "ALIGN_RIGHT":         return "end";
                case "ALIGN_SPACE_BETWEEN": return "space_between";
                case "ALIGN_SPACE_AROUND":  return "space_around";
            }
        }
        return _val;
    }
    
    /// @desc Resolve text alignment
    static resolve_text_align = function(_val)
    {
        if (is_string(_val))
        {
            switch (string_upper(_val))
            {
                case "ALIGN_LEFT":   return fa_left;
                case "ALIGN_CENTER": return fa_center;
                case "ALIGN_RIGHT":  return fa_right;
            }
        }
        return _val;
    }
    
    /// @desc Resolve scale mode constant
    static resolve_scale_mode = function(_val)
    {
        if (is_string(_val))
        {
            return string_upper(_val); // FIT, FILL, STRETCH, NONE
        }
        return _val;
    }
    
    /// @desc Resolve spacing value (padding/margin)
    static resolve_spacing = function(_ast)
    {
        if (_ast.type == UI_AST.TUPLE)
        {
            var _vals = [];
            for (var i = 0; i < array_length(_ast.values); ++i)
            {
                array_push(_vals, resolve_value(_ast.values[i]));
            }
            return _vals; // [top, right, bottom, left] or [top/bottom, left/right]
        }
        
        var _val = resolve_value(_ast);
        return [_val, _val, _val, _val]; // All sides same
    }
    
    /// @desc Resolve color value
    static resolve_color_value = function(_ast)
    {
        if (_ast.type == UI_AST.TUPLE)
        {
            var _vals = resolve_value(_ast);
            if (array_length(_vals) >= 2)
            {
                return { color: _vals[0], alpha: _vals[1] };
            }
        }
        return { color: resolve_value(_ast), alpha: 1 };
    }
    
    /// @desc Resolve border value
    static resolve_border_value = function(_ast)
    {
        if (_ast.type == UI_AST.TUPLE)
        {
            var _vals = resolve_value(_ast);
            if (array_length(_vals) >= 2)
            {
                return { color: _vals[0], width: _vals[1] };
            }
        }
        return { color: resolve_value(_ast), width: 1 };
    }
    
    /// @desc Resolve anchor value
    static resolve_anchor = function(_ast)
    {
        if (_ast.type == UI_AST.TUPLE)
        {
            var _vals = [];
            for (var i = 0; i < array_length(_ast.values); ++i)
            {
                array_push(_vals, resolve_align(resolve_value(_ast.values[i])));
            }
            return _vals;
        }
        return undefined;
    }
}
