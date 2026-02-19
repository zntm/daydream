/* UI Runtime - handles loading, spawning, and managing UI instances */
/* Central system for the declarative UI language */

/* Global UI definition cache */
global.ui_definitions = {}

/* Global UI instance registry */
global.ui_instances = {}
global.ui_instance_counter = 0;

/* Global UI event bus - tracks which events have been fired this frame */
global.ui_pending_events = {}

/// @desc Load and parse a UI file, returning definitions
/// @param {String} _path Path to .ui file
/// @returns {Struct.UIASTDocument} Parsed UI document
function ui_load(_path)
{
    /* Check cache first */
    if (struct_exists(global.ui_definitions, _path))
    {
        show_debug_message($"[UI Runtime] Using cached definition for: {_path}");
        
        return global.ui_definitions[$ _path];
    }
    
    /* Resolve full path - UI files are in resources/data/ui/ */
    var _full_path = _path;
    var _resources = PROGRAM_DIRECTORY_RESOURCES;
    
    if (_resources != "")
    {
        _full_path = $"{_resources}/data/{_path}";
    }
    
    show_debug_message($"[UI Runtime] Attempting to load UI file: '{_path}' -> '{_full_path}' (cwd: {working_directory})");
    show_debug_message($"[UI Runtime] File exists (full): {file_exists(_full_path)}");
    
    /* Load file contents */
    var _source = buffer_load_text(_full_path);
    
    /* Fallback: Try relative path directly if full path failed */
    if (_source == undefined && _full_path != _path)
    {
        show_debug_message($"[UI Runtime] Falling back to relative path: '{_path}'");
        show_debug_message($"[UI Runtime] File exists (rel): {file_exists(_path)}");
        
        _source = buffer_load_text(_path);
    }
    
    if (_source == undefined || _source == "")
    {
        show_debug_message($"[UI Runtime] ERROR: Failed to load UI file content from: {_full_path} OR {_path}");
        
        return undefined;
    }
    
    /* Tokenize */
    var _lexer = new UILexer(_source);
    var _tokens = _lexer.tokenize();
    
    if (_lexer.had_error)
    {
        show_debug_message($"[UI Runtime] Lexer error in {_path}: {_lexer.error}");
        
        return undefined;
    }
    
    /* Parse */
    var _parser = new UIParser(_tokens);
    var _document = _parser.parse();
    
    if (_parser.had_error)
    {
        show_debug_message($"[UI Runtime] Parser error in {_path}: {_parser.error}");
        
        return undefined;
    }
    
    /* Cache and return */
    var _ui_def = {
        document: _document,
        variables: _parser.variables
    }
    
    /* Expose top-level elements by name for importing in Daydream */
    var _defs = _document.definitions;
    var _exports = {}
    
    for (var i = array_length(_defs) - 1; i >= 0; --i)
    {
        var _el = _defs[i];
        
        if (is_struct(_el))
        {
            if (_el.type == UI_AST.ELEMENT)
            {
                _ui_def[$ _el.name] = _el;
                _el.variables = _parser.variables;
            }
            /* Collect exports */
            else if (_el.type == UI_AST.EXPORT_VAR)
            {
                _exports[$ _el.name] = _el.value;
            }
            else if (_el.type == UI_AST.EXPORT_ELEMENT && is_struct(_el.element))
            {
                _exports[$ _el.element.name] = _el.element;
                _ui_def[$ _el.element.name] = _el.element;
                _el.element.variables = _parser.variables;
            }
        }
    }
    
    _ui_def.exports = _exports;
    
    global.ui_definitions[$ _path] = _ui_def;
    
    show_debug_message($"[UI Runtime] Successfully loaded UI file: {_full_path}");
    
    return _ui_def;
}

