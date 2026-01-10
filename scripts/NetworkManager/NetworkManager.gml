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
    global.network_applying_packet = false;
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
            
        case PACKET_TYPE.TILE_UPDATE:
            _network_handle_tile_update(_buffer);
            break;
            
        case PACKET_TYPE.TILE_UPDATE_REQUEST:
            _network_handle_tile_request(_socket, _buffer);
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
/// @desc Handle PLAYER_INPUT packet (server only)
function _network_handle_player_input(_socket, _buffer)
{
    var _input = packet_read_input(_buffer);
    
    // Apply input to the client's player instance
    var _client = global.network_clients[? _socket];
    
    if (!is_undefined(_client))
    {
        // Store the tick so we can echo it back in updates
        _client.last_processed_tick = _input.tick;
        
        if (instance_exists(_client.player_instance))
        {
            _client.player_instance.network_input = _input;
        }
    }
}

/// @desc Handle ENTITY_UPDATE packet (client only)
function _network_handle_entity_update(_buffer)
{
    var _last_processed_tick = buffer_read(_buffer, buffer_u32);  // Server's last processed input tick
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
                if (is_local)
                {
                    // === RECONCILIATION ===
                    // Compare server state with our predicted state at that tick
                    var _reconciliation_threshold = 4;  // pixels
                    
                    last_server_tick = _last_processed_tick;
                    server_verified_x = _state.physics.x;
                    server_verified_y = _state.physics.y;
                    
                    // Find our predicted position for this tick
                    var _predicted_x = x;
                    var _predicted_y = y;
                    var _history_index = -1;
                    
                    for (var j = 0; j < array_length(input_history); ++j)
                    {
                        if (input_history[j].tick == _last_processed_tick)
                        {
                            _predicted_x = input_history[j].predicted_x;
                            _predicted_y = input_history[j].predicted_y;
                            _history_index = j;
                            break;
                        }
                    }
                    
                    // Calculate discrepancy
                    var _dx = abs(server_verified_x - _predicted_x);
                    var _dy = abs(server_verified_y - _predicted_y);
                    
                    if (_dx > _reconciliation_threshold || _dy > _reconciliation_threshold)
                    {
                        // Snap to server position
                        x = server_verified_x;
                        y = server_verified_y;
                        
                        if (variable_instance_exists(self, "physics_body"))
                        {
                            physics_body.pos_x = x;
                            physics_body.pos_y = y;
                        }
                        
                        show_debug_message($"[NET] Reconciliation: snapped from ({_predicted_x},{_predicted_y}) to ({x},{y})");
                        
                        // Discard old history (inputs before server tick are resolved)
                        if (_history_index >= 0)
                        {
                            array_delete(input_history, 0, _history_index + 1);
                        }
                        
                        // REPLAY LOOP
                        // Re-simulate physics for all pending inputs to bring us back to current time
                        var _len = array_length(input_history);
                        if (_len > 0)
                        {
                            // Applying Server Velocity
                            physics_body.vel_x = _state.physics.vx;
                            physics_body.vel_y = _state.physics.vy;
                            physics_body.sync_to_instance(self);
                            
                            for (var k = 0; k < _len; ++k)
                            {
                                var _hist = input_history[k];
                                var _inp = _hist.input;
                                
                                // Setup Input State
                                input_state.move_x = _inp.move_x;
                                input_state.move_y = _inp.move_y;
                                input_state.move_left = (_inp.move_x < 0);
                                input_state.move_right = (_inp.move_x > 0);
                                input_state.move_up = (_inp.move_y < 0);
                                input_state.move_down = (_inp.move_y > 0);
                                input_state.jump = _inp.jump;
                                // Attack/Use are event-based usually, maybe skip for movement replay?
                                
                                // Run Physics
                                // We skip full collision resolution with other entities for performance/complexity
                                // relying on static world collision in physics_step
                                physics_body.sync_from_instance(self);
                                physics_step(physics_body, input_state);
                                physics_body.sync_to_instance(self);
                                
                                // Update prediction in history
                                _hist.predicted_x = x;
                                _hist.predicted_y = y;
                            }
                        }
                    }
                    else
                    {
                        // Prediction was close enough, just clean up old history
                        if (_history_index >= 0)
                        {
                            array_delete(input_history, 0, _history_index + 1);
                        }
                    }
                }
                else
                {
                    // Remote player - set interpolation target
                    interp_start_x = x;
                    interp_start_y = y;
                    interp_target_x = _state.physics.x;
                    interp_target_y = _state.physics.y;
                    interp_timer = 0;
                    
                    // Apply other state (HP, effects, etc.)
                    hp = _state.hp;
                    hp_max = _state.hp_max;
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
            _player.interp_target_x = _state.physics.x;
            _player.interp_target_y = _state.physics.y;
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
    
    // Send to each client with their specific last_processed_tick
    var _key = ds_map_find_first(global.network_clients);
    
    while (!is_undefined(_key))
    {
        var _client = global.network_clients[? _key];
        var _last_tick = _client[$ "last_processed_tick"] ?? 0;
        
        var _buffer = packet_create(PACKET_TYPE.ENTITY_UPDATE);
        
        // Write last processed input tick for this client
        buffer_write(_buffer, buffer_u32, _last_tick);
        
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
        
        network_send_raw(_key, _buffer, buffer_tell(_buffer));
        buffer_delete(_buffer);
        
        _key = ds_map_find_next(global.network_clients, _key);
    }
}

/// @desc Send local player input to server (client only, call each tick)
function network_send_input()
{
    if (global.network_role != NETWORK_ROLE.CLIENT) return;
    if (!instance_exists(obj_Player)) return;
    
    // Get local player
    var _local_player = noone;
    with (obj_Player)
    {
        if (is_local)
        {
            _local_player = self;
            break;
        }
    }
    
    if (_local_player == noone) return;
    
    // Increment tick
    _local_player.current_tick++;
    var _tick = _local_player.current_tick;
    
    var _buffer = packet_create(PACKET_TYPE.PLAYER_INPUT);
    
    var _input = {
        tick: _tick,
        move_x: input_get_axis(true),
        move_y: input_get_axis(false),
        jump: input_check(INPUT_ACTION.JUMP),
        attack: input_check(INPUT_ACTION.ATTACK),
        use: input_check(INPUT_ACTION.USE)
    };
    
    // Store in input history for reconciliation
    var _history_entry = {
        tick: _tick,
        input: _input,
        predicted_x: _local_player.x,
        predicted_y: _local_player.y
    };
    
    array_push(_local_player.input_history, _history_entry);
    
    // Trim history if too large
    while (array_length(_local_player.input_history) > _local_player.input_history_max)
    {
        array_delete(_local_player.input_history, 0, 1);
    }
    
    packet_write_input(_buffer, _input);
    network_send_raw(global.network_client_socket, _buffer, buffer_tell(_buffer));
    buffer_delete(_buffer);
}

/// @desc Send tile update request (client only)
function network_send_tile_request(_x, _y, _z, _tile_id)
{
    if (global.network_role != NETWORK_ROLE.CLIENT) return;
    
    var _buffer = packet_create(PACKET_TYPE.TILE_UPDATE_REQUEST);
    buffer_write(_buffer, buffer_s32, _x);
    buffer_write(_buffer, buffer_s32, _y);
    buffer_write(_buffer, buffer_s32, _z);
    buffer_write(_buffer, buffer_string, _tile_id); // Sending ID string (e.g. "phantasia:stone")
    
    network_send_raw(global.network_client_socket, _buffer, buffer_tell(_buffer));
    buffer_delete(_buffer);
}

/// @desc Broadcast tile update (server only)
function network_broadcast_tile_update(_x, _y, _z, _tile_id)
{
    if (global.network_role != NETWORK_ROLE.SERVER) return;
    
    var _buffer = packet_create(PACKET_TYPE.TILE_UPDATE);
    buffer_write(_buffer, buffer_s32, _x);
    buffer_write(_buffer, buffer_s32, _y);
    buffer_write(_buffer, buffer_s32, _z);
    buffer_write(_buffer, buffer_string, _tile_id);
    
    network_broadcast_packet(_buffer);
    buffer_delete(_buffer);
}

/// @desc Handle TILE_UPDATE packet (client only)
function _network_handle_tile_update(_buffer)
{
    var _x = buffer_read(_buffer, buffer_s32);
    var _y = buffer_read(_buffer, buffer_s32);
    var _z = buffer_read(_buffer, buffer_s32);
    var _tile_id = buffer_read(_buffer, buffer_string);
    
    var _tile = new Item(_tile_id, 1);
    if (_tile_id == "base:empty") _tile = TILE_EMPTY; // Assuming "base:empty" or similar convention, or just check ID
    if (_tile_id == undefined || _tile_id == "undefined") _tile = TILE_EMPTY;

    // Apply Update
    global.network_applying_packet = true;
    tile_place(_x, _y, _z, _tile);
    global.network_applying_packet = false;
}

/// @desc Handle TILE_UPDATE_REQUEST packet (server only)
function _network_handle_tile_request(_socket, _buffer)
{
    var _x = buffer_read(_buffer, buffer_s32);
    var _y = buffer_read(_buffer, buffer_s32);
    var _z = buffer_read(_buffer, buffer_s32);
    var _tile_id = buffer_read(_buffer, buffer_string);
    
    var _client = global.network_clients[? _socket];
    if (is_undefined(_client) || !instance_exists(_client.player_instance)) return;
    
    // VALIDATION: Check distance
    var _p = _client.player_instance;
    var _dist = point_distance(_p.x, _p.y, _x * TILE_SIZE, _y * TILE_SIZE);
    
    if (_dist < 400) // Reach distance (approx 25 blocks)
    {
        var _tile = new Item(_tile_id, 1);
        if (_tile_id == "undefined") _tile = TILE_EMPTY; // Safety
        
        // Apply change (Server will broadcast via tile_place hook)
        tile_place(_x, _y, _z, _tile);
    }
    else
    {
        // Reject: Send back current state to revert client
        // Read actual tile at pos
        var _current_tile = tile_get(_x, _y, _z);
        var _current_id = (_current_tile == TILE_EMPTY) ? "undefined" : _current_tile.get_id();
        
        var _revert_buffer = packet_create(PACKET_TYPE.TILE_UPDATE);
        buffer_write(_revert_buffer, buffer_s32, _x);
        buffer_write(_revert_buffer, buffer_s32, _y);
        buffer_write(_revert_buffer, buffer_s32, _z);
        buffer_write(_revert_buffer, buffer_string, _current_id);
        
        network_send_raw(_socket, _revert_buffer, buffer_tell(_revert_buffer));
        buffer_delete(_revert_buffer);
        
        show_debug_message($"[NET] Rejected tile request from client (dist={_dist})");
    }
}
