/// @desc Network manager for server/client functionality

// Network state globals
global.network_role = undefined;  // "server", "client", or undefined
global.network_server_socket = undefined;
global.network_client_socket = undefined;
global.network_clients = ds_map_create();  // socket_id -> { uuid, player_instance }
global.network_host_ip = "127.0.0.1";
global.network_port = 6510;
global.network_buffer = buffer_create(4096, buffer_grow, 1);

enum NETWORK_ROLE {
    NONE,
    SERVER,
    CLIENT
}

/// @desc Initialize network globals
function network_init()
{
    global.network_role = NETWORK_ROLE.NONE;
    global.network_server_socket = undefined;
    global.network_client_socket = undefined;
    ds_map_clear(global.network_clients);
}

/// @desc Start a server on the specified port
/// @param {Real} _port
/// @returns {Bool} Success
function network_start_server(_port)
{
    if (global.network_role != NETWORK_ROLE.NONE)
    {
        show_debug_message("[NET] Cannot start server: already in a network session");
        return false;
    }
    
    var _socket = network_create_server(network_socket_tcp, _port, 8);
    
    if (_socket < 0)
    {
        show_debug_message($"[NET] Failed to create server on port {_port}");
        return false;
    }
    
    global.network_server_socket = _socket;
    global.network_role = NETWORK_ROLE.SERVER;
    global.network_port = _port;
    
    show_debug_message($"[NET] Server started on port {_port}");
    return true;
}

/// @desc Connect to a server
/// @param {String} _ip
/// @param {Real} _port
/// @returns {Bool} Success (connection initiated)
function network_connect_to_server(_ip, _port)
{
    if (global.network_role != NETWORK_ROLE.NONE)
    {
        show_debug_message("[NET] Cannot connect: already in a network session");
        return false;
    }
    
    var _socket = network_create_socket(network_socket_tcp);
    
    if (_socket < 0)
    {
        show_debug_message("[NET] Failed to create client socket");
        return false;
    }
    
    var _result = network_connect(_socket, _ip, _port);
    
    if (_result < 0)
    {
        show_debug_message($"[NET] Failed to initiate connection to {_ip}:{_port}");
        network_destroy(_socket);
        return false;
    }
    
    global.network_client_socket = _socket;
    global.network_role = NETWORK_ROLE.CLIENT;
    global.network_host_ip = _ip;
    global.network_port = _port;
    
    show_debug_message($"[NET] Connecting to {_ip}:{_port}...");
    return true;
}

/// @desc Disconnect from the network session
function network_disconnect()
{
    if (global.network_role == NETWORK_ROLE.SERVER)
    {
        // Notify all clients
        var _key = ds_map_find_first(global.network_clients);
        while (!is_undefined(_key))
        {
            network_destroy(_key);
            _key = ds_map_find_next(global.network_clients, _key);
        }
        ds_map_clear(global.network_clients);
        
        network_destroy(global.network_server_socket);
        global.network_server_socket = undefined;
    }
    else if (global.network_role == NETWORK_ROLE.CLIENT)
    {
        network_destroy(global.network_client_socket);
        global.network_client_socket = undefined;
    }
    
    global.network_role = NETWORK_ROLE.NONE;
    show_debug_message("[NET] Disconnected");
}

/// @desc Send a buffer to a specific socket
/// @param {Id.Socket} _socket
/// @param {Id.Buffer} _buffer
function network_send_packet(_socket, _buffer)
{
    var _size = buffer_tell(_buffer);
    network_send_packet(_socket, _buffer, _size);
}

/// @desc Broadcast a buffer to all connected clients (server only)
/// @param {Id.Buffer} _buffer
function network_broadcast_packet(_buffer)
{
    if (global.network_role != NETWORK_ROLE.SERVER) return;
    
    var _size = buffer_tell(_buffer);
    var _key = ds_map_find_first(global.network_clients);
    
    while (!is_undefined(_key))
    {
        network_send_raw(_key, _buffer, _size);
        _key = ds_map_find_next(global.network_clients, _key);
    }
}

/// @desc Handle incoming network async event
/// @param {Real} _type_event async_load type
function network_handle_async(_type_event)
{
    switch (_type_event)
    {
        case network_type_connect:
            _network_handle_connect();
            break;
            
        case network_type_disconnect:
            _network_handle_disconnect();
            break;
            
        case network_type_data:
            _network_handle_data();
            break;
    }
}

