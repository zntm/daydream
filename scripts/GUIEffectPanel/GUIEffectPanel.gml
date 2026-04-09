function GUIEffectPanel(_x, _y) : UIElement(_x, _y, 0, 16) constructor
{
    // Effect icon size (16x16 with 2px spacing)
    static ICON_SIZE = 16;
    static ICON_SPACING = 2;
    
    effect_icons = {}

    static get_player_effects = function()
    {
        if (!instance_exists(obj_Player)) return undefined;
        if (!variable_instance_exists(obj_Player, "effects")) return undefined;

        return obj_Player.effects;
    }
    
    static update = function()
    {
        if (!visible) exit;
        
        var _player_effects = get_player_effects();

        if (_player_effects == undefined)
        {
            effect_icons = {}
            children = [];
            width = 0;
            update_bindings();
            exit;
        }

        var _effect_names = global.effect_data_names;
        var _effect_length = array_length(_effect_names);
        var _active_ids = {};
        var _active_count = 0;
        
        for (var i = 0; i < _effect_length; ++i)
        {
            var _effect_id = _effect_names[i];
            var _effect_instance = _player_effects[$ _effect_id];
            
            if (_effect_instance != undefined) && (_effect_instance.timer > 0)
            {
                _active_ids[$ _effect_id] = true;

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
        }

        var _icon_ids = struct_get_names(effect_icons);
        var _icon_count = array_length(_icon_ids);

        for (var i = _icon_count - 1; i >= 0; --i)
        {
            var _effect_id = _icon_ids[i];

            if (_active_ids[$ _effect_id] == true) continue;

            var _icon = effect_icons[$ _effect_id];

            if (_icon != undefined)
            {
                remove_child(_icon);
            }

            struct_remove(effect_icons, _effect_id);
        }
        
        // Update panel width based on active effects
        width = (_active_count > 0)
            ? (_active_count * ICON_SIZE) + ((_active_count - 1) * ICON_SPACING)
            : 0;
        recalculate_layout();
        
        // Update children
        var _child_count = array_length(children);
        for (var i = 0; i < _child_count; i++)
        {
            var _child = children[i];

            if (is_struct(_child)) && struct_exists(_child, "update")
            {
                _child.update();
            }
        }
        
        update_bindings();
    }
}
