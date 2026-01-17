/// @desc Network packet types and serialization helpers

enum PACKET_TYPE {
    HELLO,          // Client -> Server: Initial handshake
    WELCOME,        // Server -> Client: Handshake response with assigned UUID
    PLAYER_INPUT,   // Client -> Server: Client's input state
    ENTITY_UPDATE,  // Server -> Client: Entity state broadcast (LEGACY - kept for fallback)
    PLAYER_JOIN,    // Server -> Clients: A new player joined
    PLAYER_LEAVE,   // Server -> Clients: A player left
    TILE_UPDATE,         // Server -> Clients: A tile changed {x, y, z, item_id}
    TILE_UPDATE_REQUEST, // Client -> Server: Request to change a tile
    INVENTORY_UPDATE,    // Server -> Clients: Inventory slot changed
    INVENTORY_ACTION,    // Client -> Server: Request move/split/drop { type, from_inv, from_index, to_inv, to_index, amount }
    CONTAINER_OPEN,      // Client -> Server: Request open {x, y, z}; Server -> Client: Response {x, y, z, size}
    CONTAINER_CLOSE,     // Client/Server: Close current container
    CHUNK_REQUEST,       // Client -> Server: Request chunk data {chunk_x, chunk_y}
    CHUNK_DATA,          // Server -> Client: Chunk tile data (sparse)
    TIME_UPDATE,         // Server -> Client: Time sync
    PLAYER_INFO,         // Server -> Client: Full player data (UUID, Attire)
    
    // New Minecraft-style entity packets
    ENTITY_SPAWN,        // Server -> Client: Entity spawned (EID, type, pos, type-data)
    ENTITY_DESTROY,      // Server -> Client: Entity destroyed (EID)
    ENTITY_MOVE,         // Server -> Client: Relative position update (EID, dx, dy, dvx, dvy)
    ENTITY_TELEPORT,     // Server -> Client: Absolute position update (EID, x, y, vx, vy)
    ENTITY_METADATA,     // Server -> Client: Entity metadata update (EID, key-value pairs)
    
    __SIZE
}


/// @desc Create a new buffer for a packet
/// @param {Enum.PACKET_TYPE} _type
/// @returns {Id.Buffer}
function packet_create(_type)
{
    var _buffer = buffer_create(256, buffer_grow, 1);
    buffer_write(_buffer, buffer_u16, 0); // Placeholder for Size
    buffer_write(_buffer, buffer_u8, _type);
    return _buffer;
}

/// @desc Read packet type from the beginning of a buffer
/// @param {Id.Buffer} _buffer
/// @returns {Enum.PACKET_TYPE}
/// @desc Read packet type from current buffer position
/// @param {Id.Buffer} _buffer
/// @returns {Enum.PACKET_TYPE}
function packet_read_type(_buffer)
{
    // buffer_seek(_buffer, buffer_seek_start, 0); // Removed seek for stream reading
    return buffer_read(_buffer, buffer_u8);
}

/// @desc Finalize and send packet with size header
/// @param {Id.Socket} _socket
/// @param {Id.Buffer} _buffer
function packet_send(_socket, _buffer)
{
    var _curr_pos = buffer_tell(_buffer);
    var _size = _curr_pos - 2; 
    buffer_poke(_buffer, 0, buffer_u16, _size);
    network_send_raw(_socket, _buffer, _curr_pos);
}

/// @desc Serialize input state to buffer (includes tick for reconciliation)
/// @param {Id.Buffer} _buffer
/// @param {Struct} _input { tick, move_x, move_y, jump_held, jump_pressed, attack_held, attack_pressed, use_held, use_pressed, selected_hotbar }
function packet_write_input(_buffer, _input)
{
    buffer_write(_buffer, buffer_u32, _input.tick);  // Tick number for reconciliation
    buffer_write(_buffer, buffer_f32, _input.move_x);
    buffer_write(_buffer, buffer_f32, _input.move_y);
    
    // Pack buttons into a bitfield
    var _flags = 0;
    if (_input.jump_held)      _flags |= 1 << 0;
    if (_input.jump_pressed)   _flags |= 1 << 1;
    if (_input.attack_held)    _flags |= 1 << 2;
    if (_input.attack_pressed) _flags |= 1 << 3;
    if (_input.use_held)       _flags |= 1 << 4;
    if (_input.use_pressed)    _flags |= 1 << 5;
    
    buffer_write(_buffer, buffer_u16, _flags);
    buffer_write(_buffer, buffer_u8, _input.selected_hotbar);
}

