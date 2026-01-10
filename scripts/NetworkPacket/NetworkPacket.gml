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
    __SIZE
}

/// @desc Create a new buffer for a packet
/// @param {Enum.PACKET_TYPE} _type
/// @returns {Id.Buffer}
function packet_create(_type)
{
    var _buffer = buffer_create(256, buffer_grow, 1);
    buffer_write(_buffer, buffer_u8, _type);
    return _buffer;
}

/// @desc Read packet type from the beginning of a buffer
/// @param {Id.Buffer} _buffer
/// @returns {Enum.PACKET_TYPE}
function packet_read_type(_buffer)
{
    buffer_seek(_buffer, buffer_seek_start, 0);
    return buffer_read(_buffer, buffer_u8);
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
        use: buffer_read(_buffer, buffer_u8)
    };
}

/// @desc Serialize inventory update
/// @param {Id.Buffer} _buffer
/// @param {String} _inv_name ("base", "armor_helmet", etc)
/// @param {Real} _index Slot index
/// @param {String} _item_id Item ID (or "" if empty)
/// @param {Real} _amount Item amount
function packet_write_inventory_update(_buffer, _inv_name, _index, _item_id, _amount)
{
    buffer_write(_buffer, buffer_string, _inv_name);
    buffer_write(_buffer, buffer_u16, _index);
    buffer_write(_buffer, buffer_string, _item_id);
    buffer_write(_buffer, buffer_u16, _amount);
}

/// @desc Serialize WELCOME packet
/// @param {Id.Buffer} _buffer
/// @param {String} _uuid Assigned UUID
/// @param {Real} _seed World seed
/// @param {Real} _time Current world time
function packet_write_welcome(_buffer, _uuid, _seed, _time)
{
    buffer_write(_buffer, buffer_string, _uuid);
    buffer_write(_buffer, buffer_u32, _seed);
    buffer_write(_buffer, buffer_f32, _time);
}

/// @desc Deserialize WELCOME packet
/// @param {Id.Buffer} _buffer
/// @returns {Struct}
function packet_read_welcome(_buffer)
{
    return {
        uuid: buffer_read(_buffer, buffer_string),
        seed: buffer_read(_buffer, buffer_u32),
        time: buffer_read(_buffer, buffer_f32)
    };
}

/// @desc Deserialize inventory update
/// @param {Id.Buffer} _buffer
/// @returns {Struct}
function packet_read_inventory_update(_buffer)
{
    return {
        inv_name: buffer_read(_buffer, buffer_string),
        index: buffer_read(_buffer, buffer_u16),
        item_id: buffer_read(_buffer, buffer_string),
        amount: buffer_read(_buffer, buffer_u16)
    };
}
