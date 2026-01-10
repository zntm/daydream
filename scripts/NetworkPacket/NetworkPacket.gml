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
