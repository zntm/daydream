/// @desc Relay protocol packet types and helpers
/// This file defines the packet format for the P2P relay system

enum RELAY_ROLE {
    NONE,
    HOST,       // Created the room, acts as relay server
    CLIENT      // Joined via invite code
}

enum RELAY_PACKET {
    // === Connection Management ===
    HELLO,              // Client -> Host: Initial handshake with identity
    WELCOME,            // Host -> Client: Accepted, here's your peer_id and peer list
    PEER_JOINED,        // Host -> All: New peer connected
    PEER_LEFT,          // Host -> All: Peer disconnected
    KICK,               // Host -> Client: You've been kicked
    
    // === Message Routing ===
    ROUTE,              // Client -> Host: Forward enclosed message to specific peer
    BROADCAST,          // Client -> Host: Forward enclosed message to all peers
    ROUTED,             // Host -> Client: A message routed from another peer
    
    // === P2P Validation ===
    VALIDATE_REQUEST,   // Peer -> All: Request validation for an action
    VALIDATE_VOTE,      // Peer -> Requester: My vote on the action
    VALIDATE_RESULT,    // Requester -> All: Final result of validation
    
    // === Game Data ===
    GAME_PACKET,        // Wraps existing PACKET_TYPE payloads
    
    // === Session Control ===
    WORLD_SYNC,         // Host -> Client: World seed, time, dimension info
    SESSION_END,        // Host -> All: Session is ending
    
    __SIZE
}

/// @desc Game-level packet types (sent inside RELAY_PACKET.GAME_PACKET wrappers)
enum PACKET_TYPE {
    PLAYER_INPUT,
    ENTITY_UPDATE,
    TILE_UPDATE,
    INVENTORY_UPDATE,
    CHUNK_REQUEST,
    CHUNK_DATA,
    TIME_UPDATE,
    PLAYER_INFO,
    ENTITY_SPAWN,
    ENTITY_DESTROY,
    ENTITY_MOVE,
    
    INVENTORY_ACTION,
    CONTAINER_OPEN,
    CONTAINER_CLOSE,
    
    __SIZE
}

enum RELAY_INVENTORY_ACTION {
    MOVE,
    SPLIT,
    DROP,
    CRAFT,
    USE
}

/// @desc Create a new relay packet buffer
/// @param {Enum.RELAY_PACKET} _type
/// @returns {Id.Buffer}
function relay_packet_create(_type)
{
    var _buffer = buffer_create(256, buffer_grow, 1);
    buffer_write(_buffer, buffer_u16, 0);   // Size placeholder
    buffer_write(_buffer, buffer_u8, _type);
    return _buffer;
}

/// @desc Read relay packet type from buffer (after size header)
/// @param {Id.Buffer} _buffer
/// @returns {Enum.RELAY_PACKET}
function relay_packet_read_type(_buffer)
{
    return buffer_read(_buffer, buffer_u8);
}

/// @desc Finalize and send relay packet with size header
/// @param {Id.Socket} _socket
/// @param {Id.Buffer} _buffer
function relay_packet_send(_socket, _buffer)
{
    var _curr_pos = buffer_tell(_buffer);
    var _size = _curr_pos - 2;  // Exclude the 2-byte size header itself
    buffer_poke(_buffer, 0, buffer_u16, _size);
    network_send_raw(_socket, _buffer, _curr_pos);
}

/// @desc Copy buffer contents from one buffer to another
/// @param {Id.Buffer} _dest Destination buffer (at current position)
/// @param {Id.Buffer} _src Source buffer (from position 0 to current position)
function relay_buffer_copy(_dest, _src)
{
    var _src_size = buffer_tell(_src);
    var _dest_pos = buffer_tell(_dest);
    buffer_copy(_src, 0, _src_size, _dest, _dest_pos);
    buffer_seek(_dest, buffer_seek_start, _dest_pos + _src_size);
}

/// @desc Copy buffer contents from source starting at offset
/// @param {Id.Buffer} _dest Destination buffer
/// @param {Id.Buffer} _src Source buffer
/// @param {Real} _offset Starting offset in source
/// @param {Real} _length Number of bytes to copy
function relay_buffer_copy_range(_dest, _src, _offset, _length)
{
    var _dest_pos = buffer_tell(_dest);
    buffer_copy(_src, _offset, _length, _dest, _dest_pos);
    buffer_seek(_dest, buffer_seek_start, _dest_pos + _length);
}

// ============================================================================
// PACKET WRITING HELPERS
// ============================================================================

/// @desc Write HELLO packet data
/// @param {Id.Buffer} _buffer
/// @param {String} _peer_id Our generated peer ID
/// @param {String} _uuid Player UUID
/// @param {Struct} _attire Player attire
function relay_write_hello(_buffer, _peer_id, _uuid, _attire)
{
    buffer_write(_buffer, buffer_string, _peer_id);
    buffer_write(_buffer, buffer_string, _uuid);
    buffer_write(_buffer, buffer_string, json_stringify(_attire ?? {}));
}

/// @desc Read HELLO packet data
/// @param {Id.Buffer} _buffer
/// @returns {Struct}
function relay_read_hello(_buffer)
{
    var _peer_id = buffer_read(_buffer, buffer_string);
    var _uuid = buffer_read(_buffer, buffer_string);
    var _attire_json = buffer_read(_buffer, buffer_string);
    
    var _attire = {}
    try { _attire = json_parse(_attire_json); } catch(_e) {}
    
    return {
        peer_id: _peer_id,
        uuid: _uuid,
        attire: _attire
    }
}

