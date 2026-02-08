/// @desc Spawn a UI element hierarchy from definitions
/// @param {Array<Struct.UIDefinition>|Struct.UIDefinition} _definitions Definition(s) with optional links
/// @returns {Struct.UIElement} The root element(s)
function ui_spawn(_definitions)
{
    // Normalize to array
    if (!is_array(_definitions))
    {
        _definitions = [_definitions];
    }
    
    if (array_length(_definitions) == 0)
    {
        return undefined;
    }
    
    // Spawn each definition
    var _elements = [];
    for (var i = 0; i < array_length(_definitions); ++i)
    {
        var _def = _definitions[i];
        var _element = ui_spawn_element(_def, undefined, _def._pending_links);
        if (_element != undefined)
        {
            array_push(_elements, _element);
        }
    }
    
    // Return single element or array
    if (array_length(_elements) == 1)
    {
        return _elements[0];
    }
    return _elements;
}

/// @desc Spawn a single UI element from a definition
/// @param {Struct.UIDefinition} _def The definition
/// @param {Struct.UIElement} _parent Optional parent element
/// @param {Struct} _links Link resolvers
/// @returns {Struct.UIElement} The spawned element
function ui_spawn_element(_def, _parent = undefined, _links = {})
{
    // Create the appropriate element type
    var _element = undefined;
    
    switch (_def.element_type)
    {
        case UI_ELEMENT_TYPE.AREA:
        case UI_ELEMENT_TYPE.WINDOW:
        case UI_ELEMENT_TYPE.POPUP:
        case UI_ELEMENT_TYPE.PAGE:
            _element = new UIBox(_def.name);
            break;
        
        case UI_ELEMENT_TYPE.TEXT:
            var _text = ui_resolve_text(_def.text, _links, _def.bindings);
            _element = new UIText(_def.name, _text);
            break;
        
        case UI_ELEMENT_TYPE.BUTTON:
            var _text = ui_resolve_text(_def.text, _links, _def.bindings);
            _element = new UIButton(_def.name, _text);
            break;
        
        case UI_ELEMENT_TYPE.TEXTBOX:
            _element = new UIInputField(_def.name);
            break;
        
        case UI_ELEMENT_TYPE.IMAGE:
            _element = new UIImage(_def.name, _def.sprite);
            break;
        
        default:
            _element = new UIBox(_def.name);
            break;
    }
    
    // Apply common properties
    ui_apply_properties(_element, _def, _links);
    
    // Spawn children
    for (var i = 0; i < array_length(_def.children); ++i)
    {
        var _child_def = _def.children[i];
        var _child = ui_spawn_element(_child_def, _element, _links);
        if (_child != undefined)
        {
            _element.add_child(_child);
        }
    }
    
    // Wire up events
    ui_wire_events(_element, _def);
    
    // Set up bindings (reactive updates)
    ui_setup_bindings(_element, _def, _links);
    
    return _element;
}

