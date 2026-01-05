/// @description Menu UI Integration - Entry points for the new UIElement-based menu system
/// This script provides functions to initialize and switch between menu screens

/// @desc Initialize the menu UI system for a given room
/// @param {Asset.GMRoom} _room The room to initialize for
function menu_ui_init(_room)
{
    var _ui = global.ui_manager;
    
    switch (_room)
    {
        case rm_Menu_Title:
            var _title_menu = MenuBuilder.create_title_menu();
            _ui.set_root(_title_menu);
            break;
            
        case rm_Menu_Player:
            var _player_select = MenuBuilder.create_player_select();
            _ui.set_root(_player_select);
            break;
            
        case rm_Menu_World:
            var _world_select = MenuBuilder.create_world_select();
            _ui.set_root(_world_select);
            break;
            
        case rm_Menu_Settings:
            var _settings = MenuBuilder.create_settings_screen();
            _ui.set_root(_settings);
            break;
            
        default:
            // No UI for this room
            _ui.set_root(undefined);
            return;
    }
    
    _ui.layout();
}

/// @desc Open the settings screen as a modal overlay
function menu_ui_open_settings()
{
    var _settings = MenuBuilder.create_settings_screen();
    global.ui_manager.push_root(_settings);
}

/// @desc Close any open modal and return to previous screen
function menu_ui_close_modal()
{
    global.ui_manager.pop_root();
}

/// @desc Update the menu UI (call from Step event)
function menu_ui_update()
{
    global.ui_manager.update();
}

/// @desc Draw the menu UI (call from Draw GUI event)
function menu_ui_draw()
{
    global.ui_manager.draw();
}

/// @desc Check if a modal is currently open
/// @returns {Bool} True if a modal dialog is open
function menu_ui_modal_open()
{
    return global.ui_manager.get_modal_depth() > 0;
}

/// @desc Transition to a new menu room with the UIElement system
/// @param {Asset.GMRoom} _room Target room
function menu_ui_goto(_room)
{
    // Use existing transition system
    menu_transition_goto(_room);
}

/// @desc Called at the end of a room transition to set up new room's UI
/// This should be called from the Room Start event of menu rooms
function menu_ui_room_start()
{
    menu_ui_init(room);
}