/// @desc Deserialize input state from buffer
/// @param {Id.Buffer} _buffer
/// @returns {Struct}
function packet_read_input(_buffer)
{
    var _data = {
        tick:            buffer_read(_buffer, buffer_u32),
        move_x:          buffer_read(_buffer, buffer_f32),
        move_y:          buffer_read(_buffer, buffer_f32),
    };
    
    var _flags = buffer_read(_buffer, buffer_u16);
    _data.jump_held      = !!(_flags & (1 << 0));
    _data.jump_pressed   = !!(_flags & (1 << 1));
    _data.attack_held    = !!(_flags & (1 << 2));
    _data.attack_pressed = !!(_flags & (1 << 3));
    _data.use_held       = !!(_flags & (1 << 4));
    _data.use_pressed    = !!(_flags & (1 << 5));
    
    _data.selected_hotbar = buffer_read(_buffer, buffer_u8);
    
    return _data;
}

/// @desc Serialize WELCOME packet
/// @param {Id.Buffer} _buffer
/// @param {String} _uuid Assigned UUID
/// @param {Real} _seed World seed
/// @param {Real} _time Current world time
/// @param {Struct} _terrain_config Terrain shaping config
function packet_write_welcome(_buffer, _uuid, _seed, _time, _terrain_config)
{
    buffer_write(_buffer, buffer_string, _uuid);
    
    // Ensure seed is a number before sending
    var _noise_seed = _seed;
    if (is_string(_noise_seed)) _noise_seed = string_get_seed(_noise_seed);
    if (!is_real(_noise_seed)) _noise_seed = 0;
    
    show_debug_message($"[NET] Writing WELCOME Seed: {_noise_seed}"); 
    buffer_write(_buffer, buffer_f64, _noise_seed); 
    buffer_write(_buffer, buffer_f32, _time);
    
    // Write terrain config as JSON
    var _config_json = (_terrain_config != undefined) ? json_stringify(_terrain_config) : "{}";
    buffer_write(_buffer, buffer_string, _config_json);
}

/// @desc Deserialize WELCOME packet
/// @param {Id.Buffer} _buffer
/// @returns {Struct}
function packet_read_welcome(_buffer)
{
    var _uuid = buffer_read(_buffer, buffer_string);
    var _seed = buffer_read(_buffer, buffer_f64);
    var _time = buffer_read(_buffer, buffer_f32);
    
    var _config_json = buffer_read(_buffer, buffer_string);
    var _terrain_config = {};
    try
    {
        _terrain_config = json_parse(_config_json);
    }
    catch(_e)
    {
        show_debug_message($"[NET] Failed to parse terrain config: {_e.message}");
    }
    
    return {
        uuid: _uuid,
        seed: _seed,
        time: _time,
        terrain_config: _terrain_config
    };
}

/// @desc Write an Inventory item to buffer (Binary serialization)
/// @param {Id.Buffer} _buffer
/// @param {Struct} _item Inventory item struct or INVENTORY_EMPTY
/// Bitmask header (u8):
///   Bit 0: Has item (1 = yes, 0 = empty slot)
///   Bit 1: Amount != 1 (1 = write u16 amount, 0 = default to 1)
///   Bit 2: Durability present (1 = write f32)
///   Bit 3: Components present (1 = write component data)
function packet_write_item(_buffer, _item)
{
    if (_item == INVENTORY_EMPTY || _item == undefined)
    {
        buffer_write(_buffer, buffer_u8, 0); // Bitmask: no item
        return;
    }
    
    var _id = _item.get_id();
    var _amount = _item.get_amount();
    var _dur = _item.get_item_durability();
    var _comp = _item[$ "___component"];
    var _comp_len = _item.get_components_length();
    
    // Build bitmask
    var _flags = 1; // Bit 0: Has item
    if (_amount != 1) _flags |= (1 << 1);
    if (_dur != undefined) _flags |= (1 << 2);
    if (_comp != undefined && _comp_len > 0) _flags |= (1 << 3);
    
    buffer_write(_buffer, buffer_u8, _flags);
    buffer_write(_buffer, buffer_string, _id);
    
    if (_flags & (1 << 1)) buffer_write(_buffer, buffer_u16, _amount);
    if (_flags & (1 << 2)) buffer_write(_buffer, buffer_f32, _dur);
    if (_flags & (1 << 3))
    {
        var _names = struct_get_names(_comp);
        buffer_write(_buffer, buffer_u8, array_length(_names));
        for (var i = 0; i < array_length(_names); ++i)
        {
            buffer_write(_buffer, buffer_string, _names[i]);
            buffer_write(_buffer, buffer_string, json_stringify(_comp[$ _names[i]])); // Components can be complex
        }
    }
}