/// @desc Spawn UI instances from definitions
/// @param {Array} _definitions Array of element names or AST elements to spawn  
/// @param {Struct} _config Configuration including link context
/// @param {Array|undefined} _events Optional array of event strings that trigger re-renders
/// @returns {Struct} UI instance with spawned elements
function ui_spawn(_definitions, _config = {}, _events = undefined)
{
    /* Handle ui_load() result struct (has .document property) */
    if (is_struct(_definitions) && struct_exists(_definitions, "document"))
    {
        var _doc = _definitions.document;
        
        _definitions = _doc.definitions;
    }
    
    /* Normalize definitions to an array if it's a single struct */
    if (is_struct(_definitions) && struct_exists(_definitions, "type") && _definitions.type == UI_AST.ELEMENT)
    {
        _definitions = [_definitions];
    }
    
    var _def_count = array_length(_definitions);
    var _parent_name = is_struct(_config.parent) && struct_exists(_config.parent, "element_name") ? _config.parent.element_name : "unknown";
    
    show_debug_message($"[UI Runtime] ui_spawn: Spawning {_def_count} definitions into parent '{_parent_name}'");
    
    /* Fallback for empty or invalid input */
    if (!is_array(_definitions))
    {
        show_debug_message("[UI Runtime] Warning: ui_spawn called with invalid definitions.");
        
        return undefined;
    }
    
    var _link = _config[$ "link"] ?? {}
    var _parent = _config[$ "parent"] ?? undefined;
    
    var _instance = {
        id: global.ui_instance_counter++,
        elements: {},
        root_elements: [],
        link_context: _link,
        render_events: _events,   /* Array of event strings, or undefined for every-frame */
        dirty: true,              /* Start dirty so first frame always renders */
        visible: true             /* Control visibility of all root elements */
    }
        
    /* Get variables from definition if available */
    var _variables = {}
    
    if (is_struct(_definitions) && struct_exists(_definitions, "variables"))
    {
        _variables = _definitions.variables;
    }
    
    for (var i = 0; i < _def_count; ++i)
    {
        var _def = _definitions[i];
        
        if (_def == undefined)
        {
            show_debug_message($"[UI Runtime] Warning: Definition at index {i} is undefined. Check your imports.");
            
            continue;
        }
        
        /* Handle definition struct wrapping */
        if (is_struct(_def) && struct_exists(_def, "document"))
        {
            _variables = _def.variables;
            _def = _def.document.definitions;
            
            /* If it's an array of elements from the document, recurse or loop */
            if (is_array(_def))
            {
                for (var j = 0; j < array_length(_def); ++j)
                {
                    var _sub_def = _def[j];
                    var _sub_vars = _variables;
                    
                    if (is_struct(_sub_def) && struct_exists(_sub_def, "variables")) _sub_vars = _sub_def.variables;
                    
                    var _sub_element = ui_instantiate_element(_sub_def, _link, _sub_vars);
                    
                    if (_sub_element != undefined)
                    {
                        ui_process_spawned_element(_sub_element, _instance, _parent);
                    }
                }
                
                continue;
            }
        }
        
        var _element = undefined;
        
        if (is_struct(_def) && struct_exists(_def, "type"))
        {
            /* Pick up variables from the element if available */
            var _el_vars = _variables;
            
            if (struct_exists(_def, "variables")) _el_vars = _def.variables;
            
            /* It's an AST node - instantiate it */
            _element = ui_instantiate_element(_def, _link, _el_vars);
        }
        
        if (_element != undefined)
        {
            ui_process_spawned_element(_element, _instance, _parent);
        }
    }
    
    /* Store instance */
    global.ui_instances[$ string(_instance.id)] = _instance;
    
    return _instance;
}

/// @desc Internal helper to process a spawned element
function ui_process_spawned_element(_element, _instance, _parent)
{
    _element.instance_id = _instance.id;
    _element.instance = _instance;
    
    if (_parent != undefined)
    {
        /* Handle UIElement or GUIComponent parent */
        if (struct_exists(_parent, "add_child"))
        {
            _parent.add_child(_element);
        } 
        /* Handle UIInstance struct parent (result of ui_spawn) */
        else if (struct_exists(_parent, "root_elements") && array_length(_parent.root_elements) > 0)
        {
            var _actual_parent = _parent.root_elements[0];
            
            if (struct_exists(_actual_parent, "add_child"))
            {
                _actual_parent.add_child(_element);
            }
        }
        else
        {
            show_debug_message($"[UI Runtime] Warning: Parent object is incompatible (missing add_child). Element '{_element.element_name}' will be a root element.");
        }
    }
    
    array_push(_instance.root_elements, _element);
    
    _instance.elements[$ _element.element_name] = _element;
    
    /* Register all nested elements by name */
    ui_register_nested_elements(_element, _instance.elements);
}

/// @desc Recursively collect all elements with specific properties
/// @param {Struct.UIElement} _element Root element to start from
/// @param {Array} _out Array to collect matching elements into
function ui_collect_slots(_element, _out)
{
    if (struct_exists(_element, "inventory_name") && struct_exists(_element, "slot_index"))
    {
        array_push(_out, _element);
    }
    
    var _children = _element.children;
    var _count = array_length(_children);
    
    for (var i = _count - 1; i >= 0; --i)
    {
        ui_collect_slots(_children[i], _out);
    }
}

/// @desc Register nested elements by name
function ui_register_nested_elements(_element, _registry)
{
    var _child_count = array_length(_element.children);
    
    for (var i = _child_count - 1; i >= 0; --i)
    {
        var _child = _element.children[i];
        
        if (struct_exists(_child, "element_name") && _child.element_name != "")
        {
            _registry[$ _child.element_name] = _child;
        }
        
        if (struct_exists(_child, "children"))
        {
            ui_register_nested_elements(_child, _registry);
        }
    }
}

