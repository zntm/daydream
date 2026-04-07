/// @desc Updates GUI panel visibility flags and drives all UI updates for this frame.
function control_game_gui_visibility()
{
    var _is_open = obj_Game_Control.is_opened;

    var _generating = !!(_is_open & WORLD_OPENED_BOOL.GENERATING_WORLD);
    var _inventory  = !!(_is_open & WORLD_OPENED_BOOL.INVENTORY);
    var _gui        = !!(_is_open & WORLD_OPENED_BOOL.GUI);
    var _menu       = !!(_is_open & WORLD_OPENED_BOOL.MENU);
    var _chat       = !!(_is_open & WORLD_OPENED_BOOL.CHAT);

    if (global.gui_panel_hotbar_modular != undefined)
    {
        global.gui_panel_hotbar_modular.visible = !_generating
            && ((_gui && !_menu && !_chat) || (_inventory && !_chat));
    }

    if (global.gui_panel_inventory_modular != undefined)
    {
        global.gui_panel_inventory_modular.visible = !_generating && _inventory && !_chat;
    }

    if (variable_global_exists("gui_panel_crafting_modular")) && (global.gui_panel_crafting_modular != undefined)
    {
        global.gui_panel_crafting_modular.visible = !_generating && _inventory && !_chat
            && (array_length(global.gui_panel_crafting_modular.children) > 0);
    }

    if (variable_global_exists("gui_panel_effects")) && (global.gui_panel_effects != undefined)
    {
        global.gui_panel_effects.visible = !_generating && _gui && !_menu && !_chat;
    }

    global.ui_input_consumed = false;
    global.ui_hover_consumed = false;

    global.gui_root.update();

    if (variable_global_exists("ui_hotbar")) && (global.ui_hotbar != undefined)
    {
        ui_mark_dirty(global.ui_hotbar);
        ui_update(global.ui_hotbar);
    }

    if (variable_global_exists("ui_inventory")) && (global.ui_inventory != undefined)
    {
        ui_mark_dirty(global.ui_inventory);
        ui_update(global.ui_inventory);
    }

    ui_clear_events();

    /* update dynamically spawned UI instances (blueprints, etc.) */
    if (variable_global_exists("ui_instances"))
    {
        var _ui_keys  = struct_get_names(global.ui_instances);
        var _ui_count = array_length(_ui_keys);

        for (var i = _ui_count - 1; i >= 0; --i)
        {
            var _ui_inst = global.ui_instances[$ _ui_keys[i]];

            if (_ui_inst != undefined) ui_update(_ui_inst);
        }
    }

    if (variable_global_exists("gui_panel_chat")) && (global.gui_panel_chat != undefined)
    {
        global.gui_panel_chat.visible = _gui && !_menu;
    }
}
