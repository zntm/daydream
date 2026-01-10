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
            
        case PACKET_TYPE.INVENTORY_UPDATE:
            _network_handle_inventory_update(_buffer);
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
        
        // Initialize server-side inventory for this client
        _network_init_client_inventory(_client);
        
        show_debug_message($"[NET] Client identified: uuid={_client_uuid}");
        
        // Send WELCOME packet with assigned UUID, World Seed, and World Time
        var _welcome = packet_create(PACKET_TYPE.WELCOME);
        packet_write_welcome(_welcome, _client_uuid, global.world_save_data.seed, global.world_save_data.time);
        network_send_raw(_socket, _welcome, buffer_tell(_welcome));
        buffer_delete(_welcome);
    }
}

/// @desc Handle WELCOME packet (client only)
function _network_handle_welcome(_buffer)
{
    var _data = packet_read_welcome(_buffer);
    show_debug_message($"[NET] Received WELCOME. UUID: {_data.uuid}, Seed: {_data.seed}, Time: {_data.time}");
    
    // Sync World Seed
    global.world_save_data.seed = _data.seed;
    open_simplex_noise_seed(_data.seed);
    
    // Sync World Time
    // obj_Game_Control.timer_respawn = _data.time; // If this is used for time
    
    // Could update local player UUID
    if (instance_exists(obj_Player))
    {
        with(obj_Player) { if (is_local) uuid = _data.uuid; }
    }
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
    
    var _received_uuids = {}; // Track UUIDs for despawning logic
    
    for (var i = 0; i < _entity_count; ++i)
    {
        var _state = new EntityState();
        _state.from_buffer(_buffer);
        
        _received_uuids[$ _state.uuid] = true;
        
        // Find existing entity
        var _inst = noone;
        var _is_player = (_state.entity_type == "player");
        
        // Check Players
        if (_is_player)
        {
            with (obj_Player)
            {
                if (uuid == _state.uuid) { _inst = id; break; }
            }
        }
        else
        {
            // Check other entities
            // Optimization: Could use a global map uuid->instance if searching becomes slow
            with (obj_Creature) { if (uuid == _state.uuid) { _inst = id; break; } }
            if (_inst == noone) with (obj_Item_Drop) { if (uuid == _state.uuid) { _inst = id; break; } }
            if (_inst == noone) with (obj_Projectile) { if (uuid == _state.uuid) { _inst = id; break; } }
        }
        
        if (instance_exists(_inst))
        {
            // --- UPDATE EXISTING ---
            if (_is_player && _inst.is_local)
            {
                // === RECONCILIATION (Local Player) ===
                var _reconciliation_threshold = 4;  // pixels
                
                _inst.last_server_tick = _last_processed_tick;
                _inst.server_verified_x = _state.physics.x;
                _inst.server_verified_y = _state.physics.y;
                
                // Find our predicted position for this tick
                var _predicted_x = _inst.x;
                var _predicted_y = _inst.y;
                var _history_index = -1;
                
                for (var j = 0; j < array_length(_inst.input_history); ++j)
                {
                    if (_inst.input_history[j].tick == _last_processed_tick)
                    {
                        _predicted_x = _inst.input_history[j].predicted_x;
                        _predicted_y = _inst.input_history[j].predicted_y;
                        _history_index = j;
                        break;
                    }
                }
                
                // Calculate discrepancy
                var _dx = abs(_inst.server_verified_x - _predicted_x);
                var _dy = abs(_inst.server_verified_y - _predicted_y);
                
                if (_dx > _reconciliation_threshold || _dy > _reconciliation_threshold)
                {
                    // Snap to server position
                    _inst.x = _inst.server_verified_x;
                    _inst.y = _inst.server_verified_y;
                    
                    if (variable_instance_exists(_inst, "physics_body"))
                    {
                        _inst.physics_body.pos_x = _inst.x;
                        _inst.physics_body.pos_y = _inst.y;
                    }
                    
                    show_debug_message($"[NET] Reconciliation: snapped from ({_predicted_x},{_predicted_y}) to ({_inst.x},{_inst.y})");
                    
                    // Discard old history
                    if (_history_index >= 0)
                    {
                        array_delete(_inst.input_history, 0, _history_index + 1);
                    }
                    
                    // REPLAY LOOP
                    var _len = array_length(_inst.input_history);
                    if (_len > 0)
                    {
                        // Sync velocity from server state for accurate replay start
                        _inst.physics_body.vel_x = _state.physics.vx;
                        _inst.physics_body.vel_y = _state.physics.vy;
                        _inst.physics_body.sync_to_instance(_inst);
                        
                        for (var k = 0; k < _len; ++k)
                        {
                            var _hist = _inst.input_history[k];
                            var _inp = _hist.input;
                            
                            // Apply input to player state
                            _inst.input_state.move_x = _inp.move_x;
                            _inst.input_state.move_y = _inp.move_y;
                            _inst.input_state.move_left = (_inp.move_x < 0);
                            _inst.input_state.move_right = (_inp.move_x > 0);
                            _inst.input_state.move_up = (_inp.move_y < 0);
                            _inst.input_state.move_down = (_inp.move_y > 0);
                            _inst.input_state.jump = _inp.jump;
                            
                            _inst.physics_body.sync_from_instance(_inst);
                            physics_step(_inst.physics_body, _inst.input_state); // Assuming physics_step is global/accessible
                            _inst.physics_body.sync_to_instance(_inst);
                            
                            _hist.predicted_x = _inst.x;
                            _hist.predicted_y = _inst.y;
                        }
                    }
                }
                else
                {
                    // Valid prediction
                    if (_history_index >= 0)
                    {
                        array_delete(_inst.input_history, 0, _history_index + 1);
                    }
                }
            }
            else
            {
                // === INTERPOLATION (Remote Player / Entity) ===
                if (variable_instance_exists(_inst, "interp_start_x"))
                {
                    _inst.interp_start_x = _inst.x;
                    _inst.interp_start_y = _inst.y;
                    _inst.interp_target_x = _state.physics.x;
                    _inst.interp_target_y = _state.physics.y;
                    _inst.interp_timer = 0;
                }
                else
                {
                    _inst.x = _state.physics.x;
                    _inst.y = _state.physics.y;
                }
                
                // For non-local entities, strictly apply state
                if (!_is_player || !_inst.is_local)
                {
                    // Apply HP, etc.
                    // Note: Ideally we don't snap X/Y here if we are interpolating, apply() does snap physics.
                    // So we might need to be careful.
                    _state.apply(_inst); 
                    
                    // Re-assert interpolation start to prevent snapping if apply() overwrote it?
                    // actually apply() updates physics.x/y and inst.x/y.
                    // If we want smooth visual interpolation, we should separate visual x/y from logic x/y or just override x/y in Draw/Step.
                    // For now, let's let apply() happen, but if we have interpolation, we used 'interp' vars.
                }
            }
        }
        else
        {
            // --- SPAWN NEW ---
            if (_state.entity_type == "player")
            {
                 // Create remote player
                 _inst = instance_create_depth(_state.physics.x, _state.physics.y, 0, obj_Player);
                 _inst.is_local = false;
                 _inst.uuid = _state.uuid;
                 _inst.interp_target_x = _state.physics.x;
                 _inst.interp_target_y = _state.physics.y;
                 _state.apply(_inst);
            }
            else if (string_pos("creature:", _state.entity_type) == 1)
            {
                 // Create creature
                 // Parse ID: "creature:phantasia:slime"
                 var _id = string_delete(_state.entity_type, 1, 9); 
                 _inst = instance_create_layer(_state.physics.x, _state.physics.y, "Instances", obj_Creature);
                 _inst._id = _id;
                 _inst.uuid = _state.uuid;
                 // Initialize creature data
                 var _data = global.creature_data[$ _id];
                 if (_data != undefined)
                 {
                     _inst.sprite_index = global.sprite_asset[$ _data.get_sprite_idle()].get_sprite();
                     // Add interpolation vars if we want smooth creatures
                 }
                 _state.apply(_inst);
            }
            else if (_state.entity_type == "item_drop")
            {
                 // Create item drop
                 var _item = new Item(_state.extra_id, _state.extra_value);
                 spawn_item_drop(_state.physics.x, _state.physics.y, _item);
                 // spawn_item_drop creates instance, we need to find it and set uuid
                 // BUT spawn_item_drop returns nothing? Wait, I saw it returns instance maybe? 
                 // Checked file: NO, it uses "with(instance_create...)" but doesn't return it explicitly at end?
                 // Wait, looked at file again: it does not return.
                 // FIX: We need to set uuid. Maybe use `instance_nearest`? risky.
                 // Better: just instance_create_layer and init manually here to be safe/clean?
                 // Or modify spawn_item_drop to return id.
                 // For now, let's manually create to ensure UUID set.
                 
                 // Re-implementation of spawn logic for sync:
                 var _data = global.item_data[$ _state.extra_id];
                 if (_data != undefined)
                 {
                      _inst = instance_create_layer(_state.physics.x, _state.physics.y, "Instances", obj_Item_Drop);
                      _inst.uuid = _state.uuid;
                      _inst.item = _item;
                      // Init visual
                      var _size = _data.get_inventory_size();
                      _inst.image_index = _data.get_inventory_index();
                      _state.apply(_inst);
                 }
            }
            else if (_state.entity_type == "projectile")
            {
                 // Create projectile
                 _inst = spawn_projectile(_state.physics.x, _state.physics.y, _state.extra_id, _state.extra_value);
                 if (instance_exists(_inst))
                 {
                     _inst.uuid = _state.uuid;
                     _state.apply(_inst);
                 }
            }
        }
    }
    
    // --- DESPAWN LOGIC ---
    // Destroy any non-player entity not in the list
    // (We treat Players separately via PLAYER_LEAVE for persistence/safety)
    
    with (obj_Creature)
    {
        if (!struct_exists(_received_uuids, uuid)) instance_destroy();
    }
    with (obj_Item_Drop)
    {
        // Don't destroy if we just spawned it locally (maybe wait for server ack?)
        // The server is authority. If server doesn't send it, it doesn't exist.
        // But what about the frame we drop it?
        // To avoid flickering, local prediction could keep it alive, but standard auth says kill it.
        // Let's kill it.
        if (!struct_exists(_received_uuids, uuid)) instance_destroy();
    }
    with (obj_Projectile)
    {
        if (!struct_exists(_received_uuids, uuid)) instance_destroy();
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
        
        // Count all network entities
        // NOTE: Only sync entities relevant to network (have UUID, etc)
        var _count = instance_number(obj_Player) + instance_number(obj_Creature) + instance_number(obj_Item_Drop) + instance_number(obj_Projectile);
        buffer_write(_buffer, buffer_u16, _count);
        
        // Helper to write
        var _write_entity = function(_inst, _buf) {
            var _s = new EntityState();
            _s.capture(_inst);
            _s.to_buffer(_buf);
            delete _s;
        };
        
        with (obj_Player) { _write_entity(self, _buffer); }
        with (obj_Creature) { _write_entity(self, _buffer); }
        with (obj_Item_Drop) { _write_entity(self, _buffer); }
        with (obj_Projectile) { _write_entity(self, _buffer); }
        
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
/// @desc Initialize inventory structure for a connected client (server only)
function _network_init_client_inventory(_client)
{
    _client.inventory = {};
    
    // Use global inventory reference definitions
    var _names = global.inventory_names;
    
    for (var i = 0; i < array_length(_names); ++i)
    {
        var _name = _names[i];
        if (variable_struct_exists(global.inventory_length, _name))
        {
            var _len = global.inventory_length[$ _name];
            _client.inventory[$ _name] = array_create(_len, INVENTORY_EMPTY);
        }
    }
}

/// @desc Send inventory update to a specific client (server only)
function network_send_inventory_update(_socket, _inv_name, _index, _item_id, _amount)
{
    if (global.network_role != NETWORK_ROLE.SERVER) return;
    
    var _buffer = packet_create(PACKET_TYPE.INVENTORY_UPDATE);
    packet_write_inventory_update(_buffer, _inv_name, _index, _item_id, _amount);
    
    network_send_raw(_socket, _buffer, buffer_tell(_buffer));
    buffer_delete(_buffer);
}

/// @desc Handle INVENTORY_UPDATE packet (client only)
function _network_handle_inventory_update(_buffer)
{
    var _data = packet_read_inventory_update(_buffer);
    
    var _inv_name = _data.inv_name;
    var _index = _data.index;
    var _item_id = _data.item_id;
    var _amount = _data.amount;
    
    // Validate existence of inventory
    if (!variable_struct_exists(global.inventory, _inv_name)) return;
    
    var _inventory = global.inventory[$ _inv_name];
    if (_index < 0 || _index >= array_length(_inventory)) return;
    
    if (_item_id == "")
    {
        _inventory[@ _index] = INVENTORY_EMPTY;
    }
    else
    {
        _inventory[@ _index] = new Inventory(_item_id, _amount);
    }
    
    // Refresh GUI
    obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY_BACKPACK | SURFACE_REFRESH_BOOLEAN.INVENTORY_HOTBAR;
}