/// @desc Instantiate an element from AST node
/// @param {Struct} _node AST element node
/// @param {Struct} _link Link context
/// @param {Struct} _variables Local variable scope
/// @returns {Struct.UIElement} Instantiated element
function ui_instantiate_element(_node, _link, _variables)
{
    if (_node.type != UI_AST.ELEMENT) return undefined;
    
    var _element = undefined;
    
    /* Create element based on type */
    switch (_node.element_type)
    {
        case "text":
            _element = new UIText(0, 0, "");
            break;
        case "button":
            _element = new UIButton(0, 0, 100, 24, "");
            break;
        case "window":
            _element = new UIWindow(0, 0, 320, 180, "");
            break;
        case "area":
            _element = new UIArea(0, 0, 100, 100);
            break;
        case "image":
            _element = new UIImage(0, 0, undefined);
            break;
        case "slider":
            _element = new UISlider(0, 0, 100, 0, 100, 50);
            break;
        case "textbox":
            _element = new UITextbox(0, 0, 100, 24);
            break;
        case "bar":
            _element = new UIBar(0, 0, 100, 8, 0, 100, 50);
            break;
        case "slot":
            _element = new UISlot(0, 0);
            break;
        case "popup":
            _element = new UIPopup(0, 0, 200, 150);
            break;
        case "page":
            _element = new UIPage(0, 0, 100, 100, "");
            break;
        case "radio_button":
            _element = new UIRadioButton(0, 0, "");
            break;
        default:
            show_debug_message($"[UI Runtime] Unknown element type: {_node.element_type}");
            
            _element = new UIElement(0, 0, 100, 100);
            
            break;
    }
    
    if (_element == undefined) return undefined;
    
    _element.element_name = _node.name;
    _element.element_type = _node.element_type;
    
    _element.set_link_context(_link);
    
    /* Apply properties */
    var _prop_count = array_length(_node.properties);
    
    for (var i = 0; i < _prop_count; ++i)
    {
        var _prop = _node.properties[i];
        
        ui_apply_property(_element, _prop, _link, _variables);
    }
    
    /* Instantiate children */
    var _child_count = array_length(_node.children);
    
    for (var i = 0; i < _child_count; ++i)
    {
        var _child_node = _node.children[i];
        
        /* Handle repeat(count, var) expansion */
        if (_child_node.repeat_count != undefined)
        {
            var _repeat_count = _child_node.repeat_count;
            var _repeat_var = _child_node.repeat_var;
            var _base_name = _child_node.name;
            
            for (var j = 0; j < _repeat_count; ++j)
            {
                /* Create a copy of the variables scope with the loop variable */
                var _loop_vars = {}
                var _var_names = struct_get_names(_variables);
                
                for (var k = array_length(_var_names) - 1; k >= 0; --k)
                {
                    _loop_vars[$ _var_names[k]] = _variables[$ _var_names[k]];
                }
                
                _loop_vars[$ _repeat_var] = j;
                
                /* Override the element name for each copy */
                var _saved_name = _child_node.name;
                
                _child_node.name = _base_name + "_" + string(j);
                
                /* Temporarily clear repeat to prevent infinite recursion */
                var _saved_count = _child_node.repeat_count;
                
                _child_node.repeat_count = undefined;
                
                var _child = ui_instantiate_element(_child_node, _link, _loop_vars);
                
                /* Restore original values */
                _child_node.name = _saved_name;
                _child_node.repeat_count = _saved_count;
                
                if (_child != undefined)
                {
                    _element.add_child(_child);
                }
            }
        }
        else
        {
            var _child = ui_instantiate_element(_child_node, _link, _variables);
            
            if (_child != undefined)
            {
                _element.add_child(_child);
            }
        }
    }
    
    /* Perform layout after all children added */
    _element.layout_children();
    
    return _element;
}

