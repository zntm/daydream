/// @description GUI Component registry and factory

global.gui_component_registry = {};

/// @description Register a component constructor
/// @param {String} _type Type name (e.g., "panel", "slot")
/// @param {Function} _constructor Constructor function
function gui_register_component(_type, _constructor)
{
    global.gui_component_registry[$ _type] = _constructor;
}

/// @description Create a component instance from type and properties
/// @param {String} _type Component type name
/// @param {Struct} _props Properties struct from JSON
/// @returns {Struct.GUIComponent} Created component instance
function gui_create_component(_type, _props)
{
    var _constructor = global.gui_component_registry[$ _type];
    
    if (_constructor == undefined)
    {
        show_debug_message("GUI: Unknown component type: " + _type);
        return undefined;
    }
    
    var _x = _props[$ "x"] ?? 0;
    var _y = _props[$ "y"] ?? 0;
    var _width = _props[$ "width"] ?? 16;
    var _height = _props[$ "height"] ?? 16;
    
    switch (_type)
    {
        case "panel":
            return new GUIPanel(_x, _y, _width, _height);
            
        case "slot":
            var _inventory_name = _props[$ "inventory_name"] ?? "base";
            var _slot_index = _props[$ "slot_index"] ?? 0;
            var _slot = new GUISlot(_x, _y, _inventory_name, _slot_index);
            
            if (struct_exists(_props, "icon_sprite")) _slot.icon_sprite = _props.icon_sprite;
            if (struct_exists(_props, "icon_index")) _slot.icon_index = _props.icon_index;
            
            return _slot;
        
        case "text":
            var _text = _props[$ "text"] ?? "";
            return new GUIText(_x, _y, _text);
        
        case "chat_history":
            var _max_messages = _props[$ "max_messages"] ?? 8;
            return new GUIChatHistory(_x, _y, _width, _height, _max_messages);
        
        case "choice_panel":
            return new GUIChoicePanel(_x, _y, _width);
            
        default:
            // Generic constructor call
            return new _constructor(_x, _y, _width, _height);
    }
}
