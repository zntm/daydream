/// @description Base GUI component constructor
/// @param {Real} _x X position relative to parent
/// @param {Real} _y Y position relative to parent
/// @param {Real} _width Component width
/// @param {Real} _height Component height

function GUIComponent(_x, _y, _width, _height) constructor
{
    x = _x;
    y = _y;
    width = _width;
    height = _height;
    
    visible = true;
    parent = undefined;
    children = [];
    
    anchor_x = undefined; // "left", "center", "right"
    anchor_y = undefined; // "top", "middle", "bottom"
    offset_x = _x;
    offset_y = _y;
    
    scale = 1.0; // Component scale multiplier (from datagen)
    
    /// @description Add a child component
    /// @param {Struct.GUIComponent} _child Child component to add
    static add_child = function(_child)
    {
        _child.parent = self;
        array_push(children, _child);
        _child.recalculate_layout();
        return _child;
    }
    
    static set_anchor = function(_anchor_x, _anchor_y)
    {
        anchor_x = _anchor_x;
        anchor_y = _anchor_y;
        recalculate_layout();
        return self;
    }
    
    static recalculate_layout = function()
    {
        if (parent == undefined) exit;
        
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

    
    /// @description Get absolute X position
    static get_absolute_x = function()
    {
        if (parent != undefined)
        {
            return parent.get_absolute_x() + x;
        }
        return x;
    }
    
    /// @description Get absolute Y position
    static get_absolute_y = function()
    {
        if (parent != undefined)
        {
            return parent.get_absolute_y() + y;
        }
        return y;
    }
    
    /// @description Update the component (called each step)
    static update = function()
    {
        if (!visible) exit;
        
        var _length = array_length(children);
        for (var i = 0; i < _length; ++i)
        {
            children[i].update();
        }
    }
    
    /// @description Draw the component (called each draw event)
    static draw = function()
    {
        if (!visible) exit;
        
        draw_content();
        
        var _length = array_length(children);
        for (var i = 0; i < _length; ++i)
        {
            children[i].draw();
        }
    }
    
    /// @description Override this to draw component-specific content
    static draw_content = function()
    {
        // Base implementation does nothing
    }
}
