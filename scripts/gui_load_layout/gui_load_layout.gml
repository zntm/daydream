/// @description Load GUI layout from JSON data
/// @param {Struct} _data JSON data for the component
/// @param {Struct.GUIComponent} _parent Parent component to add children to
/// @returns {Struct.GUIComponent} The created component

function gui_load_layout(_data, _parent = undefined)
{
    var _type = _data[$ "type"];
    var _props = _data[$ "props"] ?? {}
    
    // Create the component
    var _component = gui_create_component(_type, _props);
    
    if (_component == undefined) return undefined;
    
    var _anchor_x = _props[$ "anchor_x"];
    var _anchor_y = _props[$ "anchor_y"];
    
    if (_anchor_x != undefined || _anchor_y != undefined)
    {
        _component.set_anchor(_anchor_x, _anchor_y);
    }
    
    // Apply scale if specified
    var _scale = _props[$ "scale"];
    if (_scale != undefined)
    {
        _component.scale = _scale;
    }
    
    // Add to parent if provided
    if (_parent != undefined)
    {
        _parent.add_child(_component);
    }
    
    // Recursively load children
    var _children = _data[$ "children"];
    if (_children != undefined)
    {
        var _length = array_length(_children);
        for (var i = 0; i < _length; ++i)
        {
            gui_load_layout(_children[i], _component);
        }
    }
    
    return _component;
}
