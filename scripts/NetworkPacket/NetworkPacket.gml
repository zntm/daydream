/// @desc Network packet types and serialization helpers

enum PACKET_TYPE {
    HELLO,          // Client -> Server: Initial handshake
    WELCOME,        // Server -> Client: Handshake response with assigned UUID
    PLAYER_INPUT,   // Client -> Server: Client's input state
    ENTITY_UPDATE,  // Server -> Client: Entity state broadcast
    PLAYER_JOIN,    // Server -> Clients: A new player joined
    PLAYER_LEAVE,   // Server -> Clients: A player left
    TILE_UPDATE,         // Server -> Clients: A tile changed {x, y, z, item_id}
    TILE_UPDATE_REQUEST, // Client -> Server: Request to change a tile
    INVENTORY_UPDATE,    // Server -> Clients: Inventory slot changed
    INVENTORY_ACTION,    // Client -> Server: Request move/split/drop { type, from_inv, from_idx, to_inv, to_idx, amount }
    CONTAINER_OPEN,      // Client -> Server: Request open {x, y, z}; Server -> Client: Response {x, y, z, size}
    CONTAINER_CLOSE,     // Client/Server: Close current container
    CHUNK_REQUEST,       // Client -> Server: Request chunk data {chunk_x, chunk_y}
    CHUNK_DATA,          // Server -> Client: Chunk tile data (sparse)
    TIME_UPDATE,         // Server -> Client: Time sync
    PLAYER_INFO,         // Server -> Client: Full player data (UUID, Attire)
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
/// @param {Struct} _input { tick, move_x, move_y, jump, attack, use }
function packet_write_input(_buffer, _input)
{
    buffer_write(_buffer, buffer_u32, _input.tick);  // Tick number for reconciliation
    buffer_write(_buffer, buffer_f32, _input.move_x);
    buffer_write(_buffer, buffer_f32, _input.move_y);
    buffer_write(_buffer, buffer_u8, _input.jump);
    buffer_write(_buffer, buffer_u8, _input.attack);
    buffer_write(_buffer, buffer_u8, _input.use);
    buffer_write(_buffer, buffer_u8, _input.selected_hotbar);
}

/// @desc Deserialize input state from buffer
/// @param {Id.Buffer} _buffer
/// @returns {Struct}
function packet_read_input(_buffer)
{
    return {
        tick: buffer_read(_buffer, buffer_u32),
        move_x: buffer_read(_buffer, buffer_f32),
        move_y: buffer_read(_buffer, buffer_f32),
        jump: buffer_read(_buffer, buffer_u8),
        attack: buffer_read(_buffer, buffer_u8),
        use: buffer_read(_buffer, buffer_u8),
        selected_hotbar: buffer_read(_buffer, buffer_u8)
    };
}

/// @desc Serialize WELCOME packet
/// @param {Id.Buffer} _buffer
/// @param {String} _uuid Assigned UUID
/// @param {Real} _seed World seed
/// @param {Real} _time Current world time
function packet_write_welcome(_buffer, _uuid, _seed, _time)
{
    buffer_write(_buffer, buffer_string, _uuid);
    show_debug_message($"[NET] Writing WELCOME Seed: {_seed}");
    // Use string_format to preserve precision for floating point seeds (default string() rounds to 2 decimals)
    buffer_write(_buffer, buffer_string, string_format(_seed, 0, 20)); 
    buffer_write(_buffer, buffer_f32, _time);
}

/// @desc Deserialize WELCOME packet
/// @param {Id.Buffer} _buffer
/// @returns {Struct}
function packet_read_welcome(_buffer)
{
    var _uuid = buffer_read(_buffer, buffer_string);
    var _seed_str = buffer_read(_buffer, buffer_string);
    var _time = buffer_read(_buffer, buffer_f32);
    
    // Attempt to parse seed as number if possible, otherwise keep as string
    var _seed = _seed_str;
    try {
        if (string_digits(_seed_str) == _seed_str || string_char_at(_seed_str, 1) == "-") {
            _seed = real(_seed_str);
        }
    } catch(_e) {}
    
    return {
        uuid: _uuid,
        seed: _seed,
        time: _time
    };
}

/// @desc Write an Inventory item to buffer (Simplified JSON serialization)
/// @param {Id.Buffer} _buffer
/// @param {Struct} _item Inventory item struct or INVENTORY_EMPTY
function packet_write_item(_buffer, _item)
{
    // Use JSON for entire item to avoid field mismatch issues
    if (_item == INVENTORY_EMPTY || _item == undefined)
    {
        buffer_write(_buffer, buffer_string, "");
        return;
    }
    
    // Build a simple struct for serialization
    var _data = {
        id: _item.get_id(),
        amount: _item.get_amount()
    };
    
    // Optional durability
    var _dur = _item.get_item_durability();
    if (_dur != undefined)
    {
        _data.durability = _dur;
    }
    
    // Optional components
    var _comp = _item[$ "___component"];
    if (_comp != undefined && _item.get_components_length() > 0)
    {
        _data.components = _comp;
    }
    
    buffer_write(_buffer, buffer_string, json_stringify(_data));
}

/// @desc Read an Inventory item from buffer
/// @param {Id.Buffer} _buffer
/// @returns {Struct} Inventory item or INVENTORY_EMPTY
function packet_read_item(_buffer)
{
    var _json = buffer_read(_buffer, buffer_string);
    if (_json == "") return INVENTORY_EMPTY;
    
    try
    {
        var _data = json_parse(_json);
        if (!is_struct(_data)) return INVENTORY_EMPTY;
        
        var _id = _data[$ "id"];
        var _amount = _data[$ "amount"] ?? 1;
        
        if (_id == undefined || _id == "") return INVENTORY_EMPTY;
        
        var _item = new Inventory(_id, _amount);
        
        // Durability
        if (struct_exists(_data, "durability"))
        {
            _item.set_durability(_data.durability);
        }
        
        // Components
        if (struct_exists(_data, "components") && is_struct(_data.components))
        {
            var _comp = _data.components;
            var _names = struct_get_names(_comp);
            for (var i = 0; i < array_length(_names); ++i)
            {
                _item.set_component(_names[i], _comp[$ _names[i]]);
            }
        }
        
        return _item;
    }
    catch (_e)
    {
        show_debug_message($"[NET] Error parsing item JSON: {_e.message}");
        return INVENTORY_EMPTY;
    }
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
function packet_write_inventory_action(_buffer, _action_type, _from_inv, _from_idx, _to_inv, _to_idx, _amount)
{
    buffer_write(_buffer, buffer_u8, _action_type);
    buffer_write(_buffer, buffer_string, _from_inv);
    buffer_write(_buffer, buffer_u16, _from_idx);
    buffer_write(_buffer, buffer_string, _to_inv);
    buffer_write(_buffer, buffer_u16, _to_idx);
    buffer_write(_buffer, buffer_u16, _amount);
}

/// @desc Deserialize INVENTORY_ACTION
function packet_read_inventory_action(_buffer)
{
    return {
        type: buffer_read(_buffer, buffer_u8),
        from_inv: buffer_read(_buffer, buffer_string),
        from_idx: buffer_read(_buffer, buffer_u16),
        to_inv: buffer_read(_buffer, buffer_string),
        to_idx: buffer_read(_buffer, buffer_u16),
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