/// @desc Apply a property to an element
/// @param {Struct.UIElement} _element Target element
/// @param {Struct} _prop Property AST node
/// @param {Struct} _link Link context
/// @param {Struct} _variables Local variables
function ui_apply_property(_element, _prop, _link, _variables)
{
    var _key = _prop.key;
    var _value_node = _prop.value;
    var _value = ui_resolve_value(_value_node, _link, _variables);
    
    /* Handle special properties */
    switch (_key)
    {
        case "size":
            if (is_array(_value) && array_length(_value) >= 2)
            {
                _element.width = _value[0];
                _element.height = _value[1];
            }
            break;
        
        case "position":
            if (is_array(_value) && array_length(_value) >= 2)
            {
                var _vx = _value[0];
                var _vy = _value[1];
                
                /* Auto-detect anchors from percentages */
                var _ax = undefined;
                var _ay = undefined;
                
                if (is_struct(_vx))
                {
                    var _p = _vx[$ "percent_value"] ?? _vx[$ "value"];
                    
                    if (_p == 0) _ax = "left";
                    else if (_p == 50) _ax = "center";
                    else if (_p == 100) _ax = "right";
                }
                
                if (is_struct(_vy))
                {
                    var _p = _vy[$ "percent_value"] ?? _vy[$ "value"];
                    
                    if (_p == 0) _ay = "top";
                    else if (_p == 50) _ay = "middle";
                    else if (_p == 100) _ay = "bottom";
                }
                
                if (_ax != undefined || _ay != undefined)
                {
                    _element.set_anchor(_ax ?? _element.anchor_x ?? "left", _ay ?? _element.anchor_y ?? "top");
                }
                
                /* Resolve to pixels for the offset */
                var _ref_w = 960;
                var _ref_h = 540;
                var _rx = ui_resolve_percentage(_vx, _ref_w);
                var _ry = ui_resolve_percentage(_vy, _ref_h);
                
                /* If it was a clean percentage, the offset should be 0 relative to that anchor */
                /* e.g. ORIGIN_CENTER + (10, 0) -> anchor=center, offset=10 */
                if (is_struct(_vx) && _vx[$ "is_calc"] == true)
                {
                    _rx = _vx.absolute_offset;
                }
                else if (is_struct(_vx) && _vx[$ "is_percent"] == true)
                {
                    _rx = 0;
                }
                
                if (is_struct(_vy) && _vy[$ "is_calc"] == true)
                {
                    _ry = _vy.absolute_offset;
                }
                else if (is_struct(_vy) && _vy[$ "is_percent"] == true)
                {
                    _ry = 0;
                }

                _element.offset_x = _rx;
                _element.offset_y = _ry;
                _element.x = _rx;
                _element.y = _ry;
                
                _element.recalculate_layout();
            }
            break;
            
        case "anchor":
            if (is_array(_value) && array_length(_value) >= 2)
            {
                var _ax = _value[0];
                var _ay = _value[1];
                
                /* Support both ORIGIN_* aliases and raw strings */
                if (is_array(_ax)) _ax = "center"; /* fallback for weirdness */
                if (is_array(_ay)) _ay = "middle";
                
                _element.set_anchor(_ax, _ay);
            }
            break;
        
        case "layout":
            if (is_string(_value))
            {
                switch (_value)
                {
                    case "LAYOUT_VERTICAL": _element.layout = UI_LAYOUT.VERTICAL; break;
                    case "LAYOUT_HORIZONTAL": _element.layout = UI_LAYOUT.HORIZONTAL; break;
                    case "LAYOUT_GRID": _element.layout = UI_LAYOUT.GRID; break;
                    default: _element.layout = UI_LAYOUT.NONE; break;
                }
            }
            break;
        
        case "padding":
            _element.set_padding(_value);
            break;
        
        case "spacing":
            _element.spacing = _value;
            break;
        
        case "grid_columns":
            _element.grid_columns = floor(_value);
            break;
            
        case "smooth":
            if (struct_exists(_element, "set_smooth"))
            {
                _element.set_smooth(_value);
            }
            else
            {
                _element.smooth = _value;
            }
            break;
        
        case "background":
            if (is_struct(_value) && struct_exists(_value, "color"))
            {
                _element.background_color = _value.color;
                _element.background_alpha = _value[$ "alpha"] ?? 1;
            }
            else
            {
                _element.background_color = _value;
            }
            break;
        
        case "colour":
        case "color":
            if (is_struct(_value) && struct_exists(_value, "color"))
            {
                _element.colour = _value.color;
            }
            else
            {
                _element.colour = _value;
            }
            break;
        
        default:
            /* Check for event handlers (on_*) */
            if (string_pos("on_", _key) == 1)
            {
                if (_value_node.type == UI_AST.SCRIPT_REF)
                {
                    _element.add_event_handler(_key, _value_node.script_id);
                }
            }
            /* Check for bindings */
            else if (_value_node.type == UI_AST.BINDING)
            {
                _element.add_binding(_key, _value_node.name);
            }
            /* Array-indexed binding: *name[index] — register as a callable resolver */
            else if (_value_node.type == UI_AST.ARRAY_INDEX)
            {
                var _arr_name  = _value_node.name;
                var _idx_node  = _value_node.index;
                var _captured_link = _link;
                var _captured_vars = _variables;
                
                /* wrap in a closure so update_bindings can call it each frame */
                _element.add_binding(_key, _arr_name + "[]");
                
                _element.link_context[$ _arr_name + "[]"] = method(
                    { arr_name: _arr_name, idx_node: _idx_node, lnk: _captured_link, vars: _captured_vars },
                    function()
                    {
                        var _arr = lnk[$ arr_name];
                        
                        if (is_method(_arr))
                        {
                            _arr = _arr();
                        }
                        else if (is_array(_arr) && array_length(_arr) > 0 && is_array(_arr[0]))
                        {
                            _arr = proglang_runtime_call(_arr);
                        }
                        
                        var _idx = ui_resolve_value(idx_node, lnk, vars);
                        
                        if (is_array(_arr) && _idx >= 0 && _idx < array_length(_arr))
                        {
                            return _arr[_idx];
                        }
                        
                        return undefined;
                    }
                );
            }
            /* Handle sprite definitions for sprite_empty/sprite_fill */
            else if ((_key == "sprite_empty" || _key == "sprite_fill") && is_struct(_value) && _value[$ "is_sprite_def"] == true)
            {
                var _setter_name = "set_" + _key;
                
                if (struct_exists(_element, _setter_name))
                {
                    var _setter = _element[$ _setter_name];
                    
                    if (is_callable(_setter))
                    {
                        var _m = method(_element, _setter);
                        
                        _m(_value);
                    }
                }
            }
            /* Regular property - try to set via setter or directly */
            else
            {
                /* Special handling for color values in arbitrary properties */
                var _final_value = _value;
                
                if (is_struct(_value) && struct_exists(_value, "color"))
                {
                    _final_value = _value.color;
                    /* If the property is something like 'border_color', we might also want alpha */
                    /* but most GML functions expect just the color. UIElement handles background/border specially. */
                }
                
                var _setter_name = "set_" + _key;
                
                if (struct_exists(_element, _setter_name))
                {
                    var _setter = _element[$ _setter_name];
                    
                    if (is_callable(_setter))
                    {
                        var _m = method(_element, _setter);
                        
                        _m(_final_value);
                    }
                }
                else if (struct_exists(_element, _key))
                {
                    _element[$ _key] = _final_value;
                }
            }
            break;
    }
}