/// @desc Read an Inventory item from buffer (Binary deserialization)
/// @param {Id.Buffer} _buffer
/// @returns {Struct} Inventory item or INVENTORY_EMPTY
function packet_read_item(_buffer)
{
    var _flags = buffer_read(_buffer, buffer_u8);
    
    if (!(_flags & 1)) return INVENTORY_EMPTY; // Bit 0 not set = empty
    
    var _id = buffer_read(_buffer, buffer_string);
    if (_id == "") return INVENTORY_EMPTY;
    
    var _amount = 1;
    if (_flags & (1 << 1)) _amount = buffer_read(_buffer, buffer_u16);
    
    var _item = new Inventory(_id, _amount);
    
    if (_flags & (1 << 2))
    {
        var _dur = buffer_read(_buffer, buffer_f32);
        _item.set_durability(_dur);
    }
    
    if (_flags & (1 << 3))
    {
        var _comp_count = buffer_read(_buffer, buffer_u8);
        for (var i = 0; i < _comp_count; ++i)
        {
            var _comp_name = buffer_read(_buffer, buffer_string);
            var _comp_val_json = buffer_read(_buffer, buffer_string);
            try
            {
                _item.set_component(_comp_name, json_parse(_comp_val_json));
            }
            catch (_e)
            {
                show_debug_message($"[NET] Error parsing component '{_comp_name}': {_e.message}");
            }
        }
    }
    
    return _item;
}

/// @desc Serialize inventory update
/// @param {Id.Buffer} _buffer
/// @param {String} _inv_name ("base", "armor_helmet", etc)
/// @param {Real} _index Slot index
/// @param {Struct} _item Inventory item
function packet_write_inventory_update(_buffer, _inv_name, _index, _item)
{
    buffer_write(_buffer, buffer_string, _inv_name);
    buffer_write(_buffer, buffer_u16, _index);
    packet_write_item(_buffer, _item);
}

/// @desc Deserialize inventory update
/// @param {Id.Buffer} _buffer
/// @returns {Struct}
function packet_read_inventory_update(_buffer)
{
    var _inv_name = buffer_read(_buffer, buffer_string);
    var _index = buffer_read(_buffer, buffer_u16);
    var _item = packet_read_item(_buffer);
    
    return {
        inv_name: _inv_name,
        index: _index,
        item: _item
    };
}

/// @desc Serialize INVENTORY_ACTION
function packet_write_inventory_action(_buffer, _action_type, _from_inv, _from_index, _to_inv, _to_index, _amount)
{
    buffer_write(_buffer, buffer_u8, _action_type);
    buffer_write(_buffer, buffer_string, _from_inv);
    buffer_write(_buffer, buffer_u16, _from_index);
    buffer_write(_buffer, buffer_string, _to_inv);
    buffer_write(_buffer, buffer_u16, _to_index);
    buffer_write(_buffer, buffer_u16, _amount);
}

/// @desc Deserialize INVENTORY_ACTION
function packet_read_inventory_action(_buffer)
{
    return {
        type: buffer_read(_buffer, buffer_u8),
        from_inv: buffer_read(_buffer, buffer_string),
        from_index: buffer_read(_buffer, buffer_u16),
        to_inv: buffer_read(_buffer, buffer_string),
        to_index: buffer_read(_buffer, buffer_u16),
        amount: buffer_read(_buffer, buffer_u16)
    };
}

/// @desc Serialize CONTAINER_OPEN
function packet_write_container_open(_buffer, _x, _y, _z, _size = 0)
{
    buffer_write(_buffer, buffer_s32, _x);
    buffer_write(_buffer, buffer_s32, _y);
    buffer_write(_buffer, buffer_s32, _z);
    buffer_write(_buffer, buffer_u16, _size);
}

/// @desc Deserialize CONTAINER_OPEN
function packet_read_container_open(_buffer)
{
    return {
        x: buffer_read(_buffer, buffer_s32),
        y: buffer_read(_buffer, buffer_s32),
        z: buffer_read(_buffer, buffer_s32),
        size: buffer_read(_buffer, buffer_u16)
    };
}

