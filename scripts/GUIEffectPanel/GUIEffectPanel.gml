function GUIEffectPanel(_x, _y) : UIElement(_x, _y, 0, 16) constructor
{
    // Effect icon size (16x16 with 2px spacing)
    static ICON_SIZE = 16;
    static ICON_SPACING = 2;
    
    effect_icons = {}
    
    static update = function()
    {
        if (!visible) exit;
        
        // Check player effects and create/remove icons as needed
        if (!instance_exists(obj_Player)) exit;
        
        if (!variable_instance_exists(obj_Player, "effects")) exit;
        
        var _player_effects = obj_Player.effects;
        var _effect_names = global.effect_data_names;
        var _effect_length = array_length(_effect_names);
        
        var _active_count = 0;
        
        for (var i = 0; i < _effect_length; ++i)
        {
            var _effect_id = _effect_names[i];
            var _effect_instance = _player_effects[$ _effect_id];
            
            if (_effect_instance != undefined) && (_effect_instance.timer > 0)
            {
                // Effect is active
                if (effect_icons[$ _effect_id] == undefined)
                {
                    // Create new icon (growing leftwards for right anchor)
                    var _icon_x = -((_active_count + 1) * (ICON_SIZE + ICON_SPACING));
                    var _icon = new GUIEffectIcon(_icon_x, 0, _effect_id);
                    effect_icons[$ _effect_id] = _icon;
                    add_child(_icon);
                }
                else
                {
                    // Update position
                    var _icon = effect_icons[$ _effect_id];
                    _icon.x = -((_active_count + 1) * (ICON_SIZE + ICON_SPACING));
                }
                
                _active_count++;
            }
            else
            {
                // Effect is not active, remove icon if exists
                if (effect_icons[$ _effect_id] != undefined)
                {
                    remove_child(_icon);
                    
                    delete effect_icons[$ _effect_id];
                    effect_icons[$ _effect_id] = undefined;
                }
            }
        }
        
        // Update panel width based on active effects
        width = _active_count * (ICON_SIZE + ICON_SPACING);
        
        // Update children
        var _child_count = array_length(children);
        for (var i = 0; i < _child_count; i++) {
            children[i].update();
        }
        
        update_bindings();
    }
}
