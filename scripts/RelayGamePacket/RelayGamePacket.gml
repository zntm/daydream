/// @desc Relay Game Packet - Game-level packet serialization for relay transmission
/// Handles serialization/deserialization of game data (entities, tiles, inventory, etc.)

/// @desc Send a game packet through the relay to a specific peer
/// @param {String} _peer_id Target peer
/// @param {Enum.PACKET_TYPE} _packet_type The game packet type
/// @param {Id.Buffer} _game_buffer The game packet buffer (with data, no size header)
function relay_send_game_packet(_peer_id, _packet_type, _game_buffer)
{
    var _wrapper = relay_packet_create(RELAY_PACKET.GAME_PACKET);
    buffer_write(_wrapper, buffer_u8, _packet_type);
    
    var _game_size = buffer_tell(_game_buffer);
    buffer_write(_wrapper, buffer_u16, _game_size);
    relay_buffer_copy(_wrapper, _game_buffer);
    
    global.relay.send_to_peer(_peer_id, _wrapper);
    buffer_delete(_wrapper);
}

/// @desc Broadcast a game packet through the relay to all peers
/// @param {Enum.PACKET_TYPE} _packet_type The game packet type
/// @param {Id.Buffer} _game_buffer The game packet buffer
/// @param {String} _exclude_peer_id Optional peer to exclude
function relay_broadcast_game_packet(_packet_type, _game_buffer, _exclude_peer_id = "")
{
    var _wrapper = relay_packet_create(RELAY_PACKET.GAME_PACKET);
    buffer_write(_wrapper, buffer_u8, _packet_type);
    
    var _game_size = buffer_tell(_game_buffer);
    buffer_write(_wrapper, buffer_u16, _game_size);
    relay_buffer_copy(_wrapper, _game_buffer);
    
    global.relay.broadcast(_wrapper, _exclude_peer_id);
    buffer_delete(_wrapper);
}

/// @desc Read game packet wrapper and extract inner packet
/// @param {Id.Buffer} _buffer Buffer positioned after GAME_PACKET type byte
/// @returns {Struct} { packet_type, payload_buffer }
function relay_read_game_packet(_buffer)
{
    var _packet_type = buffer_read(_buffer, buffer_u8);
    var _payload_size = buffer_read(_buffer, buffer_u16);
    
    var _payload = buffer_create(_payload_size, buffer_fixed, 1);
    for (var i = 0; i < _payload_size; ++i)
    {
        buffer_write(_payload, buffer_u8, buffer_read(_buffer, buffer_u8));
    }
    buffer_seek(_payload, buffer_seek_start, 0);
    
    return {
        packet_type: _packet_type,
        payload: _payload
    };
}

// ============================================================================
// PACKET SERIALIZATION / DESERIALIZATION
// ============================================================================

/// @desc Write input state
function relay_write_input(_buffer, _input)
{
    buffer_write(_buffer, buffer_u32, _input.tick);
    buffer_write(_buffer, buffer_f32, _input.move_x);
    buffer_write(_buffer, buffer_f32, _input.move_y);
    
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

/// @desc Read input state
function relay_read_input(_buffer)
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

/// @desc Write inventory item
function relay_write_item(_buffer, _item)
{
    if (_item == INVENTORY_EMPTY || _item == undefined)
    {
        buffer_write(_buffer, buffer_u8, 0); 
        return;
    }
    
    var _id = _item.get_id();
    var _amount = _item.get_amount();
    var _dur = _item.get_item_durability();
    var _comp = _item[$ "___component"];
    var _comp_len = _item.get_components_length();
    
    var _flags = 1; 
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
            buffer_write(_buffer, buffer_string, json_stringify(_comp[$ _names[i]]));
        }
    }
}

/// @desc Read inventory item
function relay_read_item(_buffer)
{
    var _flags = buffer_read(_buffer, buffer_u8);
    if (!(_flags & 1)) return INVENTORY_EMPTY;
    
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
            try { _item.set_component(_comp_name, json_parse(_comp_val_json)); } catch(_e) {}
        }
    }
    
    return _item;
}

/// @desc Write inventory update
function relay_write_inventory_update(_buffer, _inv_name, _index, _item)
{
    buffer_write(_buffer, buffer_string, _inv_name);
    buffer_write(_buffer, buffer_u16, _index);
    relay_write_item(_buffer, _item);
}

/// @desc Read inventory update
function relay_read_inventory_update(_buffer)
{
    return {
        inv_name: buffer_read(_buffer, buffer_string),
        index: buffer_read(_buffer, buffer_u16),
        item: relay_read_item(_buffer)
    };
}

