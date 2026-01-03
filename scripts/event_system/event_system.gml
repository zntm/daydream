/// @desc Event system for game-wide event subscription and emission

// Event type enum - simplified
enum GAME_EVENT {
    TILE_CHANGED,       // Tile placed or destroyed
    ENTITY_SPAWNED,     // Entity created
    ENTITY_DAMAGED,     // Entity took damage (includes player)
    ENTITY_HEALED,      // Entity healed (includes player)
    ENTITY_DEATH,       // Entity died (includes player)
    ITEM_COLLECTED,     // Item picked up
    ITEM_DROPPED,       // Item dropped
    CHUNK_GENERATED,    // Chunk finished generating
    EXPLOSION,          // Explosion occurred
    STATISTIC_CHANGED,  // Statistic value updated
    ACHIEVEMENT_UNLOCKED, // Achievement completed
    CRAFTING_COMPLETE,  // Item crafted
    ITEM_USED           // Item or consumable used
}

global.event_listeners = {}

/// @function event_subscribe(_event, _callback)
/// @desc Subscribe to an event
/// @param {real} _event Event type from GAME_EVENT enum
/// @param {function} _callback Function to call when event fires
/// @returns {struct} Subscription handle (for unsubscribing)
function event_subscribe(_event, _callback)
{
    global.event_listeners[$ _event] ??= [];
    
    var _subscription = {
        event: _event,
        callback: _callback,
        active: true
    }
    
    array_push(global.event_listeners[$ _event], _subscription);
    
    return _subscription;
}

/// @function event_unsubscribe(_subscription)
/// @desc Unsubscribe from an event using the subscription handle
/// @param {struct} _subscription The subscription handle from event_subscribe
function event_unsubscribe(_subscription)
{
    _subscription.active = false;
    
    var _listeners = global.event_listeners[$ _subscription.event];
    
    if (_listeners == undefined) exit;
    
    for (var i = array_length(_listeners) - 1; i >= 0; --i)
    {
        if (_listeners[i] == _subscription)
        {
            array_delete(_listeners, i, 1);
            
            break;
        }
    }
}

/// @function event_emit(_event, _data)
/// @desc Emit an event to all subscribers
/// @param {real} _event Event type from GAME_EVENT enum
/// @param {struct} _data Event data to pass to callbacks
function event_emit(_event, _data = {})
{
    // Handle EventData constructor usage: using single argument
    if (is_struct(_event) && struct_exists(_event, "type") && struct_exists(_event, "data"))
    {
        _data = _event.data;
        _event = _event.type;
    }

    var _listeners = global.event_listeners[$ _event];
    
    if (_listeners == undefined) exit;
    
    var _length = array_length(_listeners);
    
    for (var i = 0; i < _length; ++i)
    {
        var _subscription = _listeners[i];
        
        if (_subscription.active)
        {
            _subscription.callback(_data);
        }
    }
}

/// @function event_clear(_event)
/// @desc Clear all listeners for a specific event
/// @param {real} _event Event type from GAME_EVENT enum
function event_clear(_event)
{
    var _data = global.event_listeners[$ _event];
    var _length = array_length(_data);
    
    repeat (_length)
    {
        delete global.event_listeners[$ _event][@ 0];
        
        array_delete(global.event_listeners[$ _event], 0, 1);
    }
}

/// @function event_clear_all()
/// @desc Clear all event listeners
function event_clear_all()
{
    var _event_listeners = global.event_listeners;
    
    var _names = struct_get_names(_event_listeners);
    var _names_length = array_length(_names);
    
    for (var i = 0; i < _names_length; ++i)
    {
        var _name = _names[i];
        
        var _data = global.event_listeners[$ _name];
        var _length = array_length(_data);
        
        repeat (_length)
        {
            delete global.event_listeners[$ _name][@ 0];
            
            array_delete(global.event_listeners[$ _name], 0, 1);
        }
        
        struct_remove(global.event_listeners, _name);
    }
}

/// @function EventData(_type, _data)
/// @desc Base constructor for event data
function EventData(_type, _data = {}) constructor
{
    type = _type;
    data = _data;
}

function EventDataExplosion(_x, _y, _radius) : EventData(GAME_EVENT.EXPLOSION) constructor
{
    data = { x: _x, y: _y, radius: _radius }
}

function EventDataAchievementUnlocked(_id) : EventData(GAME_EVENT.ACHIEVEMENT_UNLOCKED) constructor
{
    data = { id: _id }
}


function EventDataEntitySpawned(_entity) : EventData(GAME_EVENT.ENTITY_SPAWNED) constructor
{
    data = { entity: _entity }
}

function EventDataEntityDamaged(_target, _amount, _source) : EventData(GAME_EVENT.ENTITY_DAMAGED) constructor
{
    data = { target: _target, amount: _amount, source: _source }
}

function EventDataEntityHealed(_target, _amount, _source) : EventData(GAME_EVENT.ENTITY_HEALED) constructor
{
    data = { target: _target, amount: _amount, source: _source }
}

function EventDataEntityDeath(_entity, _cause) : EventData(GAME_EVENT.ENTITY_DEATH) constructor
{
    data = { entity: _entity, cause: _cause }
}

function EventDataItemCollected(_item, _collector) : EventData(GAME_EVENT.ITEM_COLLECTED) constructor
{
    data = { item: _item, collector: _collector }
}

function EventDataItemDropped(_item, _dropper) : EventData(GAME_EVENT.ITEM_DROPPED) constructor
{
    data = { item: _item, dropper: _dropper }
}

function EventDataChunkGenerated(_chunk_x, _chunk_y) : EventData(GAME_EVENT.CHUNK_GENERATED) constructor
{
    data = { chunk_x: _chunk_x, chunk_y: _chunk_y }
}

function EventDataStatisticChanged(_stat, _value) : EventData(GAME_EVENT.STATISTIC_CHANGED) constructor
{
    data = { stat: _stat, value: _value }
}

function EventDataCraftingComplete(_recipe, _crafter) : EventData(GAME_EVENT.CRAFTING_COMPLETE) constructor
{
    data = { recipe: _recipe, crafter: _crafter }
}

function EventDataItemUsed(_item, _user) : EventData(GAME_EVENT.ITEM_USED) constructor
{
    data = { item: _item, user: _user }
}


}
