/// @desc Statistics System - Track player and world statistics
/// Integrates with the event system for automatic tracking

#macro STATISTICS_VERSION 1

global.player_statistics = undefined;
global.world_statistics = undefined;

/// @function statistics_init()
/// @desc Initialize the statistics system and subscribe to events
function statistics_init()
{
    // Player statistics (persist across worlds)
    global.player_statistics ??= {};
    
    // World statistics (per-player contributions in the world)
    global.world_statistics ??= {};
    
    // Subscribe to game events for automatic tracking
    event_subscribe(GAME_EVENT.TILE_CHANGED, statistics_on_tile_changed);
    event_subscribe(GAME_EVENT.ENTITY_DAMAGED, statistics_on_entity_damaged);
    event_subscribe(GAME_EVENT.ENTITY_DEATH, statistics_on_entity_death);
    event_subscribe(GAME_EVENT.ITEM_COLLECTED, statistics_on_item_collected);
    event_subscribe(GAME_EVENT.CHUNK_GENERATED, statistics_on_chunk_generated);
}

/// @function statistics_increment(_stat_id, _amount)
/// @desc Increment a counter statistic
/// @param {string} _stat_id Statistic ID
/// @param {real} _amount Amount to add
function statistics_increment(_stat_id, _amount = 1)
{
    // Update player statistics
    global.player_statistics[$ _stat_id] ??= 0;
    global.player_statistics[$ _stat_id] += _amount;
    
    // Update world statistics (track per-player)
    var _player_uuid = global.player_save_data.uuid;
    
    global.world_statistics[$ _stat_id] ??= {};
    global.world_statistics[$ _stat_id][$ _player_uuid] ??= 0;
    global.world_statistics[$ _stat_id][$ _player_uuid] += _amount;
    
    // Emit event for achievements/UI to react
    event_emit(GAME_EVENT.STATISTIC_CHANGED, {
        id: _stat_id,
        player_value: global.player_statistics[$ _stat_id],
        world_value: global.world_statistics[$ _stat_id][$ _player_uuid]
    });
}

/// @function statistics_set_max(_stat_id, _value)
/// @desc Set a statistic to the max of current and new value
/// @param {string} _stat_id Statistic ID
/// @param {real} _value New value to compare
function statistics_set_max(_stat_id, _value)
{
    var _current = global.player_statistics[$ _stat_id] ?? 0;
    
    if (_value > _current)
    {
        global.player_statistics[$ _stat_id] = _value;
        
        // Update world stats too
        var _player_uuid = global.player_save_data.uuid;
        global.world_statistics[$ _stat_id] ??= {};
        global.world_statistics[$ _stat_id][$ _player_uuid] = _value;
    }
}

/// @function statistics_get(_stat_id)
/// @desc Get a player statistic value
/// @param {string} _stat_id Statistic ID
/// @returns {real} Statistic value
function statistics_get(_stat_id)
{
    return global.player_statistics[$ _stat_id] ?? 0;
}

/// @function statistics_get_world(_stat_id, _player_uuid)
/// @desc Get a world statistic for a specific player
/// @param {string} _stat_id Statistic ID
/// @param {string} _player_uuid Player UUID (optional, defaults to current player)
/// @returns {real} Statistic value
function statistics_get_world(_stat_id, _player_uuid = undefined)
{
    _player_uuid ??= global.player_save_data.uuid;
    
    var _stat = global.world_statistics[$ _stat_id];
    if (_stat == undefined) return 0;
    
    return _stat[$ _player_uuid] ?? 0;
}

/// @function statistics_get_world_total(_stat_id)
/// @desc Get total of a world statistic across all players
/// @param {string} _stat_id Statistic ID
/// @returns {real} Total value
function statistics_get_world_total(_stat_id)
{
    var _stat = global.world_statistics[$ _stat_id];
    if (_stat == undefined) return 0;
    
    var _total = 0;
    var _players = struct_get_names(_stat);
    var _count = array_length(_players);
    
    for (var i = 0; i < _count; i++)
    {
        _total += _stat[$ _players[i]];
    }
    
    return _total;
}

#region Event Handlers

/// @function statistics_on_tile_changed(_data)
function statistics_on_tile_changed(_data)
{
    var _action = _data[$ "action"];
    var _id = _data[$ "id"] ?? "";
    
    if (_action == "break" || _action == "harvest")
    {
        statistics_increment("tiles_broken", 1);
        statistics_increment($"tiles_broken_{_id}", 1);
    }
    else if (_action == "place" || _action == "build")
    {
        statistics_increment("tiles_placed", 1);
        statistics_increment($"tiles_placed_{_id}", 1);
    }
}