/// @desc Write time update
function relay_write_time_update(_buffer, _time)
{
    buffer_write(_buffer, buffer_f32, _time);
}

/// @desc Read time update
function relay_read_time_update(_buffer)
{
    return buffer_read(_buffer, buffer_f32);
}

/// @desc Write chunk data
function relay_write_chunk_data(_buffer, _chunk_x, _chunk_y, _tiles)
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

/// @desc Read chunk data
function relay_read_chunk_data(_buffer)
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

/// @desc Write player info
function relay_write_player_info(_buffer, _uuid, _attire)
{
    buffer_write(_buffer, buffer_string, _uuid);
    buffer_write(_buffer, buffer_string, json_stringify(_attire ?? {}));
}

/// @desc Read player info
function relay_read_player_info(_buffer)
{
    var _uuid = buffer_read(_buffer, buffer_string);
    var _json = buffer_read(_buffer, buffer_string);
    var _attire = {};
    try { _attire = json_parse(_json); } catch(_e) {}
    
    return {
        uuid: _uuid,
        attire: _attire
    };
}

/// @desc Write entity spawn
function relay_write_entity_spawn(_buffer, _state)
{
    _state.to_buffer(_buffer);
}

/// @desc Read entity spawn
function relay_read_entity_spawn(_buffer)
{
    var _state = new EntityState();
    _state.from_buffer(_buffer);
    return _state;
}

/// @desc Write entity destroy
function relay_write_entity_destroy(_buffer, _uuid)
{
    buffer_write(_buffer, buffer_string, _uuid);
}

/// @desc Read entity destroy
function relay_read_entity_destroy(_buffer)
{
    return buffer_read(_buffer, buffer_string);
}

/// @desc Write entity move
function relay_write_entity_move(_buffer, _uuid, _x, _y)
{
    buffer_write(_buffer, buffer_string, _uuid);
    buffer_write(_buffer, buffer_f32, _x);
    buffer_write(_buffer, buffer_f32, _y);
}

/// @desc Read entity move
function relay_read_entity_move(_buffer)
{
    return {
        uuid: buffer_read(_buffer, buffer_string),
        x: buffer_read(_buffer, buffer_f32),
        y: buffer_read(_buffer, buffer_f32)
    };
}

// ============================================================================
// CONVENIENCE WRAPPERS
// ============================================================================

/// @desc Send entity state update to all peers
function relay_send_entity_update(_entity)
{
    if (global.relay == undefined || global.relay.role == RELAY_ROLE.NONE) return;
    
    var _state = new EntityState();
    _state.from_instance(_entity);
    
    var _buf = buffer_create(256, buffer_grow, 1);
    
    // Write count=1 for compatibility with old ENTITY_UPDATE list format if needed,
    // Write the entity state to the buffer
    // read a count (u16) then loop. Let's keep that format for now.
    buffer_write(_buf, buffer_u16, 1); 
    _state.to_buffer(_buf);
    
    relay_broadcast_game_packet(PACKET_TYPE.ENTITY_UPDATE, _buf);
    buffer_delete(_buf);
}

/// @desc Send player input to all peers
function relay_send_player_input(_input)
{
    if (global.relay == undefined || global.relay.role == RELAY_ROLE.NONE) return;
    
    var _buf = buffer_create(64, buffer_grow, 1);
    relay_write_input(_buf, _input);
    
    relay_broadcast_game_packet(PACKET_TYPE.PLAYER_INPUT, _buf);
    buffer_delete(_buf);
}

/// @desc Send tile update to all peers
function relay_send_tile_update(_x, _y, _z, _tile_id)
{
    if (global.relay == undefined || global.relay.role == RELAY_ROLE.NONE) return;
    
    var _buf = buffer_create(64, buffer_grow, 1);
    buffer_write(_buf, buffer_s32, _x);
    buffer_write(_buf, buffer_s32, _y);
    buffer_write(_buf, buffer_s32, _z);
    buffer_write(_buf, buffer_string, _tile_id);
    
    relay_broadcast_game_packet(PACKET_TYPE.TILE_UPDATE, _buf);
    buffer_delete(_buf);
}

