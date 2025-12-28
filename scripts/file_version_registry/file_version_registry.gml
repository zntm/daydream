/// @desc Save version registry and upgrade system
/// Allows registering version upgraders for different save categories

global.file_version_upgraders = {}

/// @function file_version_register(_category, _from_version, _to_version, _upgrade_func)
/// @desc Register a version upgrader for a category
/// @param {string} _category The save category (e.g., "chunk", "player", "world")
/// @param {real} _from_version The version to upgrade from
/// @param {real} _to_version The version to upgrade to
/// @param {function} _upgrade_func Function that takes buffer and returns upgraded data struct
function file_version_register(_category, _from_version, _to_version, _upgrade_func)
{
    global.file_version_upgraders[$ _category] ??= [];
    
    array_push(global.file_version_upgraders[$ _category], {
        from: _from_version,
        to: _to_version,
        upgrade: _upgrade_func
    });
    
    // Sort by from_version to ensure proper upgrade order
    array_sort(global.file_version_upgraders[$ _category], function(_a, _b) {
        return _a.from - _b.from;
    });
}

/// @function file_version_get_current()
/// @desc Get current program version number
/// @returns {real} Current version number
function file_version_get_current()
{
    return PROGRAM_VERSION_NUMBER;
}

/// @function file_version_needs_upgrade(_category, _saved_version)
/// @desc Check if saved data needs upgrading
/// @param {string} _category The save category
/// @param {real} _saved_version The version the data was saved with
/// @returns {bool} Whether upgrade is needed
function file_version_needs_upgrade(_category, _saved_version)
{
    return _saved_version < PROGRAM_VERSION_NUMBER;
}

/// @function file_version_get_upgraders(_category, _from_version)
/// @desc Get all applicable upgraders from a version to current
/// @param {string} _category The save category
/// @param {real} _from_version The starting version
/// @returns {array} Array of upgrader structs to apply in order
function file_version_get_upgraders(_category, _from_version)
{
    var _upgraders = global.file_version_upgraders[$ _category];
    
    if (_upgraders == undefined) return [];
    
    var _applicable = [];
    var _current_version = _from_version;
    
    for (var i = 0; i < array_length(_upgraders); ++i)
    {
        var _upgrader = _upgraders[i];
        
        if (_upgrader.from >= _current_version && _upgrader.to <= PROGRAM_VERSION_NUMBER)
        {
            array_push(_applicable, _upgrader);
            _current_version = _upgrader.to;
        }
    }
    
    return _applicable;
}

/// @function file_version_log(_category, _from, _to)
/// @desc Log a version upgrade (for debugging)
/// @param {string} _category The save category
/// @param {real} _from Original version
/// @param {real} _to Target version
function file_version_log(_category, _from, _to)
{
    var _from_major = (_from >> 16) & 0xFF;
    var _from_minor = (_from >> 8) & 0xFF;
    var _from_patch = _from & 0xFF;
    
    var _to_major = (_to >> 16) & 0xFF;
    var _to_minor = (_to >> 8) & 0xFF;
    var _to_patch = _to & 0xFF;
    
    show_debug_message($"[Save] Upgrading {_category} from v{_from_major}.{_from_minor}.{_from_patch} to v{_to_major}.{_to_minor}.{_to_patch}");
}