/// @function statistics_on_entity_damaged(_data)
function statistics_on_entity_damaged(_data)
{
    var _damage = _data[$ "damage"] ?? 0;
    var _target_is_player = _data[$ "target_is_player"] ?? false;
    var _source_is_player = _data[$ "source_is_player"] ?? false;
    
    if (_source_is_player)
    {
        statistics_increment("damage_dealt", _damage);
    }
    
    if (_target_is_player)
    {
        statistics_increment("damage_taken", _damage);
    }
}

/// @function statistics_on_entity_death(_data)
function statistics_on_entity_death(_data)
{
    var _killed_by_player = _data[$ "killed_by_player"] ?? false;
    var _is_player = _data[$ "is_player"] ?? false;
    var _entity_id = _data[$ "id"] ?? "";
    
    if (_killed_by_player && !_is_player)
    {
        statistics_increment("mobs_killed", 1);
        statistics_increment($"mobs_killed_{_entity_id}", 1);
    }
    
    if (_is_player)
    {
        statistics_increment("deaths", 1);
    }
}

/// @function statistics_on_item_collected(_data)
function statistics_on_item_collected(_data)
{
    var _amount = _data[$ "amount"] ?? 1;
    var _id = _data[$ "id"] ?? "";
    
    statistics_increment("items_collected", _amount);
    statistics_increment($"items_collected_{_id}", _amount);
}

/// @function statistics_on_chunk_generated(_data)
function statistics_on_chunk_generated(_data)
{
    statistics_increment("chunks_explored", 1);
}

#endregion

#region Save/Load

/// @function statistics_save_player(_buffer, _statistics)
/// @desc Save player statistics to buffer
function statistics_save_player(_buffer, _statistics = undefined)
{
    _statistics ??= global.player_statistics ?? {};

    buffer_write(_buffer, buffer_u16, STATISTICS_VERSION);
    
    var _names = struct_get_names(_statistics);
    var _count = array_length(_names);
    
    buffer_write(_buffer, buffer_u32, _count);
    
    for (var i = 0; i < _count; i++)
    {
        var _name = _names[i];
        buffer_write(_buffer, buffer_string, _name);
        buffer_write(_buffer, buffer_f64, _statistics[$ _name]);
    }
}

/// @function statistics_load_player(_buffer)
/// @desc Load player statistics from buffer
/// @returns {struct} Loaded statistics
function statistics_load_player(_buffer)
{
    var _version = buffer_read(_buffer, buffer_u16);
    var _count = buffer_read(_buffer, buffer_u32);
    
    var _statistics = {};
    
    for (var i = 0; i < _count; i++)
    {
        var _name = buffer_read(_buffer, buffer_string);
        var _value = buffer_read(_buffer, buffer_f64);
        _statistics[$ _name] = _value;
    }
    
    return _statistics;
}

/// @function statistics_save_world(_buffer, _statistics)
/// @desc Save world statistics to buffer
function statistics_save_world(_buffer, _statistics = undefined)
{
    _statistics ??= global.world_statistics ?? {};

    buffer_write(_buffer, buffer_u16, STATISTICS_VERSION);
    
    var _stat_names = struct_get_names(_statistics);
    var _stat_count = array_length(_stat_names);
    
    buffer_write(_buffer, buffer_u32, _stat_count);
    
    for (var i = 0; i < _stat_count; i++)
    {
        var _stat_name = _stat_names[i];
        var _player_data = _statistics[$ _stat_name];
        
        buffer_write(_buffer, buffer_string, _stat_name);
        
        var _player_names = struct_get_names(_player_data);
        var _player_count = array_length(_player_names);
        
        buffer_write(_buffer, buffer_u16, _player_count);
        
        for (var j = 0; j < _player_count; j++)
        {
            var _player_uuid = _player_names[j];
            buffer_write(_buffer, buffer_string, _player_uuid);
            buffer_write(_buffer, buffer_f64, _player_data[$ _player_uuid]);
        }
    }
}

/// @function statistics_load_world(_buffer)
/// @desc Load world statistics from buffer
/// @returns {struct} Loaded statistics
function statistics_load_world(_buffer)
{
    var _version = buffer_read(_buffer, buffer_u16);
    var _stat_count = buffer_read(_buffer, buffer_u32);
    
    var _statistics = {};
    
    for (var i = 0; i < _stat_count; i++)
    {
        var _stat_name = buffer_read(_buffer, buffer_string);
        var _player_count = buffer_read(_buffer, buffer_u16);
        
        _statistics[$ _stat_name] = {};
        
        for (var j = 0; j < _player_count; j++)
        {
            var _player_uuid = buffer_read(_buffer, buffer_string);
            var _value = buffer_read(_buffer, buffer_f64);
            _statistics[$ _stat_name][$ _player_uuid] = _value;
        }
    }
    
    return _statistics;
}

#endregion