/// @desc Resolve a value AST node to a runtime value
/// @param {Struct} _node Value AST node
/// @param {Struct} _link Link context
/// @param {Struct} _variables Local variables
/// @returns {Any} Resolved value
function ui_resolve_value(_node, _link, _variables)
{
    switch (_node.type)
    {
        case UI_AST.NUMBER:
            return _node.value;
        
        case UI_AST.STRING:
            return _node.value;
        
        case UI_AST.BOOL:
            return _node.value;
        
        case UI_AST.COLOR:
            return { color: _node.color, alpha: _node.alpha }
        
        case UI_AST.TUPLE:
            var _values = [];
            var _count = array_length(_node.values);
            
            for (var i = 0; i < _count; ++i)
            {
                array_push(_values, ui_resolve_value(_node.values[i], _link, _variables));
            }
            
            return _values;
        
        case UI_AST.ENUM:
            return _node.name;
        
        case UI_AST.IDENTIFIER:
            /* Check for ORIGIN_* macros first */
            var _origin_val = ui_resolve_origin(_node.name);
            
            if (_origin_val != undefined)
            {
                return _origin_val;
            }
            
            /* Look up in local variables */
            if (struct_exists(_variables, _node.name))
            {
                var _var_value = _variables[$ _node.name];
                
                /* If the stored value is an AST node, resolve it recursively */
                if (is_struct(_var_value) && struct_exists(_var_value, "type"))
                {
                    return ui_resolve_value(_var_value, _link, _variables);
                }
                
                return _var_value;
            }
            
            return _node.name;
        
        case UI_AST.BINDING:
            /* Return a marker - actual binding happens at runtime */
            return undefined;
        
        case UI_AST.ARRAY_INDEX:
            /* Resolve *name[index] inline — look up array in link context, return element at index */
            if (_link != undefined && struct_exists(_link, _node.name))
            {
                var _arr = _link[$ _node.name];
                
                if (is_method(_arr))
                {
                    _arr = _arr();
                }
                else if (is_array(_arr) && !is_array(_arr[0]))
                {
                    /* plain array — use as-is */
                }
                else if (is_array(_arr))
                {
                    _arr = proglang_runtime_call(_arr);
                }
                
                var _idx = ui_resolve_value(_node.index, _link, _variables);
                
                if (is_array(_arr) && _idx >= 0 && _idx < array_length(_arr))
                {
                    return _arr[_idx];
                }
            }
            
            return undefined;
        
        case UI_AST.LOCA_KEY:
            /* Translate via localization system */
            return loca_translate(_node.key);
        
        case UI_AST.SCRIPT_REF:
            /* Return the script ID for event handlers */
            return _node.script_id;
        
        case UI_AST.SPRITE_DEF:
            /* Resolve $sprite(name) { properties } to a runtime struct */
            var _sprite_def = {
                is_sprite_def: true,
                sprite_name: _node.sprite_name,
                slice_left: 0,
                slice_right: 0,
                slice_top: 0,
                slice_bottom: 0
            }
            
            /* Resolve nested properties (slices, etc.) */
            var _prop_count = array_length(_node.properties);
            
            for (var i = 0; i < _prop_count; ++i)
            {
                var _prop = _node.properties[i];
                var _key = _prop.key;
                var _val = ui_resolve_value(_prop.value, _link, _variables);
                
                /* Handle individual slice properties */
                if (_key == "slice_left")
                {
                    _sprite_def.slice_left = _val;
                }
                else if (_key == "slice_right")
                {
                    _sprite_def.slice_right = _val;
                }
                else if (_key == "slice_top")
                {
                    _sprite_def.slice_top = _val;
                }
                else if (_key == "slice_bottom")
                {
                    _sprite_def.slice_bottom = _val;
                }
                /* Handle tuple slices = (left, top, right, bottom) or (left, right) */
                else if (_key == "slices" && is_array(_val))
                {
                    var _len = array_length(_val);
                    
                    if (_len == 2)
                    {
                        /* (left, right) shorthand */
                        _sprite_def.slice_left = _val[0];
                        _sprite_def.slice_right = _val[1];
                    }
                    else if (_len >= 4)
                    {
                        /* (left, top, right, bottom) */
                        _sprite_def.slice_left = _val[0];
                        _sprite_def.slice_top = _val[1];
                        _sprite_def.slice_right = _val[2];
                        _sprite_def.slice_bottom = _val[3];
                    }
                }
            }
            
            return _sprite_def;
        
        case UI_AST.SURFACE_DEF:
            /* Resolve $surface(name) { properties } to a runtime struct */
            var _surface_def = {
                is_surface_def: true,
                surface_name: _node.surface_name,
            }
            
            /* Resolve any nested properties */
            var _surf_prop_count = array_length(_node.properties);
            
            for (var i = 0; i < _surf_prop_count; ++i)
            {
                var _prop = _node.properties[i];
                var _key = _prop.key;
                var _val = ui_resolve_value(_prop.value, _link, _variables);
                
                _surface_def[$ _key] = _val;
            }
            
            return _surface_def;
        
        case UI_AST.PERCENTAGE:
            /* Return a special struct that defers resolution to the property handler */
            return { is_percent: true, value: _node.value }
        
        case UI_AST.UNARY_OP:
            var _right_val = ui_resolve_value(_node.right, _link, _variables);
            
            if (_node.op == "-")
            {
                if (is_struct(_right_val) && _right_val[$ "is_percent"] == true)
                {
                    return { is_percent: true, value: -_right_val.value }
                }
                
                return -_right_val;
            }
            
            return _right_val;
        
        case UI_AST.BINARY_OP:
            var _lv = ui_resolve_value(_node.left, _link, _variables);
            var _rv = ui_resolve_value(_node.right, _link, _variables);
            
            return ui_calc_binary_op(_node.op, _lv, _rv);
        
        case UI_AST.FUNC_CALL:
            var _arg_val = ui_resolve_value(_node.arg, _link, _variables);
            
            switch (_node.func_name)
            {
                case "floor": return floor(_arg_val);
                default:
                    show_debug_message($"[UI Runtime] Unknown function: {_node.func_name}");
                    
                    return _arg_val;
            }
    }
    
    return undefined;
}

