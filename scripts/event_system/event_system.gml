/// @desc Event system for game-wide event subscription and emission

// Event type enum - diegetic gameplay events only
enum GAME_EVENT {
    // Entity Movement
    ENTITY_STEP,
    ENTITY_SWIM,
    ENTITY_LAND,
    ENTITY_SPLASH,
    
    // Entity Actions
    ENTITY_CONSUME,
    ENTITY_HEAL,
    ENTITY_DAMAGE,
    ENTITY_DIE,
    ENTITY_SPAWN,
    ENTITY_MOUNT,
    ENTITY_DISMOUNT,
    ENTITY_TELEPORT,

    // Entity Item Interactions
    ENTITY_ITEM_COLLECT,
    ENTITY_ITEM_DROP,

    // Item Events (non-entity, e.g. quiver auto-collecting arrows)
    ITEM_COLLECT,
    ITEM_DROP,

    // Tile Item Interactions (e.g. putting item in chest)
    TILE_ITEM_COLLECT,
    TILE_ITEM_DROP,

    // Projectile Events
    PROJECTILE_SHOOT,
    PROJECTILE_LAND,

    // Item Use Events
    ITEM_USE,
    ITEM_USE_START,
    ITEM_USE_FINISH,

    // Tile Use Events
    TILE_USE,
    TILE_USE_START,
    TILE_USE_FINISH,

    // Tile Placement Events
    TILE_PLACE,
    TILE_UPDATE,

    // Container Events
    TILE_CONTAINER_OPEN,
    TILE_CONTAINER_CLOSE,

    // Explosive Events
    EXPLOSIVE_PRIME,
    EXPLOSIVE_EXPLODE,

