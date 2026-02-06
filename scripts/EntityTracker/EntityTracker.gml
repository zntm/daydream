/// @desc Entity Tracker for efficient network synchronization
/// Uses integer Entity IDs (EIDs) and delta compression

// --- EID Allocator ---
global.network_eid_counter = 0;
global.network_eid_to_instance = ds_map_create();  // EID -> instance
global.network_instance_to_eid = ds_map_create();  // instance.id -> EID
global.network_entity_trackers = ds_map_create();  // EID -> EntityTracker

/// @desc Allocate a new Entity ID
/// @returns {Real} New EID
function network_eid_allocate()
{
    return ++global.network_eid_counter;
}

/// @desc Register an instance with an EID
/// @param {Id.Instance} _inst
/// @returns {Real} Assigned EID
function network_eid_register(_inst)
{
    // Check if already registered
    var _existing = ds_map_find_value(global.network_instance_to_eid, _inst.id);
    if (!is_undefined(_existing)) return _existing;
    
    var _eid = network_eid_allocate();
    ds_map_add(global.network_eid_to_instance, _eid, _inst);
    ds_map_add(global.network_instance_to_eid, _inst.id, _eid);
    
    // Create tracker
    var _tracker = new EntityTracker(_inst, _eid);
    ds_map_add(global.network_entity_trackers, _eid, _tracker);
    
    return _eid;
}

/// @desc Assign a specific EID to an instance (Client side)
/// @param {Id.Instance} _inst
/// @param {Real} _eid
function network_eid_assign(_inst, _eid)
{
    // Clean up valid previous ID if exists
    var _prev_eid = network_eid_get(_inst);
    if (!is_undefined(_prev_eid)) network_eid_free(_prev_eid);

    ds_map_add(global.network_eid_to_instance, _eid, _inst);
    ds_map_add(global.network_instance_to_eid, _inst.id, _eid);
}

/// @desc Free an EID and its tracker
/// @param {Real} _eid
function network_eid_free(_eid)
{
    if (is_undefined(_eid)) return;
    
    var _inst = ds_map_find_value(global.network_eid_to_instance, _eid);
    if (!is_undefined(_inst))
        ds_map_delete(global.network_instance_to_eid, _inst);
        
    var _tracker = ds_map_find_value(global.network_entity_trackers, _eid);
    if (_tracker != undefined) delete _tracker;
    
    ds_map_delete(global.network_entity_trackers, _eid);
    ds_map_delete(global.network_eid_to_instance, _eid);
}

/// @desc Unregister an instance, freeing its EID
/// @param {Id.Instance} _inst
function network_eid_unregister(_inst)
{
    var _eid = ds_map_find_value(global.network_instance_to_eid, _inst.id);
    network_eid_free(_eid);
}

/// @desc Get EID for an instance
/// @param {Id.Instance} _inst
/// @returns {Real} EID or undefined
function network_eid_get(_inst)
{
    return ds_map_find_value(global.network_instance_to_eid, _inst.id);
}

/// @desc Get instance for an EID
/// @param {Real} _eid
/// @returns {Id.Instance} Instance or noone
function network_instance_get(_eid)
{
    var _inst = ds_map_find_value(global.network_eid_to_instance, _eid);
    if (is_undefined(_inst) || !instance_exists(_inst)) return noone;
    return _inst;
}

/// @desc Get tracker for an EID
/// @param {Real} _eid
/// @returns {Struct.EntityTracker}
function network_tracker_get(_eid)
{
    return ds_map_find_value(global.network_entity_trackers, _eid);
}

// --- Entity Tracker Struct ---

