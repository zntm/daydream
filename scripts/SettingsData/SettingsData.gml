enum SETTINGS_TYPE {
    SWITCH,
    // Left and right arrow to switch between values
    ARROW,
    // Creates a slider from 0 to 1
    SLIDER,
    HOTKEY
}

enum SETTINGS_LEVEL {
    NONE,
    MIN,
    MAX 
}

function SettingsData(_type, _default_value) constructor
{
    ___type = _type;
    
    static get_type = function()
    {
        return ___type;
    }
    
    ___default_value = _default_value;
    
    static get_default_value = function()
    {
        return ___default_value;
    }
    
    static set_on_press = function(_on_press)
    {
        ___on_press = _on_press;
        
        return self;
    }
    
    static get_on_press = function()
    {
        return self[$ "___on_press"];
    }
    
    static set_on_hold = function(_on_hold)
    {
        ___on_hold = _on_hold;
        
        return self;
    }
    
    static get_on_hold = function()
    {
        return self[$ "___on_hold"];
    }
    
    static set_on_update = function(_on_update)
    {
        ___on_update = _on_update;
        
        return self;
    }
    
    static get_on_update = function()
    {
        return self[$ "___on_update"];
    }
    
    static add_values = function()
    {
        self[$ "___values"] ??= [];
        
        for (var i = 0; i < argument_count; ++i)
        {
            array_push(___values, string(argument[i]));
        }
        
        return self;
    }
    
    static get_values = function()
    {
        return self[$ "___values"];
    }
}