    // Miscellaneous
    TILE_FALLING_LAND,
    ITEM_CRAFT
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
/// @param {real} _event Event type from GAME_EVENT enum, or EventData instance
/// @param {struct} _data Event data to pass to callbacks (optional if using EventData)
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

// ============================================================================
// EventData Constructors
// Each GAME_EVENT has exactly one corresponding constructor for Proglang usage
// ============================================================================

/// @function EventData(_type, _data)
/// @desc Base constructor for event data
function EventData(_type, _data = {}) constructor
{
    type = _type;
    data = _data;
}

// --- Entity Movement Events ---

/// @function EventDataEntityStep(_entity, _x, _y)
function EventDataEntityStep(_entity, _x, _y) : EventData(GAME_EVENT.ENTITY_STEP) constructor
{
    data = { entity: _entity, x: _x, y: _y }
}

/// @function EventDataEntitySwim(_entity, _x, _y)
function EventDataEntitySwim(_entity, _x, _y) : EventData(GAME_EVENT.ENTITY_SWIM) constructor
{
    data = { entity: _entity, x: _x, y: _y }
}

/// @function EventDataEntityLand(_entity, _x, _y)
function EventDataEntityLand(_entity, _x, _y) : EventData(GAME_EVENT.ENTITY_LAND) constructor
{
    data = { entity: _entity, x: _x, y: _y }
}

/// @function EventDataEntitySplash(_entity, _x, _y)
function EventDataEntitySplash(_entity, _x, _y) : EventData(GAME_EVENT.ENTITY_SPLASH) constructor
{
    data = { entity: _entity, x: _x, y: _y }
}

// --- Entity Action Events ---

/// @function EventDataEntityConsume(_entity, _item)
function EventDataEntityConsume(_entity, _item) : EventData(GAME_EVENT.ENTITY_CONSUME) constructor
{
    data = { entity: _entity, item: _item }
}

/// @function EventDataEntityHeal(_entity, _amount, _source)
function EventDataEntityHeal(_entity, _amount, _source = undefined) : EventData(GAME_EVENT.ENTITY_HEAL) constructor
{
    data = { entity: _entity, amount: _amount, source: _source }
}

/// @function EventDataEntityDamage(_entity, _amount, _source, _is_critical)
function EventDataEntityDamage(_entity, _amount, _source = undefined, _is_critical = false) : EventData(GAME_EVENT.ENTITY_DAMAGE) constructor
{
    data = { entity: _entity, amount: _amount, source: _source, is_critical: _is_critical }
}

/// @function EventDataEntityDie(_entity, _killer)
function EventDataEntityDie(_entity, _killer = undefined) : EventData(GAME_EVENT.ENTITY_DIE) constructor
{
    data = { entity: _entity, killer: _killer }
}

/// @function EventDataEntitySpawn(_entity, _entity_type, _entity_id, _variant)
function EventDataEntitySpawn(_entity, _entity_type = "creature", _entity_id = undefined, _variant = undefined) : EventData(GAME_EVENT.ENTITY_SPAWN) constructor
{
    data = { entity: _entity, entity_type: _entity_type, entity_id: _entity_id, variant: _variant }
}

/// @function EventDataEntityMount(_entity, _mount)
function EventDataEntityMount(_entity, _mount) : EventData(GAME_EVENT.ENTITY_MOUNT) constructor
{
    data = { entity: _entity, mount: _mount }
}

/// @function EventDataEntityDismount(_entity, _mount)
function EventDataEntityDismount(_entity, _mount) : EventData(GAME_EVENT.ENTITY_DISMOUNT) constructor
{
    data = { entity: _entity, mount: _mount }
}

/// @function EventDataEntityTeleport(_entity, _from_x, _from_y, _to_x, _to_y)
function EventDataEntityTeleport(_entity, _from_x, _from_y, _to_x, _to_y) : EventData(GAME_EVENT.ENTITY_TELEPORT) constructor
{
    data = { entity: _entity, from_x: _from_x, from_y: _from_y, to_x: _to_x, to_y: _to_y }
}

// --- Entity Item Events ---

/// @function EventDataEntityItemCollect(_entity, _item, _amount)
function EventDataEntityItemCollect(_entity, _item, _amount = 1) : EventData(GAME_EVENT.ENTITY_ITEM_COLLECT) constructor
{
    data = { entity: _entity, item: _item, amount: _amount }
}

/// @function EventDataEntityItemDrop(_entity, _item, _amount)
function EventDataEntityItemDrop(_entity, _item, _amount = 1) : EventData(GAME_EVENT.ENTITY_ITEM_DROP) constructor
{
    data = { entity: _entity, item: _item, amount: _amount }
}

// --- Item Events (non-entity) ---

/// @function EventDataItemCollect(_item, _collector, _amount)
function EventDataItemCollect(_item, _collector, _amount = 1) : EventData(GAME_EVENT.ITEM_COLLECT) constructor
{
    data = { item: _item, collector: _collector, amount: _amount }
}

/// @function EventDataItemDrop(_item, _dropper, _amount)
function EventDataItemDrop(_item, _dropper, _amount = 1) : EventData(GAME_EVENT.ITEM_DROP) constructor
{
    data = { item: _item, dropper: _dropper, amount: _amount }
}

// --- Tile Item Events ---

/// @function EventDataTileItemCollect(_x, _y, _z, _item, _amount)
function EventDataTileItemCollect(_x, _y, _z, _item, _amount = 1) : EventData(GAME_EVENT.TILE_ITEM_COLLECT) constructor
{
    data = { x: _x, y: _y, z: _z, item: _item, amount: _amount }
}

/// @function EventDataTileItemDrop(_x, _y, _z, _item, _amount)
function EventDataTileItemDrop(_x, _y, _z, _item, _amount = 1) : EventData(GAME_EVENT.TILE_ITEM_DROP) constructor
{
    data = { x: _x, y: _y, z: _z, item: _item, amount: _amount }
}

// --- Projectile Events ---

/// @function EventDataProjectileShoot(_entity, _projectile, _x, _y, _angle, _damage)
function EventDataProjectileShoot(_entity, _projectile, _x, _y, _angle, _damage = 0) : EventData(GAME_EVENT.PROJECTILE_SHOOT) constructor
{
    data = { entity: _entity, projectile: _projectile, x: _x, y: _y, angle: _angle, damage: _damage }
}

/// @function EventDataProjectileLand(_projectile, _x, _y, _target, _land_type)
function EventDataProjectileLand(_projectile, _x, _y, _target = undefined, _land_type = "tile") : EventData(GAME_EVENT.PROJECTILE_LAND) constructor
{
    data = { projectile: _projectile, x: _x, y: _y, target: _target, land_type: _land_type }
}

// --- Item Use Events ---

/// @function EventDataItemUse(_item, _user, _x, _y)
function EventDataItemUse(_item, _user, _x, _y) : EventData(GAME_EVENT.ITEM_USE) constructor
{
    data = { item: _item, user: _user, x: _x, y: _y }
}

/// @function EventDataItemUseStart(_item, _user, _x, _y)
function EventDataItemUseStart(_item, _user, _x, _y) : EventData(GAME_EVENT.ITEM_USE_START) constructor
{
    data = { item: _item, user: _user, x: _x, y: _y }
}

/// @function EventDataItemUseFinish(_item, _user, _x, _y)
function EventDataItemUseFinish(_item, _user, _x, _y) : EventData(GAME_EVENT.ITEM_USE_FINISH) constructor
{
    data = { item: _item, user: _user, x: _x, y: _y }
}

/// @function EventDataItemCraft(_recipe, _crafter, _result)
function EventDataItemCraft(_recipe, _crafter, _result = undefined) : EventData(GAME_EVENT.ITEM_CRAFT) constructor
{
    data = { recipe: _recipe, crafter: _crafter, result: _result }
}

// --- Tile Use Events ---

/// @function EventDataTileUse(_x, _y, _z, _user)
function EventDataTileUse(_x, _y, _z, _user) : EventData(GAME_EVENT.TILE_USE) constructor
{
    data = { x: _x, y: _y, z: _z, user: _user }
}

/// @function EventDataTileUseStart(_x, _y, _z, _user)
function EventDataTileUseStart(_x, _y, _z, _user) : EventData(GAME_EVENT.TILE_USE_START) constructor
{
    data = { x: _x, y: _y, z: _z, user: _user }
}

/// @function EventDataTileUseFinish(_x, _y, _z, _user)
function EventDataTileUseFinish(_x, _y, _z, _user) : EventData(GAME_EVENT.TILE_USE_FINISH) constructor
{
    data = { x: _x, y: _y, z: _z, user: _user }
}

// --- Tile Placement Events ---

/// @function EventDataTilePlace(_x, _y, _z, _tile)
function EventDataTilePlace(_x, _y, _z, _tile) : EventData(GAME_EVENT.TILE_PLACE) constructor
{
    data = { x: _x, y: _y, z: _z, tile: _tile }
}

/// @function EventDataTileUpdate(_x, _y, _z, _tile)
function EventDataTileUpdate(_x, _y, _z, _tile = undefined) : EventData(GAME_EVENT.TILE_UPDATE) constructor
{
    data = { x: _x, y: _y, z: _z, tile: _tile }
}

// --- Container Events ---

/// @function EventDataTileContainerOpen(_x, _y, _z, _player)
function EventDataTileContainerOpen(_x, _y, _z, _player) : EventData(GAME_EVENT.TILE_CONTAINER_OPEN) constructor
{
    data = { x: _x, y: _y, z: _z, player: _player }
}

/// @function EventDataTileContainerClose(_x, _y, _z)
function EventDataTileContainerClose(_x, _y, _z) : EventData(GAME_EVENT.TILE_CONTAINER_CLOSE) constructor
{
    data = { x: _x, y: _y, z: _z }
}

// --- Explosive Events ---

/// @function EventDataExplosivePrime(_x, _y, _z, _fuse_time)
function EventDataExplosivePrime(_x, _y, _z, _fuse_time = 0) : EventData(GAME_EVENT.EXPLOSIVE_PRIME) constructor
{
    data = { x: _x, y: _y, z: _z, fuse_time: _fuse_time }
}

/// @function EventDataExplosiveExplode(_x, _y, _z, _radius, _damage)
function EventDataExplosiveExplode(_x, _y, _z, _radius, _damage = 0) : EventData(GAME_EVENT.EXPLOSIVE_EXPLODE) constructor
{
    data = { x: _x, y: _y, z: _z, radius: _radius, damage: _damage }
}

// --- Miscellaneous Events ---

/// @function EventDataTileFallingLand(_x, _y, _z, _tile)
function EventDataTileFallingLand(_x, _y, _z, _tile) : EventData(GAME_EVENT.TILE_FALLING_LAND) constructor
{
    data = { x: _x, y: _y, z: _z, tile: _tile }
}