/// @desc Write WELCOME packet data
/// @param {Id.Buffer} _buffer
/// @param {String} _assigned_peer_id Peer ID assigned by host (may differ from requested)
/// @param {Array} _peer_list Array of { peer_id, uuid, attire }
/// @param {Real} _world_seed World generation seed
/// @param {Real} _world_time Current world time
function relay_write_welcome(_buffer, _assigned_peer_id, _peer_list, _world_seed, _world_time)
{
    buffer_write(_buffer, buffer_string, _assigned_peer_id);
    buffer_write(_buffer, buffer_f64, _world_seed);
    buffer_write(_buffer, buffer_f32, _world_time);
    buffer_write(_buffer, buffer_u16, array_length(_peer_list));
    
    for (var i = 0; i < array_length(_peer_list); ++i)
    {
        var _peer = _peer_list[i];
        buffer_write(_buffer, buffer_string, _peer.peer_id);
        buffer_write(_buffer, buffer_string, _peer.uuid);
        buffer_write(_buffer, buffer_string, json_stringify(_peer.attire ?? {}));
    }
}

/// @desc Read WELCOME packet data
/// @param {Id.Buffer} _buffer
/// @returns {Struct}
function relay_read_welcome(_buffer)
{
    var _peer_id = buffer_read(_buffer, buffer_string);
    var _world_seed = buffer_read(_buffer, buffer_f64);
    var _world_time = buffer_read(_buffer, buffer_f32);
    var _count = buffer_read(_buffer, buffer_u16);
    
    var _peers = [];
    for (var i = 0; i < _count; ++i)
    {
        var _p_peer_id = buffer_read(_buffer, buffer_string);
        var _p_uuid = buffer_read(_buffer, buffer_string);
        var _p_attire_json = buffer_read(_buffer, buffer_string);
        
        var _p_attire = {}
        try { _p_attire = json_parse(_p_attire_json); } catch(_e) {}
        
        array_push(_peers, {
            peer_id: _p_peer_id,
            uuid: _p_uuid,
            attire: _p_attire
        });
    }
    
    return {
        peer_id: _peer_id,
        world_seed: _world_seed,
        world_time: _world_time,
        peers: _peers
    }
}

/// @desc Write PEER_JOINED packet data
/// @param {Id.Buffer} _buffer
/// @param {String} _peer_id
/// @param {String} _uuid
/// @param {Struct} _attire
function relay_write_peer_joined(_buffer, _peer_id, _uuid, _attire)
{
    buffer_write(_buffer, buffer_string, _peer_id);
    buffer_write(_buffer, buffer_string, _uuid);
    buffer_write(_buffer, buffer_string, json_stringify(_attire ?? {}));
}

/// @desc Read PEER_JOINED packet data
/// @param {Id.Buffer} _buffer
/// @returns {Struct}
function relay_read_peer_joined(_buffer)
{
    var _peer_id = buffer_read(_buffer, buffer_string);
    var _uuid = buffer_read(_buffer, buffer_string);
    var _attire_json = buffer_read(_buffer, buffer_string);
    
    var _attire = {}
    try { _attire = json_parse(_attire_json); } catch(_e) {}
    
    return {
        peer_id: _peer_id,
        uuid: _uuid,
        attire: _attire
    }
}

/// @desc Write PEER_LEFT packet data
/// @param {Id.Buffer} _buffer
/// @param {String} _peer_id
function relay_write_peer_left(_buffer, _peer_id)
{
    buffer_write(_buffer, buffer_string, _peer_id);
}

/// @desc Read PEER_LEFT packet data
/// @param {Id.Buffer} _buffer
/// @returns {String} peer_id
function relay_read_peer_left(_buffer)
{
    return buffer_read(_buffer, buffer_string);
}

/// @desc Write ROUTE packet (client asks host to forward to specific peer)
/// @param {Id.Buffer} _buffer
/// @param {String} _target_peer_id
/// @param {Id.Buffer} _payload The inner packet to forward
function relay_write_route(_buffer, _target_peer_id, _payload)
{
    buffer_write(_buffer, buffer_string, _target_peer_id);
    
    var _payload_size = buffer_tell(_payload);
    buffer_write(_buffer, buffer_u16, _payload_size);
    relay_buffer_copy(_buffer, _payload);
}

/// @desc Write BROADCAST packet (client asks host to forward to all peers)
/// @param {Id.Buffer} _buffer
/// @param {Id.Buffer} _payload The inner packet to forward
function relay_write_broadcast(_buffer, _payload)
{
    var _payload_size = buffer_tell(_payload);
    buffer_write(_buffer, buffer_u16, _payload_size);
    relay_buffer_copy(_buffer, _payload);
}

/// @desc Write ROUTED packet (host forwards a message from one peer to another)
/// @param {Id.Buffer} _buffer
/// @param {String} _from_peer_id Original sender
/// @param {Id.Buffer} _payload The inner packet
function relay_write_routed(_buffer, _from_peer_id, _payload)
{
    buffer_write(_buffer, buffer_string, _from_peer_id);
    
    var _payload_size = buffer_tell(_payload);
    buffer_write(_buffer, buffer_u16, _payload_size);
    relay_buffer_copy(_buffer, _payload);
}

/// @desc Read ROUTED packet data
/// @param {Id.Buffer} _buffer
/// @returns {Struct} { from_peer_id, payload_buffer }
function relay_read_routed(_buffer)
{
    var _from_peer_id = buffer_read(_buffer, buffer_string);
    var _payload_size = buffer_read(_buffer, buffer_u16);
    
    // Create a new buffer for the payload
    var _payload = buffer_create(_payload_size, buffer_fixed, 1);
    for (var i = 0; i < _payload_size; ++i)
    {
        buffer_write(_payload, buffer_u8, buffer_read(_buffer, buffer_u8));
    }
    buffer_seek(_payload, buffer_seek_start, 0);
    
    return {
        from_peer_id: _from_peer_id,
        payload: _payload
    }
}
