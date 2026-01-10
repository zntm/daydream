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

/// @desc Write an Inventory item to buffer (Full serialization)
/// @param {Id.Buffer} _buffer
/// @param {Struct} _item Inventory item struct or INVENTORY_EMPTY
function packet_write_item(_buffer, _item)
{
    if (_item == INVENTORY_EMPTY || _item == undefined)
    {
        buffer_write(_buffer, buffer_string, "");
        return;
    }
    
    buffer_write(_buffer, buffer_string, _item.get_id());
    buffer_write(_buffer, buffer_u16, _item.get_amount());
    
    // Durability
    var _dur = _item.get_item_durability();
    if (_dur != undefined)
    {
        buffer_write(_buffer, buffer_u8, 1);
        buffer_write(_buffer, buffer_u32, _dur);
    }
    else
    {
        buffer_write(_buffer, buffer_u8, 0);
    }
    
    // Components (JSON string for flexibility)
    var _comp = _item[$ "___component"];
    if (_comp != undefined && _item.get_components_length() > 0)
    {
        buffer_write(_buffer, buffer_string, json_stringify(_comp));
    }
    else
    {
        buffer_write(_buffer, buffer_string, "");
    }
}

/// @desc Read an Inventory item from buffer
/// @param {Id.Buffer} _buffer
/// @returns {Struct} Inventory item or INVENTORY_EMPTY
function packet_read_item(_buffer)
{
    var _id = buffer_read(_buffer, buffer_string);
    if (_id == "") return INVENTORY_EMPTY;
    
    var _amount = buffer_read(_buffer, buffer_u16);
    var _item = new Inventory(_id, _amount);
    
    // Durability
    if (buffer_read(_buffer, buffer_u8))
    {
        _item.set_durability(buffer_read(_buffer, buffer_u32));
    }
    
    // Components
    var _comp_json = buffer_read(_buffer, buffer_string);
    if (_comp_json != "")
    {
        var _comp = json_parse(_comp_json);
        var _names = struct_get_names(_comp);
        for (var i = 0; i < array_length(_names); ++i)
        {
            _item.set_component(_names[i], _comp[$ _names[i]]);
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
    return {
        inv_name: buffer_read(_buffer, buffer_string),
        index: buffer_read(_buffer, buffer_u16),
        item: packet_read_item(_buffer)
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
    DELETE
}