/// @desc Request tile change through validation
function relay_request_tile_change(_x, _y, _z, _tile_id, _prev_tile_id = "")
{
    if (global.relay == undefined || global.relay.role == RELAY_ROLE.NONE)
    {
        var _tile = (_tile_id != "" && _tile_id != "undefined") ? new Tile(_tile_id) : TILE_EMPTY;
        global.network_applying_packet = true;
        tile_place(_x, _y, _z, _tile);
        global.network_applying_packet = false;
        return;
    }
    
    var _action_type = (_tile_id == "" || _tile_id == "undefined") 
        ? ACTION_TYPE.TILE_BREAK 
        : ACTION_TYPE.TILE_PLACE;
    
    var _data = {
        x: _x, y: _y, z: _z,
        tile_id: _tile_id,
        previous_tile_id: _prev_tile_id
    };
    
    // Apply optimistically
    var _tile = (_tile_id != "" && _tile_id != "undefined") ? new Tile(_tile_id) : TILE_EMPTY;
    global.network_applying_packet = true;
    tile_place(_x, _y, _z, _tile);
    global.network_applying_packet = false;
    
    var _action_id = global.validator.request_validation(_action_type, _data);
    global.validator.pending[$ _action_id].applied_optimistically = true;
}

/// @desc Send inventory update to a specific peer
function relay_send_inventory_update(_peer_id, _inv_name, _index, _item)
{
    if (global.relay == undefined || global.relay.role == RELAY_ROLE.NONE) return;
    
    var _buf = buffer_create(256, buffer_grow, 1);
    relay_write_inventory_update(_buf, _inv_name, _index, _item);
    
    relay_send_game_packet(_peer_id, PACKET_TYPE.INVENTORY_UPDATE, _buf);
    buffer_delete(_buf);
}

/// @desc Send time update to all peers
function relay_send_time_update(_time)
{
    if (global.relay == undefined || global.relay.role == RELAY_ROLE.NONE) return;
    
    var _buf = buffer_create(8, buffer_grow, 1);
    relay_write_time_update(_buf, _time);
    
    relay_broadcast_game_packet(PACKET_TYPE.TIME_UPDATE, _buf);
    buffer_delete(_buf);
}

/// @desc Send chunk data to a specific peer
function relay_send_chunk_data(_peer_id, _chunk_x, _chunk_y, _tiles)
{
    if (global.relay == undefined || global.relay.role == RELAY_ROLE.NONE) return;
    
    var _buf = buffer_create(4096, buffer_grow, 1);
    relay_write_chunk_data(_buf, _chunk_x, _chunk_y, _tiles);
    
    relay_send_game_packet(_peer_id, PACKET_TYPE.CHUNK_DATA, _buf);
    buffer_delete(_buf);
}

/// @desc Send player info to all peers
function relay_send_player_info(_uuid, _attire)
{
    if (global.relay == undefined || global.relay.role == RELAY_ROLE.NONE) return;
    
    var _buf = buffer_create(256, buffer_grow, 1);
    relay_write_player_info(_buf, _uuid, _attire);
    
    relay_broadcast_game_packet(PACKET_TYPE.PLAYER_INFO, _buf);
    buffer_delete(_buf);
}

/// @desc Send entity spawn to all peers (or specific if needed)
function relay_send_entity_spawn(_entity, _target_peer_id = undefined)
{
    if (global.relay == undefined || global.relay.role == RELAY_ROLE.NONE) return;
    
    var _state = new EntityState();
    _state.capture(_entity);
    
    var _buf = buffer_create(256, buffer_grow, 1);
    relay_write_entity_spawn(_buf, _state);
    
    if (_target_peer_id != undefined)
        relay_send_game_packet(_target_peer_id, PACKET_TYPE.ENTITY_SPAWN, _buf);
    else
        relay_broadcast_game_packet(PACKET_TYPE.ENTITY_SPAWN, _buf);
        
    buffer_delete(_buf);
}

/// @desc Send entity destroy to all peers
function relay_send_entity_destroy(_uuid)
{
    if (global.relay == undefined || global.relay.role == RELAY_ROLE.NONE) return;
    
    var _buf = buffer_create(64, buffer_grow, 1);
    relay_write_entity_destroy(_buf, _uuid);
    
    relay_broadcast_game_packet(PACKET_TYPE.ENTITY_DESTROY, _buf);
    buffer_delete(_buf);
}

/// @desc Send entity move to all peers
function relay_send_entity_move(_uuid, _x, _y)
{
    if (global.relay == undefined || global.relay.role == RELAY_ROLE.NONE) return;
    
    var _buf = buffer_create(64, buffer_grow, 1);
    relay_write_entity_move(_buf, _uuid, _x, _y);
    
    relay_broadcast_game_packet(PACKET_TYPE.ENTITY_MOVE, _buf);
    buffer_delete(_buf);
}