/// @desc Resolve an ORIGIN_* macro name to a percentage-based coordinate tuple
/// @param {String} _name Origin name (e.g. "ORIGIN_BOTTOM_CENTER")
/// @returns {Array|undefined} [x%, y%] percentage tuple or undefined if not an origin
function ui_resolve_origin(_name)
{
    switch (_name)
    {
        case "ORIGIN_TOP_LEFT":      return [0, 0];
        case "ORIGIN_TOP_CENTER":    return [{ is_percent: true, value: 50 }, 0];
        case "ORIGIN_TOP_RIGHT":     return [{ is_percent: true, value: 100 }, 0];
        case "ORIGIN_MIDDLE_LEFT":   return [0, { is_percent: true, value: 50 }];
        case "ORIGIN_CENTER":        return [{ is_percent: true, value: 50 }, { is_percent: true, value: 50 }];
        case "ORIGIN_MIDDLE_RIGHT":  return [{ is_percent: true, value: 100 }, { is_percent: true, value: 50 }];
        case "ORIGIN_BOTTOM_LEFT":   return [0, { is_percent: true, value: 100 }];
        case "ORIGIN_BOTTOM_CENTER": return [{ is_percent: true, value: 50 }, { is_percent: true, value: 100 }];
        case "ORIGIN_BOTTOM_RIGHT":  return [{ is_percent: true, value: 100 }, { is_percent: true, value: 100 }];
        default: return undefined;
    }
}

