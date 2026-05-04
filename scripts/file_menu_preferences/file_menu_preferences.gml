global.menu_preferences = {
    pinned_players:    [],
    pinned_worlds:     [],
    players_view_mode: "grid",
    worlds_view_mode:  "grid"
}

function file_save_menu_preferences()
{
    var _json   = json_stringify(global.menu_preferences);
    var _buffer = buffer_create(string_byte_length(_json) + 1, buffer_fixed, 1);
    
    buffer_write(_buffer, buffer_string, _json);
    buffer_save(_buffer, $"{PROGRAM_DIRECTORY_APPDATA}/menu_preferences.json");
    buffer_delete(_buffer);
}

function file_load_menu_preferences()
{
    var _path = $"{PROGRAM_DIRECTORY_APPDATA}/menu_preferences.json";
    
    if (!file_exists(_path)) exit;
    
    var _buffer = buffer_load(_path);
    
    if (_buffer == -1) exit;
    
    var _json_str = buffer_read(_buffer, buffer_string);
    
    buffer_delete(_buffer);
    
    var _data = json_parse(_json_str);
    
    if (_data == undefined) exit;
    
    global.menu_preferences.pinned_players    = _data[$ "pinned_players"]    ?? [];
    global.menu_preferences.pinned_worlds     = _data[$ "pinned_worlds"]     ?? [];
    global.menu_preferences.players_view_mode = _data[$ "players_view_mode"] ?? "grid";
    global.menu_preferences.worlds_view_mode  = _data[$ "worlds_view_mode"]  ?? "grid";
}

/// @desc Applies pinned state from menu_preferences to a loaded players array.
function file_apply_pinned_players()
{
    var _pinned  = global.menu_preferences.pinned_players;
    var _players = global.file_players;
    
    for (var i = array_length(_players) - 1; i >= 0; --i)
    {
        var _uuid = _players[i].get_uuid();
        
        _players[i][$ "pinned"] = array_contains(_pinned, _uuid);
    }
}

/// @desc Applies pinned state from menu_preferences to a loaded worlds array.
function file_apply_pinned_worlds()
{
    var _pinned = global.menu_preferences.pinned_worlds;
    var _worlds = global.file_worlds;
    
    for (var i = array_length(_worlds) - 1; i >= 0; --i)
    {
        var _uuid = _worlds[i].get_uuid();
        
        _worlds[i][$ "pinned"] = array_contains(_pinned, _uuid);
    }
}

/// @desc Toggles a player's pinned state and persists to disk.
/// @param {String} _uuid The player UUID to toggle.
/// @returns {Bool} The new pinned state.
function file_toggle_pinned_player(_uuid)
{
    var _pinned = global.menu_preferences.pinned_players;
    var _idx    = array_get_index(_pinned, _uuid);
    
    if (_idx >= 0)
    {
        array_delete(_pinned, _idx, 1);
    }
    else
    {
        array_push(_pinned, _uuid);
    }
    
    file_save_menu_preferences();
    
    return (_idx < 0);
}

/// @desc Toggles a world's pinned state and persists to disk.
/// @param {String} _uuid The world UUID to toggle.
/// @returns {Bool} The new pinned state.
function file_toggle_pinned_world(_uuid)
{
    var _pinned = global.menu_preferences.pinned_worlds;
    var _idx    = array_get_index(_pinned, _uuid);
    
    if (_idx >= 0)
    {
        array_delete(_pinned, _idx, 1);
    }
    else
    {
        array_push(_pinned, _uuid);
    }
    
    file_save_menu_preferences();
    
    return (_idx < 0);
}
