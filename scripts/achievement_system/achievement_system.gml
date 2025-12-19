/// @desc Achievement System - Track and unlock achievements based on events and statistics
/// Integrates with event system and statistics system

#macro ACHIEVEMENT_VERSION 1

global.player_achievements = undefined;

/// @function achievement_init()
/// @desc Initialize the achievement system
function achievement_init()
{
    // Player achievements (unlocked status)
    global.player_achievements ??= {};
    
    // Achievement data loaded from datagen
    global.achievement_data ??= {};
    
    // Subscribe to events for achievement checking
    event_subscribe(GAME_EVENT.TILE_CHANGED, achievement_on_tile_changed);
    event_subscribe(GAME_EVENT.ENTITY_DEATH, achievement_on_entity_death);
    event_subscribe(GAME_EVENT.ITEM_COLLECTED, achievement_on_item_collected);
    event_subscribe(GAME_EVENT.CRAFTING_COMPLETE, achievement_on_crafting_complete);
    event_subscribe(GAME_EVENT.STATISTIC_CHANGED, achievement_on_statistic_changed);
}

/// @function achievement_unlock(_id)
/// @desc Unlock an achievement
/// @param {string} _id Achievement ID
function achievement_unlock(_id)
{
    // Already unlocked?
    if (global.player_achievements[$ _id] != undefined) return false;
    
    // Mark as unlocked
    global.player_achievements[$ _id] = {
        unlocked: true,
        timestamp: datetime_to_unix()
    };
    
    // Get achievement data
    var _data = global.achievement_data[$ _id];
    
    // Show notification (if available)
    achievement_show_notification(_id, _data);
    
    // Give reward if any
    if (_data != undefined)
    {
        var _reward = _data[$ "reward"];
        
        if (_reward != undefined)
        {
            var _item = _reward[$ "item"];
            var _amount = _reward[$ "amount"] ?? 1;
            
            if (_item != undefined)
            {
                inventory_add("base", new Inventory(_item, _amount));
            }
        }
    }
    
    // Emit event
    event_emit(GAME_EVENT.ACHIEVEMENT_UNLOCKED, {
        id: _id,
        data: _data
    });
    
    return true;
}

/// @function achievement_is_unlocked(_id)
/// @desc Check if an achievement is unlocked
/// @param {string} _id Achievement ID
/// @returns {bool} True if unlocked
function achievement_is_unlocked(_id)
{
    return (global.player_achievements[$ _id] != undefined);
}

/// @function achievement_get_progress(_id)
/// @desc Get progress towards a statistic-based achievement
/// @param {string} _id Achievement ID
/// @returns {struct} { current, required, percentage }
function achievement_get_progress(_id)
{
    var _data = global.achievement_data[$ _id];
    
    if (_data == undefined) return { current: 0, required: 1, percentage: 0 };
    
    var _condition = _data[$ "condition"];
    
    if (_condition == undefined) return { current: 0, required: 1, percentage: 0 };
    
    var _stat = _condition[$ "statistic"];
    var _required = _condition[$ "count"] ?? 1;
    
    if (_stat != undefined)
    {
        var _current = statistics_get(_stat);
        
        return {
            current: _current,
            required: _required,
            percentage: clamp(_current / _required, 0, 1)
        };
    }
    
    return { current: 0, required: _required, percentage: 0 };
}

/// @function achievement_show_notification(_id, _data)
/// @desc Show achievement unlock notification
function achievement_show_notification(_id, _data)
{
    // Create floating text or UI notification
    var _name = $"Achievement: {_id}";
    
    // Use localization if available
    var _loca_key = $"phantasia:achievement.{_id}.name";
    var _loca = loca_translate(_loca_key);
    
    if (_loca != _loca_key)
    {
        _name = _loca;
    }
    
    // Create floating text at player position
    if (instance_exists(obj_Player))
    {
        spawn_floating_text(obj_Player.x, obj_Player.y - 32, _name, c_yellow);
    }
}

