/// @desc Open UI from a .ui file (native handler for @phantasia:open_ui)
/// @param {Struct} _params Parameters from the item script
/// @param {Struct} _context Execution context (includes tile, position, etc.)
function open_ui(_params, _context)
{
    // Extract parameters
    var _ui_path = _params[$ "ui"];
    var _definition_name = _params[$ "definition"];
    var _bindings_config = _params[$ "bindings"] ?? {};
    
    if (_ui_path == undefined)
    {
        show_debug_message("[UI] Error: Missing 'ui' parameter in open_ui");
        return;
    }
    
    if (_definition_name == undefined)
    {
        show_debug_message("[UI] Error: Missing 'definition' parameter in open_ui");
        return;
    }
    
    // Get the UI definition
    var _def = ui_get_definition(_ui_path, _definition_name);
    
    if (_def == undefined)
    {
        show_debug_message($"[UI] Failed to load UI definition: {_definition_name} from {_ui_path}");
        return;
    }
    
    // Set up bindings from tile components
    var _tile = _context[$ "tile"];
    var _binding_keys = struct_get_names(_bindings_config);
    
    for (var i = 0; i < array_length(_binding_keys); ++i)
    {
        var _binding_name = _binding_keys[i];
        var _binding_source = _bindings_config[$ _binding_name];
        
        // Handle component bindings (e.g., "component:id")
        if (string_pos("component:", _binding_source) == 1)
        {
            var _component_name = string_delete(_binding_source, 1, 10);
            
            // Create a getter function for this component
            var _getter = method({ tile: _tile, component: _component_name }, function() {
                return tile.get_component(component);
            });
            
            // Create a setter function for this component  
            var _setter = method({ tile: _tile, component: _component_name }, function(_value) {
                tile.set_component(component, _value);
            });
            
            // Set getter link (used for initial value and reactive updates)
            _def.set_link(_binding_name, _getter);
            
            // Set setter link (used by textboxes to write back changes)
            _def.set_link(_binding_name + "_setter", _setter);
        }
    }
    
    // Spawn the UI
    var _element = ui_spawn(_def);
    
    if (_element == undefined)
    {
        show_debug_message($"[UI] Failed to spawn UI: {_definition_name}");
        return;
    }
    
    // Store context on the element for event handlers
    _element._ui_context = _context;
    _element._ui_bindings_config = _bindings_config;
    
    // Add to UI system as a popup/overlay
    if (instance_exists(obj_UIManager))
    {
        obj_UIManager.add_popup(_element);
    }
    else if (variable_global_exists("ui_root"))
    {
        global.ui_root.add_child(_element);
    }
    else
    {
        show_debug_message("[UI] No UI manager found to add element to.");
    }
}

/// @desc Close the current UI popup (handler for @phantasia:ui/close_menu)
function close_ui(_context)
{
    // Get callback element from context
    var _element = _context[$ "element"];
    
    if (_element != undefined)
    {
        // Walk up to find the popup root
        var _popup = _element;
        while (_popup._parent != undefined)
        {
            _popup = _popup._parent;
        }
        
        // Remove it
        if (_popup.destroy != undefined)
        {
            _popup.destroy();
        }
        else if (instance_exists(obj_UIManager))
        {
            obj_UIManager.remove_popup(_popup);
        }
    }
}

// Register these as Proglang handlers
if (!variable_global_exists("proglang_native_ui"))
{
    global.proglang_native_ui = true;
    
    // Wrap open_ui as a native callable
    global.proglang_scripts[$ "phantasia:open_ui"] = {
        native: true,
        func: method(undefined, function() {
            var _params = arg0;
            var _context = arg1 ?? {};
            open_ui(_params, _context);
        })
    };
    
    global.proglang_scripts[$ "phantasia:ui/close_menu"] = {
        native: true,
        func: method(undefined, function() {
            var _context = arg0 ?? {};
            close_ui(_context);
        })
    };
}