/// @desc Perform a binary math operation on two resolved values
/// Supports: number op number, tuple op tuple (element-wise), number op tuple (broadcast)
/// @param {String} _op Operator string
/// @param {Any} _left Left value
/// @param {Any} _right Right value
/// @returns {Any} Result
function ui_calc_binary_op(_op, _left, _right)
{
    /* Both arrays (tuples) → element-wise */
    if (is_array(_left) && is_array(_right))
    {
        var _len = max(array_length(_left), array_length(_right));
        var _result = [];
        
        for (var i = 0; i < _len; ++i)
        {
            var _l = (i < array_length(_left)) ? _left[i] : 0;
            var _r = (i < array_length(_right)) ? _right[i] : 0;
            
            array_push(_result, ui_calc_binary_op(_op, _l, _r));
        }
        
        return _result;
    }
    
    /* One is array, other is scalar → broadcast */
    if (is_array(_left))
    {
        var _result = [];
        var _length = array_length(_left);
        
        for (var i = 0; i < _length; ++i)
        {
            array_push(_result, ui_calc_binary_op(_op, _left[i], _right));
        }
        
        return _result;
    }
    
    if (is_array(_right))
    {
        var _result = [];
        var _length = array_length(_right);
        
        for (var i = 0; i < _length; ++i)
        {
            array_push(_result, ui_calc_binary_op(_op, _left, _right[i]));
        }
        
        return _result;
    }

    
    /* Extract numeric values (handle percentage structs) */
    var _lv = _left;
    var _rv = _right;
    var _l_pct = false;
    var _r_pct = false;
    var _l_calc = false;
    var _r_calc = false;
    
    if (is_struct(_left) && _left[$ "is_calc"] == true)
    {
        _l_calc = true;
    }
    else if (is_struct(_left) && _left[$ "is_percent"] == true)
    {
        _lv = _left.value;
        _l_pct = true;
    }
    
    if (is_struct(_right) && _right[$ "is_calc"] == true)
    {
        _r_calc = true;
    }
    else if (is_struct(_right) && _right[$ "is_percent"] == true)
    {
        _rv = _right.value;
        _r_pct = true;
    }
    
    /* Handle calc struct combinations for + and - */
    if ((_op == "+" || _op == "-") && (_l_pct || _r_pct || _l_calc || _r_calc))
    {
        /* Extract percent and absolute components */
        var _pct_part = 0;
        var _abs_part = 0;
        
        /* Left operand */
        if (_l_calc)
        {
            _pct_part += _left.percent_value;
            _abs_part += _left.absolute_offset;
        }
        else if (_l_pct)
        {
            _pct_part += _lv;
        }
        else
        {
            _abs_part += _lv;
        }
        
        /* Right operand (negate if subtracting) */
        var _sign = (_op == "+") ? 1 : -1;
        
        if (_r_calc)
        {
            _pct_part += _sign * _right.percent_value;
            _abs_part += _sign * _right.absolute_offset;
        }
        else if (_r_pct)
        {
            _pct_part += _sign * _rv;
        }
        else
        {
            _abs_part += _sign * _rv;
        }
        
        /* If no percent component, return plain number */
        if (_pct_part == 0) return _abs_part;
        
        /* If no absolute component, return pure percentage */
        if (_abs_part == 0) return { is_percent: true, value: _pct_part }
        
        /* Mixed: return calc struct */
        return { is_calc: true, percent_value: _pct_part, absolute_offset: _abs_part }
    }
    
    /* Perform the arithmetic */
    var _val = 0;
    
    switch (_op)
    {
        case "+":  _val = _lv + _rv; break;
        case "-":  _val = _lv - _rv; break;
        case "*":  _val = _lv * _rv; break;
        case "/":  _val = (_rv != 0) ? _lv / _rv : 0; break;
        case "%":  _val = (_rv != 0) ? _lv mod _rv : 0; break;
        case "**": _val = power(_lv, _rv); break;
        default:   _val = _lv; break;
    }
    
    /* If both operands were percentages, keep result as percentage */
    if (_l_pct && _r_pct)
    {
        return { is_percent: true, value: _val }
    }
    
    return _val;
}

/// @desc Resolve a value that might be a percentage, calc, or plain number
/// @param {Any} _value Number, { is_percent, value }, or { is_calc, percent_value, absolute_offset }
/// @param {Real} _reference Reference dimension (e.g. gui_width, parent_width)
/// @returns {Real} Resolved absolute value
function ui_resolve_percentage(_value, _reference)
{
    if (is_struct(_value))
    {
        if (_value[$ "is_calc"] == true)
        {
            return _reference * (_value.percent_value / 100) + _value.absolute_offset;
        }
        
        if (_value[$ "is_percent"] == true)
        {
            return _reference * (_value.value / 100);
        }
    }
    
    return _value;
}

/// @desc Get the base GUI scale for UI elements
/// @returns {Struct} {x: real, y: real}
function ui_get_base_scale()
{
    /* Standard target is 960x540 */
    /* gui_width/gui_height already incorporate gui_scale, so no extra multiply needed */
    var _w = variable_global_exists("gui_width") ? global.gui_width : 960;
    var _h = variable_global_exists("gui_height") ? global.gui_height : 540;
    
    return {
        x: _w / 960,
        y: _h / 540
    }
}

