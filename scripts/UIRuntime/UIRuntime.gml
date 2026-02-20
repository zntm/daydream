/* ui runtime - handles loading, spawning, and managing ui instances */
/* central system for the declarative ui language */


/* global ui definition cache */
global.ui_definitions = {};


/* global ui instance registry */
global.ui_instances = {};

global.ui_instance_counter = 0;


/* global ui event bus - tracks which events have been fired this frame */
global.ui_pending_events = {};


/* =============================================================================
   loading and parsing
   ============================================================================= */

/* load and parse a ui file, returning definitions */
/* @param {string} _path path to .ui file */
/* @returns {struct.UIASTDocument} parsed ui document */
function ui_load(_path)
{
    /* check cache first */
    if (struct_exists(global.ui_definitions, _path))
    {
        show_debug_message($"[UI Runtime] using cached definition for: {_path}");
        
        return global.ui_definitions[$ _path];
    }
    
    
    /* resolve full path - ui files are in resources/data/ui/ */
    var _full_path = _path;
    var _resources = PROGRAM_DIRECTORY_RESOURCES;
    
    
    if (_resources != "")
    {
        _full_path = $"{_resources}/data/{_path}";
    }
    
    
    show_debug_message($"[UI Runtime] attempting to load ui file: '{_path}' -> '{_full_path}' (cwd: {working_directory})");
    show_debug_message($"[UI Runtime] file exists (full): {file_exists(_full_path)}");
    
    
    /* load file contents */
    var _source = buffer_load_text(_full_path);
    
    
    /* fallback: try relative path directly if full path failed */
    if (_source == undefined && _full_path != _path)
    {
        show_debug_message($"[UI Runtime] falling back to relative path: '{_path}'");
        show_debug_message($"[UI Runtime] file exists (rel): {file_exists(_path)}");
        
        _source = buffer_load_text(_path);
    }
    
    
    if (_source == undefined || _source == "")
    {
        show_debug_message($"[UI Runtime] ERROR: failed to load ui file content from: {_full_path} OR {_path}");
        
        return undefined;
    }
    
    
    /* tokenize */
    var _lexer = new UILexer(_source);
    var _tokens = _lexer.tokenize();
    
    
    if (_lexer.had_error)
    {
        show_debug_message($"[UI Runtime] lexer error in {_path}: {_lexer.error}");
        
        return undefined;
    }
    
    
    /* parse */
    var _parser = new UIParser(_tokens);
    var _document = _parser.parse();
    
    
    if (_parser.had_error)
    {
        show_debug_message($"[UI Runtime] parser error in {_path}: {_parser.error}");
        
        return undefined;
    }
    
    
    /* cache and return */
    var _ui_def = {
        document: _document,
        variables: _parser.variables
    }
    
    
    /* expose top-level elements by name for importing in daydream */
    var _defs = _document.definitions;
    var _exports = {};
    var _def_count = array_length(_defs);
    
    
    for (var i = _def_count - 1; i >= 0; --i)
    {
        var _el = _defs[i];
        
        
        if (is_struct(_el))
        {
            switch (_el.type)
            {
                case UI_AST.ELEMENT:
                    _ui_def[$ _el.name] = _el;
                    _el.variables = _parser.variables;
                    break;
                    
                case UI_AST.EXPORT_VAR:
                    _exports[$ _el.name] = _el.value;
                    break;
                    
                case UI_AST.EXPORT_ELEMENT:
                    if (is_struct(_el.element))
                    {
                        var _inner = _el.element;
                        
                        _exports[$ _inner.name] = _inner;
                        _ui_def[$ _inner.name] = _inner;
                        _inner.variables = _parser.variables;
                    }
                    break;
            }
        }
    }
    
    
    _ui_def.exports = _exports;
    
    global.ui_definitions[$ _path] = _ui_def;
    
    
    show_debug_message($"[UI Runtime] successfully loaded ui file: {_full_path}");
    
    return _ui_def;
}


/* =============================================================================
   spawning
   ============================================================================= */