/// @desc Apply definition properties to an element
function ui_apply_properties(_element, _def, _links)
{
    // Size (with percentage resolution deferred to parent)
    if (_def.width != undefined)
    {
        _element._ui_width_def = _def.width;
        if (!_def.width.is_percentage)
        {
            _element.width = _def.width.value;
        }
    }
    if (_def.height != undefined)
    {
        _element._ui_height_def = _def.height;
        if (!_def.height.is_percentage)
        {
            _element.height = _def.height.value;
        }
    }
    
    // Position
    _element.x = _def.x;
    _element.y = _def.y;
    
    // Layout
    if (_def.layout != undefined)
    {
        switch (_def.layout)
        {
            case "vertical":
                _element.layout = UI_LAYOUT.FLEX_COLUMN;
                break;
            case "horizontal":
                _element.layout = UI_LAYOUT.FLEX_ROW;
                break;
            default:
                _element.layout = UI_LAYOUT.BLOCK;
                break;
        }
    }
    
    if (_def.spacing != undefined)
    {
        _element.spacing = _def.spacing;
    }
    
    if (_def.justify != undefined)
    {
        _element.justify_content = ui_resolve_ui_align(_def.justify);
    }
    
    if (_def.align != undefined)
    {
        _element.align_items = ui_resolve_ui_align(_def.align);
    }
    
    // Padding
    if (_def.padding != undefined)
    {
        if (is_array(_def.padding))
        {
            var _p = _def.padding;
            var _len = array_length(_p);
            if (_len >= 4)
            {
                _element.padding_top = _p[0];
                _element.padding_right = _p[1];
                _element.padding_bottom = _p[2];
                _element.padding_left = _p[3];
            }
            else if (_len >= 2)
            {
                _element.padding_top = _p[0];
                _element.padding_bottom = _p[0];
                _element.padding_left = _p[1];
                _element.padding_right = _p[1];
            }
            else if (_len >= 1)
            {
                _element.padding_top = _p[0];
                _element.padding_right = _p[0];
                _element.padding_bottom = _p[0];
                _element.padding_left = _p[0];
            }
        }
        else
        {
            _element.padding_top = _def.padding;
            _element.padding_right = _def.padding;
            _element.padding_bottom = _def.padding;
            _element.padding_left = _def.padding;
        }
    }
    
    // Styling (for UIBox-based elements)
    if (variable_struct_exists(_element, "background_color"))
    {
        if (_def.background != undefined)
        {
            _element.background_color = _def.background.color;
            _element.background_alpha = _def.background.alpha ?? 1;
        }
        if (_def.corner_radius != undefined)
        {
            _element.corner_radius = _def.corner_radius;
        }
    }
    
    // Text properties (for UIText/UIButton)
    if (variable_struct_exists(_element, "text_color"))
    {
        if (_def.text_colour != undefined)
        {
            _element.text_color = _def.text_colour;
        }
    }
    if (variable_struct_exists(_element, "text_scale"))
    {
        if (_def.text_scale != undefined)
        {
            _element.text_scale = _def.text_scale;
        }
    }
    
    // Textbox-specific properties (for UIInputField)
    if (_def.element_type == UI_ELEMENT_TYPE.TEXTBOX)
    {
        // Placeholder
        if (_def.placeholder != undefined)
        {
            if (is_struct(_def.placeholder) && _def.placeholder[$ "type"] == "locale")
            {
                _element.placeholder = loca_translate(_def.placeholder.key);
            }
            else
            {
                _element.placeholder = string(_def.placeholder);
            }
        }
        
        // Max length
        if (_def.max_length != undefined)
        {
            _element.max_length = _def.max_length;
        }
        
        // Input mode (string, integer, etc.)
        if (_def.input_mode != undefined)
        {
            switch (_def.input_mode)
            {
                case "MODE_INTEGER":
                    _element.numeric_only = true;
                    _element.allowed_chars = "-0123456789";
                    break;
                case "MODE_STRING":
                default:
                    _element.numeric_only = false;
                    break;
            }
        }
        
        // Allowed characters
        if (_def.allowed_chars != undefined)
        {
            _element.allowed_chars = _def.allowed_chars;
        }
    }
    
    // Visibility & state
    _element.visible = _def.visible;
    _element.enabled = _def.enabled;
    
    // Flex
    if (_def.flex != undefined)
    {
        _element.flex = _def.flex;
    }
    
    // Store definition reference for bindings
    _element._ui_definition = _def;
}

/// @desc Resolve text value (may be locale or binding)
function ui_resolve_text(_text, _links, _bindings)
{
    if (_text == undefined) return "";
    
    // Locale
    if (is_struct(_text) && _text.type == "locale")
    {
        return loca_translate(_text.key);
    }
    
    // Check if text has a binding
    var _binding_key = _bindings[$ "text"];
    if (_binding_key != undefined)
    {
        var _resolver = _links[$ _binding_key];
        if (_resolver != undefined)
        {
            return _resolver();
        }
    }
    
    return string(_text);
}

/// @desc Resolve alignment string to UI_ALIGN enum
function ui_resolve_ui_align(_align_str)
{
    switch (_align_str)
    {
        case "start":         return UI_ALIGN.START;
        case "center":        return UI_ALIGN.CENTER;
        case "end":           return UI_ALIGN.END;
        case "space_between": return UI_ALIGN.SPACE_BETWEEN;
        case "space_around":  return UI_ALIGN.SPACE_AROUND;
        default:              return UI_ALIGN.START;
    }
}