/// @desc Internal: Handle new connection
function _network_handle_connect()
{
    var _socket = async_load[? "socket"];
    
    if (global.network_role == NETWORK_ROLE.SERVER)
    {
        // A client connected to us
        var _uuid = string(irandom(999999999));  // Temporary UUID generation
        
        ds_map_add(global.network_clients, _socket, {
            uuid: _uuid,
            player_instance: noone
        });
        
        show_debug_message($"[NET] Client connected: socket={_socket}, uuid={_uuid}");
        
        // Send WELCOME packet with UUID
        var _buffer = packet_create(PACKET_TYPE.WELCOME);
        buffer_write(_buffer, buffer_string, _uuid);
        network_send_raw(_socket, _buffer, buffer_tell(_buffer));
        buffer_delete(_buffer);
        
        // Spawn remote player for this client
        var _player = instance_create_depth(obj_Player.x, obj_Player.y, 0, obj_Player);
        _player.is_local = false;
        _player.uuid = _uuid;
        _player.socket_id = _socket;
        
        global.network_clients[? _socket].player_instance = _player;
        
        // Notify other clients about new player
        var _join_buffer = packet_create(PACKET_TYPE.PLAYER_JOIN);
        buffer_write(_join_buffer, buffer_string, _uuid);
        
        var _key = ds_map_find_first(global.network_clients);
        while (!is_undefined(_key))
        {
            if (_key != _socket)
            {
                network_send_raw(_key, _join_buffer, buffer_tell(_join_buffer));
            }
            _key = ds_map_find_next(global.network_clients, _key);
        }
        buffer_delete(_join_buffer);
    }
    else if (global.network_role == NETWORK_ROLE.CLIENT)
    {
        // We connected to the server
        show_debug_message("[NET] Connected to server!");
        
        // Send HELLO packet
        var _buffer = packet_create(PACKET_TYPE.HELLO);
        buffer_write(_buffer, buffer_string, global.player_save_data.uuid);
        network_send_raw(global.network_client_socket, _buffer, buffer_tell(_buffer));
        buffer_delete(_buffer);
    }
}

/// @desc Internal: Handle disconnection
function _network_handle_disconnect()
{
    var _socket = async_load[? "socket"];
    
    if (global.network_role == NETWORK_ROLE.SERVER)
    {
        // A client disconnected
        var _client = global.network_clients[? _socket];
        
        if (!is_undefined(_client))
        {
            show_debug_message($"[NET] Client disconnected: uuid={_client.uuid}");
            
            // Destroy their player instance
            if (instance_exists(_client.player_instance))
            {
                instance_destroy(_client.player_instance);
            }
            
            // Notify other clients
            var _buffer = packet_create(PACKET_TYPE.PLAYER_LEAVE);
            buffer_write(_buffer, buffer_string, _client.uuid);
            
            var _key = ds_map_find_first(global.network_clients);
            while (!is_undefined(_key))
            {
                if (_key != _socket)
                {
                    network_send_raw(_key, _buffer, buffer_tell(_buffer));
                }
                _key = ds_map_find_next(global.network_clients, _key);
            }
            buffer_delete(_buffer);
            
            ds_map_delete(global.network_clients, _socket);
        }
    }
    else if (global.network_role == NETWORK_ROLE.CLIENT)
    {
        // We got disconnected from the server
        show_debug_message("[NET] Disconnected from server");
        network_disconnect();
    }
}

/// @desc Internal: Handle incoming data
function _network_handle_data()
{
    var _socket = async_load[? "socket"];
    var _buffer = async_load[? "buffer"];
    
    var _packet_type = packet_read_type(_buffer);
    
    switch (_packet_type)
    {
        case PACKET_TYPE.HELLO:
            _network_handle_hello(_socket, _buffer);
            break;
            
        case PACKET_TYPE.WELCOME:
            _network_handle_welcome(_buffer);
            break;
            
        case PACKET_TYPE.PLAYER_INPUT:
            _network_handle_player_input(_socket, _buffer);
            break;
            
        case PACKET_TYPE.ENTITY_UPDATE:
            _network_handle_entity_update(_buffer);
            break;
            
        case PACKET_TYPE.PLAYER_JOIN:
            _network_handle_player_join(_buffer);
            break;
            
        case PACKET_TYPE.PLAYER_LEAVE:
            _network_handle_player_leave(_buffer);
            break;
    }
}