/// @function achievement_check_condition(_condition, _data)
/// @desc Check if achievement condition is met
function achievement_check_condition(_condition, _event_data)
{
    if (_condition == undefined) return false;
    
    var _item_id = _condition[$ "item_id"];
    var _entity_id = _condition[$ "entity_id"];
    var _count = _condition[$ "count"] ?? 1;
    var _statistic = _condition[$ "statistic"];
    
    // Check item match
    if (_item_id != undefined)
    {
        var _event_item = _event_data[$ "id"] ?? _event_data[$ "item_id"];
        
        if (_event_item == undefined) return false;
        
        // Handle comma-separated list
        if (string_pos(",", _item_id) > 0)
        {
            var _items = string_split(_item_id, ",");
            var _found = false;
            
            for (var i = 0; i < array_length(_items); i++)
            {
                if (_event_item == _items[i])
                {
                    _found = true;
                    break;
                }
            }
            
            if (!_found) return false;
        }
        else if (_event_item != _item_id)
        {
            return false;
        }
    }
    
    // Check entity match
    if (_entity_id != undefined)
    {
        var _event_entity = _event_data[$ "entity_id"] ?? _event_data[$ "id"];
        
        if (_event_entity != _entity_id) return false;
    }
    
    // Check statistic threshold
    if (_statistic != undefined)
    {
        var _current = statistics_get(_statistic);
        
        if (_current < _count) return false;
    }
    
    return true;
}

#region Event Handlers

function achievement_on_tile_changed(_data)
{
    achievement_check_event("TILE_CHANGED", _data);
}

function achievement_on_entity_death(_data)
{
    if (_data[$ "killed_by_player"])
    {
        achievement_check_event("ENTITY_DEATH", _data);
    }
}

function achievement_on_item_collected(_data)
{
    achievement_check_event("ITEM_COLLECTED", _data);
}

function achievement_on_crafting_complete(_data)
{
    achievement_check_event("CRAFTING_COMPLETE", _data);
}

function achievement_on_statistic_changed(_data)
{
    // Check all statistic-based achievements
    var _names = struct_get_names(global.achievement_data);
    var _count = array_length(_names);
    
    for (var i = 0; i < _count; i++)
    {
        var _id = _names[i];
        
        if (achievement_is_unlocked(_id)) continue;
        
        var _ach = global.achievement_data[$ _id];
        var _condition = _ach[$ "condition"];
        
        if (_condition == undefined) continue;
        
        var _stat = _condition[$ "statistic"];
        
        if (_stat != undefined && _stat == _data.id)
        {
            if (achievement_check_condition(_condition, {}))
            {
                achievement_unlock(_id);
            }
        }
    }
}

function achievement_check_event(_event_type, _event_data)
{
    var _names = struct_get_names(global.achievement_data);
    var _count = array_length(_names);
    
    for (var i = 0; i < _count; i++)
    {
        var _id = _names[i];
        
        if (achievement_is_unlocked(_id)) continue;
        
        var _ach = global.achievement_data[$ _id];
        var _condition = _ach[$ "condition"];
        
        if (_condition == undefined) continue;
        
        var _ach_event = _condition[$ "event"];
        
        if (_ach_event != _event_type) continue;
        
        if (achievement_check_condition(_condition, _event_data))
        {
            achievement_unlock(_id);
        }
    }
}

#endregion

#region Save/Load

/// @function achievement_save_player(_buffer, _achievements)
function achievement_save_player(_buffer, _achievements = undefined)
{
    _achievements ??= global.player_achievements;

    buffer_write(_buffer, buffer_u16, ACHIEVEMENT_VERSION);
    
    var _names = struct_get_names(_achievements);
    var _count = array_length(_names);
    
    buffer_write(_buffer, buffer_u32, _count);
    
    for (var i = 0; i < _count; i++)
    {
        var _name = _names[i];
        var _data = _achievements[$ _name];
        
        buffer_write(_buffer, buffer_string, _name);
        buffer_write(_buffer, buffer_f64, _data.timestamp);
    }
}

/// @function achievement_load_player(_buffer)
/// @returns {struct} Loaded achievements
function achievement_load_player(_buffer)
{
    var _version = buffer_read(_buffer, buffer_u16);
    var _count = buffer_read(_buffer, buffer_u32);
    
    var _achievements = {};
    
    for (var i = 0; i < _count; i++)
    {
        var _name = buffer_read(_buffer, buffer_string);
        var _timestamp = buffer_read(_buffer, buffer_f64);
        
        _achievements[$ _name] = {
            unlocked: true,
            timestamp: _timestamp
        };
    }
    
    return _achievements;
}

#endregion