enum INVENTORY_ACTION_TYPE {
    MOVE,
    SPLIT,
    DROP,
    DELETE,
    CRAFT
}

/// @desc Serialize CHUNK_REQUEST
/// @param {Id.Buffer} _buffer
/// @param {Real} _chunk_x Chunk world X (pixel)
/// @param {Real} _chunk_y Chunk world Y (pixel)
function packet_write_chunk_request(_buffer, _chunk_x, _chunk_y)
{
    buffer_write(_buffer, buffer_s32, _chunk_x);
    buffer_write(_buffer, buffer_s32, _chunk_y);
}

/// @desc Deserialize CHUNK_REQUEST
/// @param {Id.Buffer} _buffer
/// @returns {Struct}
function packet_read_chunk_request(_buffer)
{
    return {
        chunk_x: buffer_read(_buffer, buffer_s32),
        chunk_y: buffer_read(_buffer, buffer_s32)
    };
}

/// @desc Serialize CHUNK_DATA (sparse format)
/// @param {Id.Buffer} _buffer
/// @param {Real} _chunk_x Chunk world X (pixel)
/// @param {Real} _chunk_y Chunk world Y (pixel)
/// @param {Array} _tiles Array of { local_x, local_y, z, tile_id }
function packet_write_chunk_data(_buffer, _chunk_x, _chunk_y, _tiles)
{
    buffer_write(_buffer, buffer_s32, _chunk_x);
    buffer_write(_buffer, buffer_s32, _chunk_y);
    buffer_write(_buffer, buffer_u16, array_length(_tiles));
    
    for (var i = 0; i < array_length(_tiles); ++i)
    {
        var _t = _tiles[i];
        buffer_write(_buffer, buffer_u8, _t.local_x);
        buffer_write(_buffer, buffer_u8, _t.local_y);
        buffer_write(_buffer, buffer_u8, _t.z);
        buffer_write(_buffer, buffer_string, _t.tile_id);
    }
}

/// @desc Deserialize CHUNK_DATA
/// @param {Id.Buffer} _buffer
/// @returns {Struct}
function packet_read_chunk_data(_buffer)
{
    var _chunk_x = buffer_read(_buffer, buffer_s32);
    var _chunk_y = buffer_read(_buffer, buffer_s32);
    var _count = buffer_read(_buffer, buffer_u16);
    var _tiles = [];
    
    for (var i = 0; i < _count; ++i)
    {
        array_push(_tiles, {
            local_x: buffer_read(_buffer, buffer_u8),
            local_y: buffer_read(_buffer, buffer_u8),
            z: buffer_read(_buffer, buffer_u8),
            tile_id: buffer_read(_buffer, buffer_string)
        });
    }
    
    return {
        chunk_x: _chunk_x,
        chunk_y: _chunk_y,
        tiles: _tiles
    };
}
/// @desc Serialize TIME_UPDATE
/// @param {Id.Buffer} _buffer
/// @param {Real} _time
function packet_write_time_update(_buffer, _time)
{
    buffer_write(_buffer, buffer_f32, _time);
}

/// @desc Deserialize TIME_UPDATE
/// @param {Id.Buffer} _buffer
/// @returns {Real}
function packet_read_time_update(_buffer)
{
    return buffer_read(_buffer, buffer_f32);
}

/// @desc Serialize PLAYER_INFO (Full data including attire)
/// @param {Id.Buffer} _buffer
/// @param {String} _uuid
/// @param {Struct} _attire
/// @desc Serialize PLAYER_INFO (Full data including attire)
/// @param {Id.Buffer} _buffer
/// @param {String} _uuid
/// @param {Struct} _attire
function packet_write_player_info(_buffer, _uuid, _attire)
{
    buffer_write(_buffer, buffer_string, _uuid);
    var _json = (_attire != undefined) ? json_stringify(_attire) : "{}";
    buffer_write(_buffer, buffer_string, _json);
}

/// @desc Deserialize PLAYER_INFO
/// @param {Id.Buffer} _buffer
/// @returns {Struct} {uuid, attire}
function packet_read_player_info(_buffer)
{
    var _uuid = buffer_read(_buffer, buffer_string);
    var _json = buffer_read(_buffer, buffer_string);
    
    var _attire = {};
    try
    {
        _attire = json_parse(_json);
    }
    catch (_e)
    {
        show_debug_message($"[NET] JSON Parse Error in PLAYER_INFO: {_e.message}. JSON: {_json}");
    }
    
    return {
        uuid: _uuid,
        attire: _attire
    };
}