/// @desc Handle HELLO packet (server only)
function _network_handle_hello(_socket, _buffer)
{
    var _client_uuid = buffer_read(_buffer, buffer_string);
    
    // Update client info with their actual UUID
    if (ds_map_exists(global.network_clients, _socket))
    {
        var _client = global.network_clients[? _socket];
        _client.uuid = _client_uuid;
        
        if (instance_exists(_client.player_instance))
        {
            _client.player_instance.uuid = _client_uuid;
        }
        
        show_debug_message($"[NET] Client identified: uuid={_client_uuid}");
    }
}

/// @desc Handle WELCOME packet (client only)
function _network_handle_welcome(_buffer)
{
    var _assigned_uuid = buffer_read(_buffer, buffer_string);
    show_debug_message($"[NET] Received WELCOME, assigned UUID: {_assigned_uuid}");
    
    // Could update local player UUID if needed
}

/// @desc Handle PLAYER_INPUT packet (server only)
function _network_handle_player_input(_socket, _buffer)
{
    var _input = packet_read_input(_buffer);
    
    // Apply input to the client's player instance
    var _client = global.network_clients[? _socket];
    
    if (!is_undefined(_client) && instance_exists(_client.player_instance))
    {
        _client.player_instance.network_input = _input;
    }
}

/// @desc Handle ENTITY_UPDATE packet (client only)
function _network_handle_entity_update(_buffer)
{
    var _entity_count = buffer_read(_buffer, buffer_u16);
    
    for (var i = 0; i < _entity_count; ++i)
    {
        var _state = new EntityState();
        _state.from_buffer(_buffer);
        
        // Find or create entity instance
        var _found = false;
        
        with (obj_Player)
        {
            if (uuid == _state.uuid)
            {
                if (!is_local)
                {
                    _state.apply(self);
                }
                _found = true;
                break;
            }
        }
        
        // If not found and not our local player, create remote player
        if (!_found && _state.entity_type == "player")
        {
            var _player = instance_create_depth(_state.physics.x, _state.physics.y, 0, obj_Player);
            _player.is_local = false;
            _player.uuid = _state.uuid;
            _state.apply(_player);
        }
    }
}

/// @desc Handle PLAYER_JOIN packet (client only)
function _network_handle_player_join(_buffer)
{
    var _uuid = buffer_read(_buffer, buffer_string);
    show_debug_message($"[NET] Player joined: uuid={_uuid}");
    
    // Create remote player instance
    var _player = instance_create_depth(obj_Player.x, obj_Player.y, 0, obj_Player);
    _player.is_local = false;
    _player.uuid = _uuid;
}

/// @desc Handle PLAYER_LEAVE packet (client only)
function _network_handle_player_leave(_buffer)
{
    var _uuid = buffer_read(_buffer, buffer_string);
    show_debug_message($"[NET] Player left: uuid={_uuid}");
    
    // Find and destroy remote player instance
    with (obj_Player)
    {
        if (uuid == _uuid && !is_local)
        {
            instance_destroy();
            break;
        }
    }
}

/// @desc Broadcast entity states to all clients (server only, call each tick)
function network_broadcast_entities()
{
    if (global.network_role != NETWORK_ROLE.SERVER) return;
    
    var _buffer = packet_create(PACKET_TYPE.ENTITY_UPDATE);
    
    // Count players
    var _count = instance_number(obj_Player);
    buffer_write(_buffer, buffer_u16, _count);
    
    // Write each player's state
    with (obj_Player)
    {
        var _state = new EntityState();
        _state.capture(self);
        _state.to_buffer(_buffer);
    }
    
    network_broadcast_packet(_buffer);
    buffer_delete(_buffer);
}

/// @desc Send local player input to server (client only, call each tick)
function network_send_input()
{
    if (global.network_role != NETWORK_ROLE.CLIENT) return;
    
    var _buffer = packet_create(PACKET_TYPE.PLAYER_INPUT);
    
    var _input = {
        move_x: input_get_axis(true),
        move_y: input_get_axis(false),
        jump: input_check(INPUT_ACTION.JUMP),
        attack: input_check(INPUT_ACTION.ATTACK),
        use: input_check(INPUT_ACTION.USE)
    };
    
    packet_write_input(_buffer, _input);
    network_send_raw(global.network_client_socket, _buffer, buffer_tell(_buffer));
    buffer_delete(_buffer);
}