/// @desc Destroy a UI instance and all its elements
/// @param {Struct} _instance UI instance to destroy
function ui_destroy(_instance)
{
    if (_instance == undefined) return;
    
    /* Destroy all root elements */
    var _count = array_length(_instance.root_elements);
    
    for (var i = _count - 1; i >= 0; --i)
    {
        /* Elements are structs, just let GC handle them */
    }
    
    /* Remove from registry */
    struct_remove(global.ui_instances, string(_instance.id));
}

/// @desc Get an element by name from a UI instance
/// @param {Struct} _instance UI instance
/// @param {String} _name Element name
/// @returns {Struct.UIElement} Element or undefined
function ui_get(_instance, _name)
{
    if (_instance == undefined) return undefined;
    
    return _instance.elements[$ _name];
}

/// @desc Set a property on an element by name
/// @param {Struct} _instance UI instance
/// @param {String} _name Element name
/// @param {String} _property Property name
/// @param {Any} _value Value to set
function ui_set(_instance, _name, _property, _value)
{
    var _element = ui_get(_instance, _name);
    
    if (_element != undefined)
    {
        _element[$ _property] = _value;
    }
}

/// @desc Fire a UI event - marks all instances listening for this event as dirty
/// @param {String} _event_name Event identifier (e.g. "inventory_changed", "hp_changed")
function ui_event(_event_name)
{
    global.ui_pending_events[$ _event_name] = true;
    
    /* Mark matching instances as dirty */
    var _keys = struct_get_names(global.ui_instances);
    var _key_count = array_length(_keys);
    
    for (var i = _key_count - 1; i >= 0; --i)
    {
        var _inst = global.ui_instances[$ _keys[i]];
        
        if (_inst.render_events != undefined)
        {
            var _ev_count = array_length(_inst.render_events);
            
            for (var j = _ev_count - 1; j >= 0; --j)
            {
                if (_inst.render_events[j] == _event_name)
                {
                    _inst.dirty = true;
                    
                    break;
                }
            }
        }
    }
}

/// @desc Manually mark a UI instance as needing a re-render
/// @param {Struct} _instance UI instance
function ui_mark_dirty(_instance)
{
    if (_instance != undefined) _instance.dirty = true;
}

/// @desc Clear the global event bus (call at end of frame)
function ui_clear_events()
{
    global.ui_pending_events = {}
}

/// @desc Check if a UI instance should render this frame
/// @param {Struct} _instance UI instance
/// @returns {Bool} True if instance should render
function ui_should_render(_instance)
{
    /* No event filter = always render (backwards compatible) */
    if (_instance.render_events == undefined) return true;
    
    /* Has event filter = only render when dirty */
    return _instance.dirty;
}

/// @desc Refresh all bindings in a UI instance
/// @param {Struct} _instance UI instance
function ui_refresh(_instance)
{
    if (_instance == undefined) return;
    if (!ui_should_render(_instance)) return;
    
    var _count = array_length(_instance.root_elements);
    
    for (var i = _count - 1; i >= 0; --i)
    {
        if (struct_exists(_instance.root_elements[i], "update_bindings"))
        {
            _instance.root_elements[i].update_bindings();
        }
    }
}

/// @desc Update all root elements in a UI instance
/// @param {Struct} _instance UI instance
function ui_update(_instance)
{
    if (_instance == undefined) return;
    
    /* Sync visibility to root elements */
    var _is_visible = _instance[$ "visible"] ?? true;
    var _root_count = array_length(_instance.root_elements);
    
    for (var i = _root_count - 1; i >= 0; --i)
    {
        _instance.root_elements[i].visible = _is_visible;
    }
    
    if (!ui_should_render(_instance)) return;
    
    for (var i = _root_count - 1; i >= 0; --i)
    {
        _instance.root_elements[i].update();
    }
}

/// @desc Draw all root elements in a UI instance
function ui_draw(_instance)
{
    if (_instance == undefined) return;
    
    var _count = array_length(_instance.root_elements);
    
    for (var i = _count - 1; i >= 0; --i)
    {
        _instance.root_elements[i].draw();
    }
    
    /* Clear dirty flag after drawing */
    if (_instance.render_events != undefined)
    {
        _instance.dirty = false;
    }
}

/// @desc Cleanly destroy a UI instance
function ui_instance_destroy(_instance)
{
    if (_instance == undefined) return;
    
    /* Unparent root elements */
    var _count = array_length(_instance.root_elements);
    
    for (var i = _count - 1; i >= 0; --i)
    {
        var _root = _instance.root_elements[i];
        
        if (_root.parent != undefined)
        {
            var _p_children = _root.parent.children;
            
            for (var j = array_length(_p_children) - 1; j >= 0; --j)
            {
                if (_p_children[j] == _root)
                {
                    array_delete(_p_children, j, 1);
                    
                    break;
                }
            }
        }
    }
    
    /* Remove from registry */
    variable_global_get("ui_instances")[$ string(_instance.id)] = undefined;
    
    struct_remove(global.ui_instances, string(_instance.id));
}