/// @desc Wire up event handlers from definition to element
function ui_wire_events(_element, _def)
{
    var _event_keys = struct_get_names(_def.events);
    
    for (var i = 0; i < array_length(_event_keys); ++i)
    {
        var _event_name = _event_keys[i];
        var _script_id = _def.events[$ _event_name];
        
        // Strip leading @ if present (consistent with function_execute)
        if (string_pos("@", _script_id) == 1)
        {
            _script_id = string_delete(_script_id, 1, 1);
        }
        
        // Create a closure that calls the Proglang script
        var _handler = method({ script_id: _script_id, element: _element }, function(_self) {
            // Find the root element to get UI context (stored by open_ui)
            var _root = element;
            while (_root._parent != undefined)
            {
                _root = _root._parent;
            }
            
            // Get context from root element (set by open_ui)
            var _context = _root._ui_context ?? {};
            
            // Extract tile coordinates from context for Proglang scripts
            var _tile = _context[$ "tile"];
            var _x = 0, _y = 0, _z = 0;
            if (_tile != undefined)
            {
                _x = _tile.x ?? 0;
                _y = _tile.y ?? 0;
                _z = _tile.z ?? 0;
            }
            
            // Execute the Proglang script with element and tile context
            if (struct_exists(global.proglang_scripts, script_id))
            {
                proglang_call(script_id, [], { element: element, tile: _tile });
            }
            else
            {
                // Try executing as a dynamic script (file-based)
                function_execute({ id: "@" + script_id, parameters: {} }, _x, _y, _z);
            }
        });
        
        // Map event names to element callbacks
        switch (_event_name)
        {
            case "on_click":
                _element.on_click = _handler;
                break;
            case "on_press":
                _element.on_press = _handler;
                break;
            case "on_release":
                _element.on_release = _handler;
                break;
            case "on_select_release":
                _element.on_select_release = _handler;
                break;
            case "on_hover_enter":
                _element.on_hover_enter = _handler;
                break;
            case "on_hover_exit":
                _element.on_hover_exit = _handler;
                break;
            case "on_focus":
                _element.on_focus = _handler;
                break;
            case "on_blur":
                _element.on_blur = _handler;
                break;
            case "on_change":
                if (variable_struct_exists(_element, "on_change"))
                {
                    _element.on_change = _handler;
                }
                break;
            case "on_submit":
                if (variable_struct_exists(_element, "on_submit"))
                {
                    _element.on_submit = _handler;
                }
                break;
        }
    }
}

/// @desc Set up reactive bindings for an element
function ui_setup_bindings(_element, _def, _links)
{
    var _binding_keys = struct_get_names(_def.bindings);
    
    if (array_length(_binding_keys) == 0) return;
    
    // Store binding info on element for updates
    _element._ui_bindings = [];
    _element._ui_setters = {};
    
    for (var i = 0; i < array_length(_binding_keys); ++i)
    {
        var _prop_name = _binding_keys[i];
        var _binding_key = _def.bindings[$ _prop_name];
        var _resolver = _links[$ _binding_key];
        var _setter = _links[$ _binding_key + "_setter"];
        
        if (_resolver != undefined)
        {
            array_push(_element._ui_bindings, {
                property: _prop_name,
                resolver: _resolver,
                setter: _setter
            });
            
            // Store setter for this property
            if (_setter != undefined)
            {
                _element._ui_setters[$ _prop_name] = _setter;
            }
            
            // Initialize textbox text from binding
            if (_prop_name == "text" && _def.element_type == UI_ELEMENT_TYPE.TEXTBOX)
            {
                var _initial_value = _resolver();
                if (_initial_value != undefined)
                {
                    _element.text = string(_initial_value);
                    _element.cursor_position = string_length(_element.text);
                }
                
                // Wire up on_change to call the setter
                if (_setter != undefined)
                {
                    var _setter_ref = _setter;
                    var _old_on_change = _element.on_change;
                    _element.on_change = method({ setter: _setter_ref, old_handler: _old_on_change }, 
                        function(_self, _text) {
                            // Call the setter with the new text value
                            setter(_text);
                            
                            // Call original on_change if it existed
                            if (old_handler != undefined)
                            {
                                old_handler(_self, _text);
                            }
                        }
                    );
                }
            }
        }
    }
    
    // Add custom update function for reactive bindings (except textboxes - they update via user input)
    var _is_textbox = (_def.element_type == UI_ELEMENT_TYPE.TEXTBOX);
    
    if (array_length(_element._ui_bindings) > 0 && !_is_textbox)
    {
        var _old_update = _element.update;
        _element.update = method(_element, function() {
            // Update bindings
            for (var i = 0; i < array_length(_ui_bindings); ++i)
            {
                var _binding = _ui_bindings[i];
                var _new_value = _binding.resolver();
                
                switch (_binding.property)
                {
                    case "text":
                        if (variable_struct_exists(self, "set_text"))
                        {
                            set_text(string(_new_value));
                        }
                        break;
                    case "visible":
                        visible = _new_value;
                        break;
                    case "enabled":
                        enabled = _new_value;
                        break;
                }
            }
            
            // Call original update
            if (_old_update != undefined)
            {
                _old_update();
            }
        });
    }
}