/* spawn ui instances from definitions */
/* @param {array|struct} _definitions array of element names or ast elements to spawn   */
/* @param {struct} _config configuration including link context */
/* @param {array|undefined} _events optional array of event strings that trigger re-renders */
/* @returns {struct} ui instance with spawned elements */
function ui_spawn(_definitions, _config = {}, _events = undefined)
{
    /* handle ui_load() result struct (has .document property) */
    if (is_struct(_definitions) && struct_exists(_definitions, "document"))
    {
        var _doc = _definitions.document;
        
        _definitions = _doc.definitions;
    }
    
    
    /* normalize definitions to an array if it's a single struct */
    if (is_struct(_definitions) && struct_exists(_definitions, "type") && _definitions.type == UI_AST.ELEMENT)
    {
        _definitions = [_definitions];
    }
    
    
    if !(is_array(_definitions))
    {
        show_debug_message("[UI Runtime] warning: ui_spawn called with invalid definitions.");
        
        return undefined;
    }
    
    
    var _def_count = array_length(_definitions);
    
    var _parent_val = _config[$ "parent"];
    var _parent_name = (is_struct(_parent_val) && struct_exists(_parent_val, "element_name")) ? _parent_val.element_name : "unknown";
    
    
    show_debug_message($"[UI Runtime] ui_spawn: spawning {_def_count} definitions into parent '{_parent_name}'");
    
    
    var _link = _config[$ "link"] ?? {};
    var _parent = _config[$ "parent"] ?? undefined;
    
    
    var _instance = {
        id: global.ui_instance_counter++,
        elements: {},
        root_elements: [],
        link_context: _link,
        render_events: _events,   /* array of event strings, or undefined for every-frame */
        dirty: true,              /* start dirty so first frame always renders */
        visible: true             /* control visibility of all root elements */
    }
    
    
    global.ui_instances[$ string(_instance.id)] = _instance;
    
    
    /* get variables from definition if available */
    var _variables = {};
    
    if (is_struct(_definitions) && struct_exists(_definitions, "variables"))
    {
        _variables = _definitions.variables;
    }
    
    
    for (var i = 0; i < _def_count; ++i)
    {
        var _def = _definitions[i];
        
        
        if (_def == undefined)
        {
            show_debug_message($"[UI Runtime] warning: definition at index {i} is undefined. check your imports.");
            
            continue;
        }
        
        
        /* handle definition struct wrapping */
        if (is_struct(_def) && struct_exists(_def, "document"))
        {
            _variables = _def.variables;
            _def = _def.document.definitions;
            
            
            /* if it's an array of elements from the document, recurse or loop */
            if (is_array(_def))
            {
                var _sub_count = array_length(_def);
                
                for (var j = 0; j < _sub_count; ++j)
                {
                    var _sub_def = _def[j];
                    var _sub_vars = _variables;
                    
                    
                    if (is_struct(_sub_def) && struct_exists(_sub_def, "variables"))
                    {
                        _sub_vars = _sub_def.variables;
                    }
                    
                    
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
            /* pick up variables from the element if available */
            var _el_vars = _variables;
            
            
            if (struct_exists(_def, "variables"))
            {
                _el_vars = _def.variables;
            }
            
            
            /* it's an ast node - instantiate it */
            _element = ui_instantiate_element(_def, _link, _el_vars);
        }
        
        
        if (_element != undefined)
        {
            ui_process_spawned_element(_element, _instance, _parent);
        }
    }
    
    
    return _instance;
}


/* internal helper to process a spawned element */
function ui_process_spawned_element(_element, _instance, _parent)
{
    _element.instance_id = _instance.id;
    _element.instance = _instance;
    
    
    /* ALWAYS add top-level elements of this spawn call to root_elements */
    /* this allows global.ui_*.root_elements[0] to work even if a parent was provided */
    array_push(_instance.root_elements, _element);
    
    
    if (_parent != undefined)
    {
        /* handle uielement or guicomponent parent */
        if (struct_exists(_parent, "add_child"))
        {
            _parent.add_child(_element);
        } 
        /* handle uiinstance struct parent (result of ui_spawn) */
        else if (struct_exists(_parent, "root_elements") && array_length(_parent.root_elements) > 0)
        {
            var _actual_parent = _parent.root_elements[0];
            
            
            if (struct_exists(_actual_parent, "add_child"))
            {
                _actual_parent.add_child(_element);
            }
        }
    }
    
    
    _instance.elements[$ _element.element_name] = _element;
    
    
    /* register all nested elements by name */
    ui_register_nested_elements(_element, _instance.elements);
}


/* recursively collect all elements with specific properties */
/* @param {struct.uielement} _element root element to start from */
/* @param {array} _out array to collect matching elements into */
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


/* register nested elements by name */
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


/* =============================================================================
   instantiation
   ============================================================================= */

/* instantiate an element from ast node */
/* @param {struct} _node ast element node */
/* @param {struct} _link link context */
/* @param {struct} _variables local variable scope */
/* @returns {struct.uielement} instantiated element */
function ui_instantiate_element(_node, _link, _variables)
{
    if (_node.type != UI_AST.ELEMENT) return undefined;
    
    
    var _element = undefined;
    
    
    /* create element based on type */
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
            
        case "line":
            _element = new UILine(0, 0);
            break;
            
        case "line_path":
            _element = new UILinePath(0, 0);
            break;
            
        case "dropdown":
            _element = new UIDropdown(0, 0, 100, 16);
            break;
            
        case "scroll_area":
            _element = new UIScrollArea(0, 0, 100, 100);
            break;
            
        default:
            show_debug_message($"[UI Runtime] unknown element type: {_node.element_type}");
            
            _element = new UIElement(0, 0, 100, 100);
            
            break;
    }
    
    
    if (_element == undefined) return undefined;
    
    
    _element.element_name = _node.name;
    _element.element_type = _node.element_type;
    
    
    _element.set_link_context(_link);
    
    
    /* apply properties */
    var _prop_count = array_length(_node.properties);
    
    
    for (var i = 0; i < _prop_count; ++i)
    {
        var _prop = _node.properties[i];
        
        
        ui_apply_property(_element, _prop, _link, _variables);
    }
    
    
    /* instantiate children */
    var _child_count = array_length(_node.children);
    
    
    for (var i = 0; i < _child_count; ++i)
    {
        var _child_node = _node.children[i];
        
        
        /* handle repeat(count, var) expansion */
        if (_child_node.repeat_count != undefined)
        {
            var _repeat_count = _child_node.repeat_count;
            var _repeat_var = _child_node.repeat_var;
            var _base_name = _child_node.name;
            
            
            for (var j = 0; j < _repeat_count; ++j)
            {
                /* create a copy of the variables scope with the loop variable */
                var _loop_vars = {};
                var _var_names = struct_get_names(_variables);
                var _var_count = array_length(_var_names);
                
                
                for (var k = _var_count - 1; k >= 0; --k)
                {
                    _loop_vars[$ _var_names[k]] = _variables[$ _var_names[k]];
                }
                
                _loop_vars[$ _repeat_var] = j;
                
                
                /* override the element name for each copy */
                var _saved_name = _child_node.name;
                
                _child_node.name = _base_name + "_" + string(j);
                
                
                /* temporarily clear repeat to prevent infinite recursion */
                var _saved_count = _child_node.repeat_count;
                
                _child_node.repeat_count = undefined;
                
                
                var _child = ui_instantiate_element(_child_node, _link, _loop_vars);
                
                
                /* restore original values */
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
    
    
    /* perform layout after all children added */
    _element.layout_children();
    
    return _element;
}


/* apply a property to an element */
/* @param {struct.uielement} _element target element */
/* @param {struct} _prop property ast node */
/* @param {struct} _link link context */
/* @param {struct} _variables local variables */
function ui_apply_property(_element, _prop, _link, _variables)
{
    var _key = _prop.key;
    var _value_node = _prop.value;
    var _value = ui_resolve_value(_value_node, _link, _variables);
    
    
    /* handle special properties */
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
                
                
                /* auto-detect anchors from percentages */
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
                
                
                /* resolve to pixels for the offset */
                var _ref_w = (global.gui_root != undefined) ? global.gui_root.width : 960;
                var _ref_h = (global.gui_root != undefined) ? global.gui_root.height : 540;
                
                var _rx = ui_resolve_percentage(_vx, _ref_w);
                var _ry = ui_resolve_percentage(_vy, _ref_h);
                
                
                /* if it was a clean percentage, the offset should be 0 relative to that anchor */
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
                
                
                /* support both ORIGIN_* aliases and raw strings */
                if (is_array(_ax)) _ax = "center";
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
        
            
        case "start":
            if (struct_exists(_element, "set_start"))
            {
                _element.set_start(_value);
            }
            break;
        
            
        case "end":
            if (struct_exists(_element, "set_end"))
            {
                _element.set_end(_value);
            }
            break;
        
            
        case "points":
            if (struct_exists(_element, "set_points"))
            {
                _element.set_points(_value);
            }
            break;
        
            
        case "thickness":
            _element.thickness = _value;
            break;
        
            
        case "fade":
            if (struct_exists(_element, "set_fade"))
            {
                _element.set_fade(_value);
            }
            break;
        
            
        case "choices": /* aligned with renamed choices in uidropdown */
        case "options":
            if (struct_exists(_element, "set_choices"))
            {
                _element.set_choices(_value);
            }
            else if (struct_exists(_element, "set_options"))
            {
                _element.set_options(_value);
            }
            break;
        
            
        case "choice_index": /* aligned with renamed property in uidropdown */
        case "selected":
            if (struct_exists(_element, "set_selected"))
            {
                _element.set_selected(_value);
            }
            break;
        
            
        default:
            /* check for event handlers (on_*) */
            if (string_pos("on_", _key) == 1)
            {
                if (_value_node.type == UI_AST.SCRIPT_REF)
                {
                    _element.add_event_handler(_key, _value_node.script_id);
                }
            }
            /* check for bindings */
            else if (_value_node.type == UI_AST.BINDING)
            {
                _element.add_binding(_key, _value_node.name);
            }
            /* array-indexed binding: *name[index] — register as a callable resolver */
            else if (_value_node.type == UI_AST.ARRAY_INDEX)
            {
                var _arr_name = _value_node.name;
                var _idx_node = _value_node.index;
                
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
            /* handle sprite definitions for sprite_empty/sprite_fill */
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
            /* regular property - try to set via setter or directly */
            else
            {
                var _final_value = _value;
                
                
                if (is_struct(_value) && struct_exists(_value, "color"))
                {
                    _final_value = _value.color;
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


/* =============================================================================
   resolution
   ============================================================================= */

/* resolve a value ast node to a runtime value */
/* @param {struct} _node value ast node */
/* @param {struct} _link link context */
/* @param {struct} _variables local variables */
/* @returns {any} resolved value */
function ui_resolve_value(_node, _link, _variables)
{
    switch (_node.type)
    {
        case UI_AST.NUMBER:
        case UI_AST.STRING:
        case UI_AST.BOOL:
            return _node.value;
            
        case UI_AST.COLOR:
            return { color: _node.color, alpha: _node.alpha };
            
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
            /* check for ORIGIN_* macros first */
            var _origin_val = ui_resolve_origin(_node.name);
            
            
            if (_origin_val != undefined)
            {
                return _origin_val;
            }
            
            
            /* look up in local variables */
            if (struct_exists(_variables, _node.name))
            {
                var _var_value = _variables[$ _node.name];
                
                
                /* if the stored value is an ast node, resolve it recursively */
                if (is_struct(_var_value) && struct_exists(_var_value, "type"))
                {
                    return ui_resolve_value(_var_value, _link, _variables);
                }
                
                return _var_value;
            }
            
            return _node.name;
            
        case UI_AST.BINDING:
            return undefined;
            
        case UI_AST.ARRAY_INDEX:
            if (_link != undefined && struct_exists(_link, _node.name))
            {
                var _arr = _link[$ _node.name];
                
                
                if (is_method(_arr))
                {
                    _arr = _arr();
                }
                else if (is_array(_arr) && !is_array(_arr[0]))
                {
                    /* plain array */
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
            return loca_translate(_node.key);
            
        case UI_AST.SCRIPT_REF:
            return _node.script_id;
            
        case UI_AST.SPRITE_DEF:
            var _sprite_def = {
                is_sprite_def: true,
                sprite_name: _node.sprite_name,
                slice_left: 0,
                slice_right: 0,
                slice_top: 0,
                slice_bottom: 0
            };
            
            
            var _prop_count = array_length(_node.properties);
            
            
            for (var i = 0; i < _prop_count; ++i)
            {
                var _prop = _node.properties[i];
                var _key = _prop.key;
                var _val = ui_resolve_value(_prop.value, _link, _variables);
                
                
                switch (_key)
                {
                    case "slice_left":   _sprite_def.slice_left = _val; break;
                    case "slice_right":  _sprite_def.slice_right = _val; break;
                    case "slice_top":    _sprite_def.slice_top = _val; break;
                    case "slice_bottom": _sprite_def.slice_bottom = _val; break;
                    case "slices":
                        if (is_array(_val))
                        {
                            var _len = array_length(_val);
                            
                            if (_len == 2)
                            {
                                _sprite_def.slice_left = _val[0];
                                _sprite_def.slice_right = _val[1];
                            }
                            else if (_len >= 4)
                            {
                                _sprite_def.slice_left = _val[0];
                                _sprite_def.slice_top = _val[1];
                                _sprite_def.slice_right = _val[2];
                                _sprite_def.slice_bottom = _val[3];
                            }
                        }
                        break;
                }
            }
            
            return _sprite_def;
            
        case UI_AST.SURFACE_DEF:
            var _surface_def = {
                is_surface_def: true,
                surface_name: _node.surface_name
            };
            
            
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
            return { is_percent: true, value: _node.value };
            
        case UI_AST.UNARY_OP:
            var _right_val = ui_resolve_value(_node.right, _link, _variables);
            
            
            if (_node.op == "-")
            {
                if (is_struct(_right_val) && _right_val[$ "is_percent"] == true)
                {
                    return { is_percent: true, value: -(_right_val.value) };
                }
                
                return -(_right_val);
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
                    show_debug_message($"[UI Runtime] unknown function: {_node.func_name}");
                    
                    return _arg_val;
            }
    }
    
    return undefined;
}


/* resolve an ORIGIN_* macro name to a percentage-based coordinate tuple */
/* @param {string} _name origin name (e.g. "ORIGIN_BOTTOM_CENTER") */
/* @returns {array|undefined} [x%, y%] percentage tuple or undefined if not an origin */
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


/* perform a binary math operation on two resolved values */
function ui_calc_binary_op(_op, _left, _right)
{
    /* both arrays (tuples) → element-wise */
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
    
    
    /* one is array, other is scalar → broadcast */
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

    
    /* extract numeric values (handle percentage structs) */
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
    
    
    /* handle calc struct combinations for + and - */
    if ((_op == "+" || _op == "-") && (_l_pct || _r_pct || _l_calc || _r_calc))
    {
        var _pct_part = 0;
        var _abs_part = 0;
        
        
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
        
        
        if (_pct_part == 0) return _abs_part;
        
        if (_abs_part == 0) return { is_percent: true, value: _pct_part };
        
        return { is_calc: true, percent_value: _pct_part, absolute_offset: _abs_part };
    }
    
    
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
    
    
    if (_l_pct && _r_pct)
    {
        return { is_percent: true, value: _val };
    }
    
    return _val;
}


/* resolve a value that might be a percentage, calc, or plain number */
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


/* get the base gui scale for ui elements */
function ui_get_base_scale()
{
    var _lw = (global.gui_root != undefined) ? global.gui_root.width : 960;
    var _lh = (global.gui_root != undefined) ? global.gui_root.height : 540;
    
    var _w = variable_global_exists("gui_width") ? global.gui_width : _lw;
    var _h = variable_global_exists("gui_height") ? global.gui_height : _lh;
    
    
    return {
        x: _w / _lw,
        y: _h / _lh
    };
}


/* =============================================================================
   management
   ============================================================================= */

/* destroy a ui instance and all its elements */
function ui_destroy(_instance)
{
    if (_instance == undefined) exit;
    
    
    ui_instance_destroy(_instance);
}


/* get an element by name from a ui instance */
function ui_get(_instance, _name)
{
    if (_instance == undefined) return undefined;
    
    return _instance.elements[$ _name];
}


/* set a property on an element by name */
function ui_set(_instance, _name, _property, _value)
{
    var _element = ui_get(_instance, _name);
    
    
    if (_element != undefined)
    {
        _element[$ _property] = _value;
    }
}


/* fire a ui event - marks all instances listening for this event as dirty */
function ui_event(_event_name)
{
    global.ui_pending_events[$ _event_name] = true;
    
    
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


/* manually mark a ui instance as needing a re-render */
function ui_mark_dirty(_instance)
{
    if (_instance != undefined)
    {
        _instance.dirty = true;
    }
}


/* clear the global event bus */
function ui_clear_events()
{
    global.ui_pending_events = {};
}


/* check if a ui instance should render this frame */
function ui_should_render(_instance)
{
    if (_instance.render_events == undefined) return true;
    
    return _instance.dirty;
}


/* refresh all bindings in a ui instance */
function ui_refresh(_instance)
{
    if (_instance == undefined) exit;
    
    if !(ui_should_render(_instance)) exit;
    
    
    var _count = array_length(_instance.root_elements);
    
    
    for (var i = _count - 1; i >= 0; --i)
    {
        if (struct_exists(_instance.root_elements[i], "update_bindings"))
        {
            _instance.root_elements[i].update_bindings();
        }
    }
}


/* update all root elements in a ui instance */
function ui_update(_instance)
{
    if (_instance == undefined) exit;
    
    
    /* sync visibility to root elements */
    var _is_visible = _instance[$ "visible"] ?? true;
    var _root_count = array_length(_instance.root_elements);
    
    
    for (var i = _root_count - 1; i >= 0; --i)
    {
        _instance.root_elements[i].visible = _is_visible;
    }
    
    
    if !(ui_should_render(_instance)) exit;
    
    
    for (var i = _root_count - 1; i >= 0; --i)
    {
        _instance.root_elements[i].update();
    }
}


/* draw all root elements in a ui instance */
function ui_draw(_instance)
{
    if (_instance == undefined) exit;
    
    
    var _count = array_length(_instance.root_elements);
    
    
    for (var i = _count - 1; i >= 0; --i)
    {
        _instance.root_elements[i].draw();
    }
    
    
    /* clear dirty flag after drawing */
    if (_instance.render_events != undefined)
    {
        _instance.dirty = false;
    }
}


/* cleanly destroy a ui instance */
function ui_instance_destroy(_instance)
{
    if (_instance == undefined) exit;
    
    
    /* unparent root elements */
    var _count = array_length(_instance.root_elements);
    
    
    for (var i = _count - 1; i >= 0; --i)
    {
        var _root = _instance.root_elements[i];
        
        
        if (_root.parent != undefined)
        {
            var _p_children = _root.parent.children;
            var _pc_count = array_length(_p_children);
            
            
            for (var j = _pc_count - 1; j >= 0; --j)
            {
                if (_p_children[j] == _root)
                {
                    array_delete(_p_children, j, 1);
                    
                    break;
                }
            }
        }
    }
    
    
    /* remove from registry */
    struct_remove(global.ui_instances, string(_instance.id));
}