/// @desc Tracks entity state for delta compression
/// @param {Id.Instance} _inst
/// @param {Real} _eid
function EntityTracker(_inst, _eid) constructor
{
    eid = _eid;
    instance = _inst;
    
    // Entity type (for spawn packet)
    entity_type = ENTITY_NET_TYPE.UNKNOWN;
    if (_inst.object_index == obj_Player || _inst.object_index == obj_Client)
        entity_type = ENTITY_NET_TYPE.PLAYER;
    else if (_inst.object_index == obj_Creature)
        entity_type = ENTITY_NET_TYPE.CREATURE;
    else if (_inst.object_index == obj_Item_Drop)
        entity_type = ENTITY_NET_TYPE.ITEM_DROP;
    else if (_inst.object_index == obj_Projectile)
        entity_type = ENTITY_NET_TYPE.PROJECTILE;
    
    // Last sent position (fixed-point, 1/32 of a pixel)
    last_x = 0;
    last_y = 0;
    last_vx = 0;
    last_vy = 0;
    
    // Last sent metadata
    last_hp = 0;
    last_hp_max = 0;
    
    // Dirty flags
    spawned = false;  // Has spawn packet been sent?
    
    /// @desc Capture current state and return packets to send
    /// @returns {Array} Array of packet buffers to send (caller must delete)
    static get_update_packets = function()
    {
        var _packets = [];
        
        if (!instance_exists(instance)) return _packets;
        
        // Get current position (fixed-point)
        var _curr_x = round(instance.x * 32);
        var _curr_y = round(instance.y * 32);
        var _curr_vx = 0;
        var _curr_vy = 0;
        
        if (variable_instance_exists(instance, "physics_body"))
        {
            _curr_vx = round(instance.physics_body.vel_x * 8000);
            _curr_vy = round(instance.physics_body.vel_y * 8000);
        }
        
        // --- SPAWN ---
        if (!spawned)
        {
            var _buf = packet_create(PACKET_TYPE.ENTITY_SPAWN);
            buffer_write(_buf, buffer_u32, eid);
            buffer_write(_buf, buffer_u8, entity_type);
            buffer_write(_buf, buffer_string, instance.uuid);
            buffer_write(_buf, buffer_s32, _curr_x);
            buffer_write(_buf, buffer_s32, _curr_y);
            buffer_write(_buf, buffer_s16, _curr_vx);
            buffer_write(_buf, buffer_s16, _curr_vy);
            
            // Type-specific data
            _write_type_data(_buf);
            
            array_push(_packets, _buf);
            
            last_x = _curr_x;
            last_y = _curr_y;
            last_vx = _curr_vx;
            last_vy = _curr_vy;
            spawned = true;
            
            // Also send initial metadata
            var _meta_buf = _get_metadata_packet();
            if (_meta_buf != undefined) array_push(_packets, _meta_buf);
            
            return _packets;
        }
        
        // --- MOVEMENT ---
        var _dx = _curr_x - last_x;
        var _dy = _curr_y - last_y;
        var _dvx = _curr_vx - last_vx;
        var _dvy = _curr_vy - last_vy;
        
        var _moved = (_dx != 0 || _dy != 0 || _dvx != 0 || _dvy != 0);
        
        if (_moved)
        {
            // Check if delta fits in RelMove (s16)
            var _can_relmove = (abs(_dx) < 32767 && abs(_dy) < 32767);
            
            if (_can_relmove)
            {
                var _buf = packet_create(PACKET_TYPE.ENTITY_MOVE);
                buffer_write(_buf, buffer_u32, eid);
                buffer_write(_buf, buffer_s16, _dx);
                buffer_write(_buf, buffer_s16, _dy);
                buffer_write(_buf, buffer_s16, _dvx);
                buffer_write(_buf, buffer_s16, _dvy);
                array_push(_packets, _buf);
            }
            else
            {
                // Teleport (absolute)
                var _buf = packet_create(PACKET_TYPE.ENTITY_TELEPORT);
                buffer_write(_buf, buffer_u32, eid);
                buffer_write(_buf, buffer_s32, _curr_x);
                buffer_write(_buf, buffer_s32, _curr_y);
                buffer_write(_buf, buffer_s16, _curr_vx);
                buffer_write(_buf, buffer_s16, _curr_vy);
                array_push(_packets, _buf);
            }
            
            last_x = _curr_x;
            last_y = _curr_y;
            last_vx = _curr_vx;
            last_vy = _curr_vy;
        }
        
        // --- METADATA ---
        var _meta_buf = _get_metadata_packet();
        if (_meta_buf != undefined) array_push(_packets, _meta_buf);
        
        return _packets;
    }
    
    /// @desc Write type-specific spawn data
    static _write_type_data = function(_buf)
    {
        switch (entity_type)
        {
            case ENTITY_NET_TYPE.CREATURE:
                buffer_write(_buf, buffer_string, instance._id);
                break;
            case ENTITY_NET_TYPE.ITEM_DROP:
                if (struct_exists(instance, "item"))
                {
                    buffer_write(_buf, buffer_string, instance.item.get_id());
                    buffer_write(_buf, buffer_u16, instance.item.get_amount());
                }
                else
                {
                    buffer_write(_buf, buffer_string, "");
                    buffer_write(_buf, buffer_u16, 0);
                }
                break;
            case ENTITY_NET_TYPE.PROJECTILE:
                buffer_write(_buf, buffer_string, instance._id);
                buffer_write(_buf, buffer_f32, instance.damage);
                break;
            case ENTITY_NET_TYPE.PLAYER:
                // Player attire (JSON for flexibility, sent once on spawn)
                var _attire_json = "{}";
                if (variable_instance_exists(instance, "attire"))
                    _attire_json = json_stringify(instance.attire);
                buffer_write(_buf, buffer_string, _attire_json);
                break;
        }
    }
    
    /// @desc Check for metadata changes and return packet if needed
    static _get_metadata_packet = function()
    {
        if (!instance_exists(instance)) return undefined;
        
        var _hp = variable_instance_exists(instance, "hp") ? instance.hp : 0;
        var _hp_max = variable_instance_exists(instance, "hp_max") ? instance.hp_max : 0;
        
        if (_hp == last_hp && _hp_max == last_hp_max) return undefined;
        
        var _buf = packet_create(PACKET_TYPE.ENTITY_METADATA);
        buffer_write(_buf, buffer_u32, eid);
        
        // Simple key-value: HP
        buffer_write(_buf, buffer_u8, 1);  // 1 entry
        buffer_write(_buf, buffer_u8, ENTITY_META_KEY.HP);
        buffer_write(_buf, buffer_f32, _hp);
        buffer_write(_buf, buffer_f32, _hp_max);
        
        last_hp = _hp;
        last_hp_max = _hp_max;
        
        return _buf;
    }
}

// --- Enums ---

enum ENTITY_NET_TYPE
{
    UNKNOWN,
    PLAYER,
    CREATURE,
    ITEM_DROP,
    PROJECTILE
}

enum ENTITY_META_KEY
{
    HP,
    EFFECTS,
    SELECTED_HOTBAR
}
