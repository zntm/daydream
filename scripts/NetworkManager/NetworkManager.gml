/// @desc Network manager for server/client functionality

// Network state globals
global.network_role = undefined;  // "server", "client", or undefined
global.network_server_socket = undefined;
global.network_client_socket = undefined;
global.network_clients = ds_map_create();           // socket_id -> { uuid, player_instance, ... }
global.network_persistent_data = ds_map_create();  // uuid -> { inventory, player_instance?, ... }
global.network_host_ip = "127.0.0.1";
global.network_port = 6510;
global.network_buffer = buffer_create(4096, buffer_grow, 1);

enum NETWORK_ROLE {
    NONE,
    SERVER,
    CLIENT,
    INTEGRATED  // Singleplayer: server+client in same process, zero-latency loopback
}

/// @desc Initialize network globals
function network_init()
{
    global.network_role = NETWORK_ROLE.NONE;
    global.network_server_socket = undefined;
    global.network_client_socket = undefined;
    global.network_applying_packet = false;
    ds_map_clear(global.network_clients);
    ds_map_clear(global.network_persistent_data);
}

/// @desc Start a server on the specified port
/// @param {Real} _port
/// @returns {Bool} Success
function network_start_server(_port)
{
    if (!IS_MULTIPLAYER_ENABLED) return false;

    if (global.network_role != NETWORK_ROLE.NONE)
    {
        show_debug_message("[NET] Cannot start server: already in a network session");
        return false;
    }
    
    var _socket = network_create_server_raw(network_socket_tcp, _port, 8);
    
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
    if (!IS_MULTIPLAYER_ENABLED) return false;

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
    
    // network_connect_raw is synchronous - blocks until connected or failed
    var _result = network_connect_raw(_socket, _ip, _port);
    
    if (_result < 0)
    {
        show_debug_message($"[NET] Failed to connect to {_ip}:{_port}");
        network_destroy(_socket);
        return false;
    }
    
    global.network_client_socket = _socket;
    global.network_role = NETWORK_ROLE.CLIENT;
    global.network_host_ip = _ip;
    global.network_port = _port;
    
    show_debug_message($"[NET] Connected to {_ip}:{_port}!");
    
    var _buffer = packet_create(PACKET_TYPE.HELLO);
    buffer_write(_buffer, buffer_string, global.player_save_data.uuid);
    
    var _attire = global.player_save_data.attire;
    var _json = (_attire != undefined) ? json_stringify(_attire) : "{}";
    buffer_write(_buffer, buffer_string, _json);
    
    packet_send(global.network_client_socket, _buffer);
    buffer_delete(_buffer);
    
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
    else if (global.network_role == NETWORK_ROLE.INTEGRATED)
    {
        // Destroy the integrated server instance
        if (instance_exists(obj_Server))
        {
            instance_destroy(obj_Server);
        }
        ds_map_clear(global.network_clients);
    }
    
    global.network_role = NETWORK_ROLE.NONE;
    show_debug_message("[NET] Disconnected");
}

/// @desc Start integrated server for singleplayer (zero-latency loopback)
/// @returns {Bool} Success
function network_start_integrated()
{
    if (global.network_role != NETWORK_ROLE.NONE)
    {
        show_debug_message("[NET] Cannot start integrated: already in a network session");
        return false;
    }
    
    global.network_role = NETWORK_ROLE.INTEGRATED;
    
    // Register the local player as a "client" with socket_id = -1 (loopback)
    var _local_uuid = global.player_save_data.uuid;
    ds_map_add(global.network_clients, -1, {
        uuid: _local_uuid,
        player_instance: noone, // Will be set when obj_Player is created
        inventory: {},
        open_container: { x: -1, y: -1, z: -1 },
        last_processed_tick: 0,
        is_local: true
    });
    
    // Create obj_Server if not exists
    if (!instance_exists(obj_Server))
    {
        instance_create_depth(0, 0, 0, obj_Server);
        obj_Server.is_integrated = true;
    }
    
    show_debug_message("[NET] Integrated server started (singleplayer mode)");
    return true;
}

/// @desc Send a packet via loopback (direct function call, zero latency)
/// @param {Id.Buffer} _buffer
function _network_loopback_send(_buffer)
{
    // Read the packet type and dispatch directly to the handler
    var _pos = buffer_tell(_buffer);
    buffer_seek(_buffer, buffer_seek_start, 2); // Skip size header
    
    var _packet_type = buffer_read(_buffer, buffer_u8);
    
    // Dispatch to appropriate handler (as if we received it from network)
    switch (_packet_type)
    {
        case PACKET_TYPE.ENTITY_UPDATE:     _network_handle_entity_update(_buffer); break;
        case PACKET_TYPE.TIME_UPDATE:       _network_handle_time_update(_buffer); break;
        case PACKET_TYPE.TILE_UPDATE:       _network_handle_tile_update(_buffer); break;
        case PACKET_TYPE.INVENTORY_UPDATE:  _network_handle_inventory_update(_buffer); break;
        case PACKET_TYPE.ENTITY_SPAWN:      _network_handle_entity_spawn(_buffer); break;
        case PACKET_TYPE.ENTITY_DESTROY:    _network_handle_entity_destroy(_buffer); break;
        case PACKET_TYPE.ENTITY_MOVE:       _network_handle_entity_move(_buffer); break;
        case PACKET_TYPE.ENTITY_TELEPORT:   _network_handle_entity_teleport(_buffer); break;
        case PACKET_TYPE.ENTITY_METADATA:   _network_handle_entity_metadata(_buffer); break;
        // Server-bound packets (from local client to integrated server)
        case PACKET_TYPE.PLAYER_INPUT:      _network_handle_player_input(-1, _buffer); break;
        case PACKET_TYPE.TILE_UPDATE_REQUEST: _network_handle_tile_request(-1, _buffer); break;
        case PACKET_TYPE.INVENTORY_ACTION:  _network_handle_inventory_action(-1, _buffer); break;
        case PACKET_TYPE.CONTAINER_OPEN:    _network_handle_container_open(-1, _buffer); break;
        case PACKET_TYPE.CONTAINER_CLOSE:   _network_handle_container_close(-1, _buffer); break;
        case PACKET_TYPE.CHUNK_REQUEST:     _network_handle_chunk_request(-1, _buffer); break;
    }
    
    buffer_seek(_buffer, buffer_seek_start, _pos); // Restore position
}

/// @desc Send a buffer to a specific socket
/// @param {Id.Socket} _socket
/// @param {Id.Buffer} _buffer
function network_send_packet(_socket, _buffer)
{
    // Use packet_send to ensure proper size header framing
    packet_send(_socket, _buffer);
}

/// @desc Broadcast a buffer to all connected clients (server only)
/// @param {Id.Buffer} _buffer
function network_broadcast_packet(_buffer, _exclude_socket = undefined)
{
    if (global.network_role != NETWORK_ROLE.SERVER && global.network_role != NETWORK_ROLE.INTEGRATED) return;
    
    var _size = buffer_tell(_buffer);
    var _key = ds_map_find_first(global.network_clients);
    
    while (!is_undefined(_key))
    {
        if (_key != _exclude_socket)
        {
            if (_key == -1)
            {
                // Loopback for integrated client
                _network_loopback_send(_buffer);
            }
            else
            {
                packet_send(_key, _buffer);
            }
        }
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
            
        case network_type_non_blocking_connect:
            var _succeeded = async_load[? "succeeded"];
            
            if (_succeeded)
            {
                _network_handle_connect();
            }
            else
            {
                show_debug_message($"[NET] Connection Failed!");
                // TODO: Show UI error?
                network_destroy(global.network_client_socket);
                global.network_client_socket = undefined;
                global.network_role = NETWORK_ROLE.NONE;
            }
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
    // For non-blocking connect, the socket is already our client socket
    // For server receiving connect, 'socket' is the new client socket
    
    if (global.network_role == NETWORK_ROLE.SERVER)
    {
        var _socket = async_load[? "socket"];
        
        // A client connected to us
        ds_map_add(global.network_clients, _socket, {
            uuid: undefined,
            player_instance: noone,
            inventory: {},
            open_container: { x: -1, y: -1, z: -1 },
            last_processed_tick: 0
        });
        
        show_debug_message($"[NET] Client socket connected: socket={_socket}");
    }
    else if (global.network_role == NETWORK_ROLE.CLIENT)
    {
        // We connected to the server
        // Note: HELLO packet is already sent by network_connect_to_server()
        show_debug_message("[NET] Connected to server!");
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
            network_broadcast_packet(_buffer, _socket);
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
/// @desc Internal: Handle incoming data
function _network_handle_data()
{
    var _socket = async_load[? "id"]; // "id" holds the client socket sending the data
    var _buffer = async_load[? "buffer"];
    var _buffer_size = async_load[? "size"];  // Actual received data size, NOT buffer_get_size()
    
    // Safety check just in case
    if (is_undefined(_socket))
    {
        show_debug_message("[NET] CRITICAL: Socket (id) is undefined in DATA event!");
        return;
    }
    
    // Process stream (handle concatenated packets)
    buffer_seek(_buffer, buffer_seek_start, 0);
    
    while (buffer_tell(_buffer) < _buffer_size)
    {
        // 1. Check Header (Size u16)
        if (buffer_tell(_buffer) + 2 > _buffer_size) break; 
        
        var _msg_size = buffer_read(_buffer, buffer_u16);
        var _packet_start_body = buffer_tell(_buffer);
        
        // 2. Check Payload
        if (_packet_start_body + _msg_size > _buffer_size) 
        {
            // Incomplete packet (fragmentation not supported yet)
            show_debug_message("[NET] Warning: Incomplete packet received.");
            break; 
        }
        
        // 3. Read Type (First byte of payload)
        var _packet_type = buffer_read(_buffer, buffer_u8);
        
        // show_debug_message($"[NET] Received packet type {_packet_type} from socket {_socket}");
        
        switch (_packet_type)
        {
            case PACKET_TYPE.HELLO:             _network_handle_hello(_socket, _buffer); break;
            case PACKET_TYPE.WELCOME:           _network_handle_welcome(_buffer); break;
            case PACKET_TYPE.PLAYER_INPUT:      _network_handle_player_input(_socket, _buffer); break;
            case PACKET_TYPE.ENTITY_UPDATE:     _network_handle_entity_update(_buffer); break;
            case PACKET_TYPE.PLAYER_INFO:       _network_handle_player_info(_buffer); break;
            case PACKET_TYPE.TIME_UPDATE:       _network_handle_time_update(_buffer); break;
            case PACKET_TYPE.PLAYER_LEAVE:      _network_handle_player_leave(_buffer); break;
            case PACKET_TYPE.TILE_UPDATE:       _network_handle_tile_update(_buffer); break;
            case PACKET_TYPE.TILE_UPDATE_REQUEST: _network_handle_tile_request(_socket, _buffer); break;
            case PACKET_TYPE.INVENTORY_UPDATE:  _network_handle_inventory_update(_buffer); break;
            case PACKET_TYPE.INVENTORY_ACTION:  _network_handle_inventory_action(_socket, _buffer); break;
            case PACKET_TYPE.CONTAINER_OPEN:    _network_handle_container_open(_socket, _buffer); break;
            case PACKET_TYPE.CONTAINER_CLOSE:   _network_handle_container_close(_socket, _buffer); break;
            case PACKET_TYPE.CHUNK_REQUEST:     _network_handle_chunk_request(_socket, _buffer); break;
            case PACKET_TYPE.CHUNK_DATA:        _network_handle_chunk_data(_buffer); break;
            
            // New Handlers
            case PACKET_TYPE.ENTITY_SPAWN:      _network_handle_entity_spawn(_buffer); break;
            case PACKET_TYPE.ENTITY_DESTROY:    _network_handle_entity_destroy(_buffer); break;
            case PACKET_TYPE.ENTITY_MOVE:       _network_handle_entity_move(_buffer); break;
            case PACKET_TYPE.ENTITY_TELEPORT:   _network_handle_entity_teleport(_buffer); break;
            case PACKET_TYPE.ENTITY_METADATA:   _network_handle_entity_metadata(_buffer); break;
        }
        
        // 4. Align to next packet
        buffer_seek(_buffer, buffer_seek_start, _packet_start_body + _msg_size);
    }
}

/// @desc Handle HELLO packet (server only)
function _network_handle_hello(_socket, _buffer)
{
    show_debug_message($"[NET] Received HELLO from socket={_socket}");
    
    var _client_uuid = buffer_read(_buffer, buffer_string);
    var _client_attire_json = buffer_read(_buffer, buffer_string);
    var _client_attire = json_parse(_client_attire_json);
    
    // Create client entry if not exists (raw sockets may not trigger connect event)
    if (!ds_map_exists(global.network_clients, _socket))
    {
        show_debug_message($"[NET] Creating client entry for socket={_socket} (raw socket late registration)");
        ds_map_add(global.network_clients, _socket, {
            uuid: undefined,
            player_instance: noone,
            inventory: {},
            open_container: { x: -1, y: -1, z: -1 },
            last_processed_tick: 0
        });
    }
    
    // Check for UUID collision (Host or other Clients)
    // This happens frequently in local testing if multiple instances share save data/UUIDs
    var _uuid_collision = false;
    
    // Debug: Log incoming vs Host
    var _host_uuid = string(global.player_save_data.uuid);
    show_debug_message($"[NET] HELLO Check: Incoming={_client_uuid} vs Host={_host_uuid}");
    
    // 1. Check existing keys in client map
    var _k = ds_map_find_first(global.network_clients);
    while (!is_undefined(_k))
    {
        if (_k != _socket)
        {
            var _c = global.network_clients[? _k];
            // Ensure strict string comparison
            if (string(_c.uuid) == string(_client_uuid)) _uuid_collision = true; 
        }
        _k = ds_map_find_next(global.network_clients, _k);
    }
    
    // 2. Check Host Player (Source of Truth)
    // Always check global data as obj_Player might not be initialized or 'is_local' might be ambiguous
    if (string(_client_uuid) == _host_uuid)
    {
        _uuid_collision = true;
        show_debug_message("[NET] CRITICAL: UUID Collision with Host Global Data!");
    }
    
    // 3. Fallback: Check obj_Player instances
    if (!_uuid_collision)
    {
        with (obj_Player)
        {
            if (is_local && string(uuid) == string(_client_uuid)) _uuid_collision = true;
        }
    }
    
    if (_uuid_collision)
    {
        randomize(); // Ensure random seed is fresh
        show_debug_message($"[NET] UUID Collision detected for {_client_uuid}. Assigning new UUID.");
        _client_uuid = uuid_generate(irandom(0xffff_ffff)); 
        show_debug_message($"[NET] New UUID assigned: {_client_uuid}");
    }
    
    // Update client info with their actual (possibly new) UUID
    var _client = global.network_clients[? _socket];
    _client.uuid = _client_uuid;
    
    if (instance_exists(_client.player_instance))
    {
        _client.player_instance.uuid = _client_uuid;
    }
    
    // Reconnection Logic: Bind to persistent data
    // Use the *possibly new* UUID for persistence lookup
    // Note: If they collided, they WON'T match a persistent session (which is good, new session)
    if (ds_map_exists(global.network_persistent_data, _client_uuid))
    {
        var _pers = global.network_persistent_data[? _client_uuid];
        _client.inventory = _pers.inventory;
        
        show_debug_message($"[NET] Persistent session restored: uuid={_client_uuid}");
    }
    else
    {
        // Initializing server-side inventory for this new client
        _network_init_client_inventory(_client);
        
        // Store in persistent map
        ds_map_add(global.network_persistent_data, _client_uuid, {
            inventory: _client.inventory
        });
        
        show_debug_message($"[NET] New session created: uuid={_client_uuid}");
    }
    
    // Handle player instance (Creation or Re-use)
    var _player = noone;
    with (obj_Player)
    {
        if (uuid == _client_uuid) _player = id;
    }
    
    if (_player == noone)
    {
        var _spawn_x = 0;
        var _spawn_y = 0;
        with (obj_Player) { if (is_local) { _spawn_x = x; _spawn_y = y; break; } }
        
        _player = instance_create_depth(_spawn_x, _spawn_y, 0, obj_Client, {
            is_local: false,
            uuid: _client_uuid
        });
    }
    _player.socket_id = _socket;
    _client.player_instance = _player;
    
    // Update player attire
    _player.attire = _client_attire;
    
    // Notify other clients about player join (with Attire)
    var _join_buffer = packet_create(PACKET_TYPE.PLAYER_INFO);
    packet_write_player_info(_join_buffer, _client_uuid, _client_attire);
    network_broadcast_packet(_join_buffer, _socket); // Don't send back to the joiner
    buffer_delete(_join_buffer);
    
    // Send existing players TO the new client
    with (obj_Player)
    {
        if (uuid != _client_uuid)
        {
            var _p_buffer = packet_create(PACKET_TYPE.PLAYER_INFO);
            show_debug_message($"[NET] Sending existing player info: uuid={uuid}, attire={json_stringify(attire)}");
            packet_write_player_info(_p_buffer, uuid, attire);
            packet_send(_socket, _p_buffer);
            buffer_delete(_p_buffer);
        }
    }
    
    // Send WELCOME packet with assigned UUID, World Seed, and World Time
    show_debug_message($"[NET] Sending WELCOME to socket={_socket}");
    var _welcome_buffer = packet_create(PACKET_TYPE.WELCOME);
    var _terrain_config = undefined;
    var _world_data = global.world_data[$ global.world_save_data.dimension];
    if (_world_data != undefined) 
    {
        _terrain_config = _world_data.get_terrain_shaping_config();
    }
    
    packet_write_welcome(_welcome_buffer, _client_uuid, global.world_save_data.seed, global.world_save_data.time, _terrain_config);
    packet_send(_socket, _welcome_buffer);
    buffer_delete(_welcome_buffer);
    
    // Send initial inventory sync
    var _inv = _client.inventory;
    var _names = struct_get_names(_inv);
    for (var i = 0; i < array_length(_names); ++i)
    {
        var _name = _names[i];
        var _arr = _inv[$ _name];
        if (is_array(_arr))
        {
            for (var j = 0; j < array_length(_arr); ++j)
            {
                network_send_inventory_update(_socket, _name, j, _arr[j]);
            }
        }
    }
}

/// @desc Handle WELCOME packet (client only)
function _network_handle_welcome(_buffer)
{
    var _data = packet_read_welcome(_buffer);
    show_debug_message($"[NET] Received WELCOME. UUID: {_data.uuid}, Seed: {_data.seed}, Time: {_data.time}");

    // Apply Seed
    global.world_save_data.seed = _data.seed;
    global.world_save_data.time = _data.time;
    
    // Apply Terrain Configuration (CRITICAL for worldgen sync)
    if (_data.terrain_config != undefined)
    {
        var _world_data = global.world_data[$ global.world_save_data.dimension];
        if (_world_data != undefined)
        {
            _world_data.set_terrain_shaping(_data.terrain_config);
            show_debug_message("[NET] Applied Terrain Configuration from Server");
            
            // Re-initialize TerrainShaper with new config
            global.terrain_shaper = new TerrainShaper(_world_data);
        }
    }
    
    // CRITICAL: Clear existing chunks so they are regenerated with the new seed
    chunk_map_clear();
    
    // Also clear chunk pool / fading chunks if they exist to prevent visual artifacts
    if (variable_global_exists("chunk_pool"))
    {
        var _pool = global.chunk_pool;
        _pool.fading_chunks = [];
    }
    
    // Force immediate chunk update
    with (obj_Game_Control)
    {
        chunk_in_view_x = -999999; // Force update
        chunk_in_view_y = -999999;
    }
    
    show_debug_message($"[NET] Applied World Seed: {_data.seed}. Resetting chunks.");
    
    // Initialize world_save_data if not exists (connecting from menu)
    if (!variable_global_exists("world_save_data") || global.world_save_data == undefined)
    {
        global.world_save_data = {
            seed: _data.seed,
            dimension: "phantasia:overworld",
            time: _data.time,
            day: 0,
            name: "Multiplayer World"
        };
    }
    else
    {
        // Sync World Seed
        global.world_save_data.seed = _data.seed;
    }
    
    // Store the numeric seed directly
    var _noise_seed = _data.seed;
    global.world_save_data.seed = _noise_seed;
    
    open_simplex_noise_seed(_noise_seed);
    
    // Update local player UUID and global persistence
    global.player_save_data.uuid = _data.uuid;
    
    if (instance_exists(obj_Player))
    {
        with(obj_Player) { if (is_local) uuid = _data.uuid; }
    }
    
    // Re-initialize TerrainShaper with synced world data to ensure consistent generation
    var _world_dim = global.world_save_data.dimension;
    var _world_inst = global.world_data[$ _world_dim];
    if (_world_inst != undefined)
    {
        show_debug_message($"[NET] Re-initializing TerrainShaper for {_world_dim}");
        global.terrain_shaper = new TerrainShaper(_world_inst);
    }
    else
    {
        show_debug_message($"[NET] Warning: World data for {_world_dim} not found during TerrainShaper sync!");
    }
    
    // Start Game
    show_debug_message("[NET] Transitioning to rm_World...");
    room_goto(rm_World);
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
            show_debug_message($"[NET] Applying input to Player {_client.player_instance.uuid} from socket {_socket}: MoveX={_input.move_x}, MoveY={_input.move_y}");
            _client.player_instance.network_input = _input;
            _client.player_instance.selected_hotbar = clamp(_input.selected_hotbar, 0, 9);
        }
        else
        {
            show_debug_message($"[NET] Warning: Client {_socket} has no player instance for input!");
        }
    }
    else
    {
        show_debug_message($"[NET] Warning: Input from unknown client socket {_socket}");
    }
}

/// @desc Handle ENTITY_UPDATE packet (client only)
function _network_handle_entity_update(_buffer)
{
    // Ignore entity updates if we are not in the game room (prevents menu-room spawns)
    if (global.network_role == NETWORK_ROLE.CLIENT && room != rm_World) 
    {
        show_debug_message("[NET] Entity update ignored - not in rm_World");
        exit;
    }
    
    var _last_processed_tick = buffer_read(_buffer, buffer_u32);  // Server's last processed input tick
    var _entity_count = buffer_read(_buffer, buffer_u16);
    
    show_debug_message($"[NET] Received ENTITY_UPDATE: count={_entity_count}, tick={_last_processed_tick}");
    
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
            if (_inst == noone)
            {
                with (obj_Client)
                {
                    if (uuid == _state.uuid) { _inst = id; break; }
                }
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
                            
                            // Apply full input state for reconciliation replay
                            _inst.input_state.move_x = _inp.move_x;
                            _inst.input_state.move_y = _inp.move_y;
                            
                            _inst.input_state.jump_held      = _inp.jump_held;
                            _inst.input_state.jump_pressed   = _inp.jump_pressed;
                            _inst.input_state.attack_held    = _inp.attack_held;
                            _inst.input_state.attack_pressed = _inp.attack_pressed;
                            _inst.input_state.use_held       = _inp.use_held;
                            _inst.input_state.use_pressed    = _inp.use_pressed;
                            
                            // Compatibility/Legacy fields if still used anywhere in physics
                            _inst.input_state.move_left = (_inp.move_x < 0);
                            _inst.input_state.move_right = (_inp.move_x > 0);
                            _inst.input_state.move_up = (_inp.move_y < 0);
                            _inst.input_state.move_down = (_inp.move_y > 0);
                            
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
                    // Preserve position if interpolating to avoid snapping
                    var _prev_x = _inst.x;
                    var _prev_y = _inst.y;
                    
                    _state.apply(_inst); 
                    
                    if (variable_instance_exists(_inst, "interp_start_x"))
                    {
                        // Restore position solely for visual interpolation
                        // apply() sets the 'physics' position which logic might need, 
                        // but for smooth rendering, we usually want to be between start and target.
                        // However, apply() sets inst.x/y.
                        // If we restore x/y, we let the interpolation logic (in Step) move it towards target.
                        _inst.x = _prev_x;
                        _inst.y = _prev_y;
                    }
                }
            }
        }
        else
        {
            // --- SPAWN NEW ---
            if (_state.entity_type == "player")
            {
            // Create remote player
            _inst = instance_create_depth(_state.physics.x, _state.physics.y, 0, obj_Client, {
                is_local: false,
                uuid: _state.uuid
            });
            _inst.interp_target_x = _state.physics.x;
            _inst.interp_target_y = _state.physics.y;
            _state.apply(_inst);
            }
            else if (string_pos("creature:", _state.entity_type) == 1)
            {
                // Create creature using spawn_creature for proper initialization
                // Parse ID: "creature:phantasia:slime"
                var _id = string_delete(_state.entity_type, 1, 9); 
                var _data = global.creature_data[$ _id];
                if (_data != undefined)
                {
                    _inst = spawn_creature(_state.physics.x, _state.physics.y, _id, undefined);
                    _inst.uuid = _state.uuid;
                    _state.apply(_inst);
                }
            }
            else if (_state.entity_type == "item_drop")
            {
                // Create item drop with full initialization
                var _item = new Item(_state.extra_id, _state.extra_value);
                var _data = global.item_data[$ _state.extra_id];
                if (_data != undefined)
                {
                    var _size = _data.get_inventory_size();
                    
                    _inst = instance_create_layer(_state.physics.x, _state.physics.y, "Instances", obj_Item_Drop);
                    
                    // Initialize attribute and physics body (matches spawn_item_drop)
                    _inst.attribute = new Attribute()
                        .set_collision_box(_size, _size)
                        .set_gravity(0.15);
                    
                    _inst.physics_body = new PhysicsBody(_inst.attribute);
                    _inst.physics_body.pos_x = _inst.x;
                    _inst.physics_body.pos_y = _inst.y;
                    _inst.physics_body.scale_x = _size / 8;
                    _inst.physics_body.scale_y = _size / 8;
                    
                    _inst.image_xscale = _inst.physics_body.scale_x;
                    _inst.image_yscale = _inst.physics_body.scale_y;
                    _inst.image_index = _data.get_inventory_index();
                    _inst.image_speed = 0;
                    
                    _inst.uuid = _state.uuid;
                    _inst.item = _item;
                    _inst.inst = noone;
                    _inst.timer_pickup = 0;
                    _inst.timer_life = 60 * 15;
                    
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
        if (variable_instance_exists(id, "uuid") && !struct_exists(_received_uuids, uuid)) instance_destroy();
    }
    with (obj_Item_Drop)
    {
        // Don't destroy if we just spawned it locally (maybe wait for server ack?)
        // The server is authority. If server doesn't send it, it doesn't exist.
        // But what about the frame we drop it?
        // To avoid flickering, local prediction could keep it alive, but standard auth says kill it.
        // Let's kill it.
        if (variable_instance_exists(id, "uuid") && !struct_exists(_received_uuids, uuid)) instance_destroy();
    }
    with (obj_Projectile)
    {
        if (variable_instance_exists(id, "uuid") && !struct_exists(_received_uuids, uuid)) instance_destroy();
    }
}

/// @desc Broadcast entity states to all clients using delta compression (server only)
function network_broadcast_entities()
{
    if (global.network_role != NETWORK_ROLE.SERVER) return;
    
    // --- Step 1: Register new entities ---
    var _register_if_new = function(_inst) {
        if (!variable_instance_exists(_inst, "uuid")) 
            _inst.uuid = uuid_generate(irandom(0xffff_ffff));
        
        var _eid = network_eid_get(_inst);
        if (is_undefined(_eid))
        {
            network_eid_register(_inst);
        }
    };
    
    with (obj_Player) { _register_if_new(self); }
    with (obj_Client) { _register_if_new(self); }
    with (obj_Creature) { _register_if_new(self); }
    with (obj_Item_Drop) { _register_if_new(self); }
    with (obj_Projectile) { _register_if_new(self); }
    
    // --- Step 2: Detect destroyed entities and send DESTROY packets ---
    var _eids_to_remove = [];
    var _eid_key = ds_map_find_first(global.network_eid_to_instance);
    
    while (!is_undefined(_eid_key))
    {
        var _inst = ds_map_find_value(global.network_eid_to_instance, _eid_key);
        if (!instance_exists(_inst))
        {
            // Queue destroy packet
            var _destroy_buf = packet_create(PACKET_TYPE.ENTITY_DESTROY);
            buffer_write(_destroy_buf, buffer_u32, _eid_key);
            network_broadcast_packet(_destroy_buf);
            buffer_delete(_destroy_buf);
            
            array_push(_eids_to_remove, _eid_key);
        }
        _eid_key = ds_map_find_next(global.network_eid_to_instance, _eid_key);
    }
    
    // Cleanup removed EIDs
    for (var i = 0; i < array_length(_eids_to_remove); ++i)
    {
        var _eid = _eids_to_remove[i];
        var _tracker = ds_map_find_value(global.network_entity_trackers, _eid);
        if (_tracker != undefined) delete _tracker;
        
        ds_map_delete(global.network_entity_trackers, _eid);
        ds_map_delete(global.network_eid_to_instance, _eid);
        // Note: instance_to_eid cleanup handled separately since instance is gone
    }
    
    // --- Step 3: Send delta updates for all tracked entities ---
    var _tracker_key = ds_map_find_first(global.network_entity_trackers);
    
    while (!is_undefined(_tracker_key))
    {
        var _tracker = ds_map_find_value(global.network_entity_trackers, _tracker_key);
        
        if (_tracker != undefined)
        {
            var _packets = _tracker.get_update_packets();
            
            for (var i = 0; i < array_length(_packets); ++i)
            {
                network_broadcast_packet(_packets[i]);
                buffer_delete(_packets[i]);
            }
        }
        
        _tracker_key = ds_map_find_next(global.network_entity_trackers, _tracker_key);
    }
    
    // --- Step 4: Send last processed tick for reconciliation (per-client) ---
    var _client_key = ds_map_find_first(global.network_clients);
    
    while (!is_undefined(_client_key))
    {
        var _client = global.network_clients[? _client_key];
        var _last_tick = _client[$ "last_processed_tick"] ?? 0;
        
        // Find the client's player EID and send a targeted reconciliation packet
        if (instance_exists(_client.player_instance))
        {
            var _player_eid = network_eid_get(_client.player_instance);
            if (!is_undefined(_player_eid))
            {
                var _rec_buf = packet_create(PACKET_TYPE.ENTITY_METADATA);
                buffer_write(_rec_buf, buffer_u32, _player_eid);
                buffer_write(_rec_buf, buffer_u8, 1);  // 1 entry
                buffer_write(_rec_buf, buffer_u8, ENTITY_META_KEY.SELECTED_HOTBAR);
                buffer_write(_rec_buf, buffer_u32, _last_tick);  // Piggyback tick in metadata
                buffer_write(_rec_buf, buffer_u8, _client.player_instance.selected_hotbar);
                
                packet_send(_client_key, _rec_buf);
                buffer_delete(_rec_buf);
            }
        }
        
        _client_key = ds_map_find_next(global.network_clients, _client_key);
    }
}


/// @desc Send local player input to server (client only, call each tick)
function network_send_input()
{
    if (global.network_role != NETWORK_ROLE.CLIENT) return;
    if (!instance_exists(obj_Player)) 
    {
        show_debug_message("[NET] network_send_input: No obj_Player exists");
        return;
    }
    
    show_debug_message("[NET] network_send_input: Searching for local player...");
    
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
    
    if (_local_player == noone) 
    {
        show_debug_message("[NET] network_send_input: No local player found!");
        return;
    }
    
    show_debug_message($"[NET] network_send_input: Local player found, ticking: { _local_player.uuid}");
    
    // Increment tick
    _local_player.current_tick++;
    var _tick = _local_player.current_tick;
    
    var _buffer = packet_create(PACKET_TYPE.PLAYER_INPUT);
    
    // Get actual input state from the player instance (already polled this frame if local)
    // We use the fields expected by packet_write_input
    var _input = {
        tick:            _tick,
        move_x:          _local_player.input_state.move_x,
        move_y:          _local_player.input_state.move_y,
        jump_held:       _local_player.input_state.jump_held,
        jump_pressed:    _local_player.input_state.jump_pressed,
        attack_held:     _local_player.input_state.attack_held,
        attack_pressed:  _local_player.input_state.attack_pressed,
        use_held:        _local_player.input_state.use_held,
        use_pressed:     _local_player.input_state.use_pressed,
        selected_hotbar: global.inventory_selected_hotbar
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
    
    show_debug_message($"[NET] Sent Input Tick={_tick}, MoveX={_input.move_x}, MoveY={_input.move_y}");
    
    packet_send(global.network_client_socket, _buffer);
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
    
    packet_send(global.network_client_socket, _buffer);
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
    
    var _tile = TILE_EMPTY;
    if (_tile_id != "base:empty" && _tile_id != "undefined" && _tile_id != "" && _tile_id != undefined)
    {
        _tile = new Tile(_tile_id);
    }
    
    // Safety check BEFORE accessing item_data
    if (_tile != TILE_EMPTY)
    {
        var _data = global.item_data[$ _tile.get_id()];
        if (_data == undefined) 
        {
            _tile = TILE_EMPTY;
        }
    }

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
        var _tile = ((_tile_id != "undefined") ? new Tile(_tile_id) : TILE_EMPTY);

        // Authoritative Verification & Inventory Consumption
        var _valid_action = true;
        
        // Only consume if placing a block (not mining/clearing)
        if (_tile != TILE_EMPTY)
        {
            var _hotbar_idx = _p.selected_hotbar;
            var _inv_item = _client.inventory.base[_hotbar_idx];
            
            if (_inv_item != INVENTORY_EMPTY && _inv_item.get_id() == _tile_id)
            {
                var _changed_slots = [];
                inventory_item_decrement("base", _hotbar_idx, _client.inventory, _changed_slots);
                _network_broadcast_inventory_update(_client, "base", _changed_slots);
            }
            else
            {
                // Verify failed: Player doesn't have the item they are trying to place
                _valid_action = false;
                show_debug_message($"[NET] Invalid placement denied: Client {_client.uuid} tried to place {_tile_id} without item.");
            }
        }
        
        if (_valid_action)
        {
            // Apply change (Server will broadcast via tile_place hook)
            tile_place(_x, _y, _z, _tile);
        }
        else
        {
            // Revert logic (force update back to client)
            var _current_tile = tile_get(_x, _y, _z);
            var _current_id = (_current_tile == TILE_EMPTY) ? "undefined" : _current_tile.get_id();
            
            var _revert_buffer = packet_create(PACKET_TYPE.TILE_UPDATE);
            buffer_write(_revert_buffer, buffer_s32, _x);
            buffer_write(_revert_buffer, buffer_s32, _y);
            buffer_write(_revert_buffer, buffer_s32, _z);
            buffer_write(_revert_buffer, buffer_string, _current_id);
            
            packet_send(_socket, _revert_buffer);
            buffer_delete(_revert_buffer);
        }
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
        
        packet_send(_socket, _revert_buffer);
        buffer_delete(_revert_buffer);
        
        show_debug_message($"[NET] Rejected tile request from client (dist={_dist})");
    }
}
/// @desc Initialize inventory structure for a connected client (server only)
function _network_init_client_inventory(_client)
{
    _client.inventory = {};
    _client.open_container = { x: -1, y: -1, z: -1 };
    
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
function network_send_inventory_update(_socket, _inv_name, _index, _item)
{
    if (global.network_role != NETWORK_ROLE.SERVER) return;
    
    var _buffer = packet_create(PACKET_TYPE.INVENTORY_UPDATE);
    packet_write_inventory_update(_buffer, _inv_name, _index, _item);
    
    packet_send(_socket, _buffer);
    buffer_delete(_buffer);
}

/// @desc Handle INVENTORY_UPDATE packet (client only)
function _network_handle_inventory_update(_buffer)
{
    var _data = packet_read_inventory_update(_buffer);
    
    var _inv_name = _data.inv_name;
    var _index = _data.index;
    var _item = _data.item;
    
    // Validate existence of inventory
    if (!variable_struct_exists(global.inventory, _inv_name)) return;
    
    var _inventory = global.inventory[$ _inv_name];
    if (_index < 0 || _index >= array_length(_inventory)) return;
    
    _inventory[@ _index] = _item;
    
    // Refresh GUI (only if Game Control exists aka inside the game world)
    if (instance_exists(obj_Game_Control))
    {
        obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY_BACKPACK | SURFACE_REFRESH_BOOLEAN.INVENTORY_HOTBAR;
    }
}

/// @desc Handle INVENTORY_ACTION packet (server only)
function _network_handle_inventory_action(_socket, _buffer)
{
    var _action = packet_read_inventory_action(_buffer);
    var _client = global.network_clients[? _socket];
    if (is_undefined(_client)) return;
    
    var _inv_target = _client.inventory;
    
    // Helper to resolve physical inventory from name
    var _resolve_inv = function(_c, _name) {
        if (_name == "_container") {
            var _pos = _c.open_container;
            if (_pos.x != -1) {
                var _tile = tile_get(_pos.x, _pos.y, _pos.z);
                if (_tile != TILE_EMPTY) return _tile.get_inventory();
            }
            return undefined;
        }
        return _c.inventory[$ _name];
    };
    
    switch (_action.type)
    {
        case INVENTORY_ACTION_TYPE.MOVE:
            var _from_inv = _resolve_inv(_client, _action.from_inv);
            var _to_inv = _resolve_inv(_client, _action.to_inv);
            
            if (!is_undefined(_from_inv) && !is_undefined(_to_inv))
            {
                var _item = _from_inv[_action.from_idx];
                _from_inv[@ _action.from_idx] = _to_inv[_action.to_idx];
                _to_inv[@ _action.to_idx] = _item;
                
                // Broadcast updates
                _network_broadcast_inventory_update(_action.from_inv, _action.from_idx, _from_inv[_action.from_idx], _client);
                _network_broadcast_inventory_update(_action.to_inv, _action.to_idx, _to_inv[_action.to_idx], _client);
            }
            break;
            
        case INVENTORY_ACTION_TYPE.SPLIT:
            var _from_inv = _resolve_inv(_client, _action.from_inv);
            var _to_inv = _resolve_inv(_client, _action.to_inv);
            
            if (!is_undefined(_from_inv) && !is_undefined(_to_inv))
            {
                var _item_src = _from_inv[_action.from_idx];
                if (_item_src != INVENTORY_EMPTY && _item_src.get_amount() >= _action.amount)
                {
                    var _item_dst = _to_inv[_action.to_idx];
                    
                    if (_item_dst == INVENTORY_EMPTY)
                    {
                        var _new_item = variable_clone(_item_src).set_amount(_action.amount);
                        _to_inv[@ _action.to_idx] = _new_item;
                        _item_src.add_amount(-_action.amount);
                        if (_item_src.get_amount() <= 0) _from_inv[@ _action.from_idx] = INVENTORY_EMPTY;
                    }
                    else if (_item_dst.get_id() == _item_src.get_id())
                    {
                        var _data = global.item_data[$ _item_dst.get_id()];
                        var _can_add = min(_action.amount, _data.get_inventory_max() - _item_dst.get_amount());
                        
                        if (_can_add > 0)
                        {
                            _item_dst.add_amount(_can_add);
                            _item_src.add_amount(-_can_add);
                            if (_item_src.get_amount() <= 0) _from_inv[@ _action.from_idx] = INVENTORY_EMPTY;
                        }
                    }
                    
                    _network_broadcast_inventory_update(_action.from_inv, _action.from_idx, _from_inv[_action.from_idx], _client);
                    _network_broadcast_inventory_update(_action.to_inv, _action.to_idx, _to_inv[_action.to_idx], _client);
                }
            }
            break;
            
        case INVENTORY_ACTION_TYPE.DROP:
            var _inv = _resolve_inv(_client, _action.from_inv);
            if (!is_undefined(_inv))
            {
                var _item = _inv[_action.from_idx];
                if (_item != INVENTORY_EMPTY)
                {
                    var _amount_to_drop = min(_action.amount, _item.get_amount());
                    var _drop_item = variable_clone(_item).set_amount(_amount_to_drop);
                    
                    var _p = _client.player_instance;
                    if (instance_exists(_p))
                        spawn_item_drop(_p.x, _p.y - 16, _drop_item, sign(_p.image_xscale), _p.image_xscale * 0.2, -0.6, GAME_TICK * 3);
                    
                    _item.add_amount(-_amount_to_drop);
                    if (_item.get_amount() <= 0) _inv[@ _action.from_idx] = INVENTORY_EMPTY;
                    
                    _network_broadcast_inventory_update(_action.from_inv, _action.from_idx, _inv[_action.from_idx], _client);
                }
            }
            break;
            
        case INVENTORY_ACTION_TYPE.CRAFT:
            var _index = _action.from_idx; 
            if (_index >= 0 && _index < array_length(global.crafting_data))
            {
                var _changed_slots = [];
                inventory_craft_clear(_index, _client.inventory, _changed_slots);
                
                var _recipe = global.crafting_data[_index];
                var _result_id = _recipe.get_id();
                var _result_amount = _recipe.get_amount();
                
                // For simplicity, crafting always gives to mouse in the current UI flow
                if (_client.inventory.mouse.item == INVENTORY_EMPTY)
                {
                    _client.inventory.mouse.item = new Inventory(_result_id, _result_amount);
                }
                else if (_client.inventory.mouse.item.get_id() == _result_id)
                {
                    _client.inventory.mouse.item.add_amount(_result_amount);
                }
                
                // Broadcast material consumptions
                for (var i = 0; i < array_length(_changed_slots); ++i)
                {
                    _network_broadcast_inventory_update("base", _changed_slots[i], _client.inventory.base[_changed_slots[i]], _client);
                }
                
                // Broadcast new item in mouse
                _network_broadcast_inventory_update("mouse", 0, _client.inventory.mouse.item, _client);
            }
            break;
    }
}

/// @desc Broadcast inventory update to affected client or all clients (if container)
function _network_broadcast_inventory_update(_inv_name, _index, _item, _triggering_client)
{
    if (_inv_name == "_container")
    {
        // Broadcast to all clients watching this container
        var _pos = _triggering_client.open_container;
        var _sockets = ds_map_keys_to_array(global.network_clients);
        for (var i = 0; i < array_length(_sockets); ++i)
        {
            var _c = global.network_clients[? _sockets[i]];
            if (_c.open_container.x == _pos.x && _c.open_container.y == _pos.y && _c.open_container.z == _pos.z)
            {
                network_send_inventory_update(_sockets[i], "_container", _index, _item);
            }
        }
    }
    else
    {
        // Find the socket for this client and send update
        var _sockets = ds_map_keys_to_array(global.network_clients);
        for (var i = 0; i < array_length(_sockets); ++i)
        {
            if (global.network_clients[? _sockets[i]] == _triggering_client)
            {
                network_send_inventory_update(_sockets[i], _inv_name, _index, _item);
                break;
            }
        }
    }
}

/// @desc Handle CONTAINER_OPEN request (Server) or response (Client)
function _network_handle_container_open(_socket, _buffer)
{
    var _data = packet_read_container_open(_buffer);
    
    if (global.network_role == NETWORK_ROLE.SERVER)
    {
        var _client = global.network_clients[? _socket];
        _client.open_container = { x: _data.x, y: _data.y, z: _data.z };
        
        var _tile = tile_get(_data.x, _data.y, _data.z);
        if (_tile != TILE_EMPTY)
        {
            var _inv = _tile.get_inventory();
            if (!is_undefined(_inv))
            {
                // Send current contents to the client
                var _size = array_length(_inv);
                
                // First send response with size
                var _resp = packet_create(PACKET_TYPE.CONTAINER_OPEN);
                packet_write_container_open(_resp, _data.x, _data.y, _data.z, _size);
                packet_send(_socket, _resp);
                buffer_delete(_resp);
                
                // Then send all slots
                for (var i = 0; i < _size; ++i)
                {
                    network_send_inventory_update(_socket, "_container", i, _inv[i]);
                }
            }
        }
    }
    else
    {
        // Client: Server sent container size
        inventory_resize("_container", _data.size);
        obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY_BACKPACK;
    }
}

/// @desc Handle CONTAINER_CLOSE request
function _network_handle_container_close(_socket, _buffer)
{
    if (global.network_role == NETWORK_ROLE.SERVER)
    {
        var _client = global.network_clients[? _socket];
        _client.open_container = { x: -1, y: -1, z: -1 };
    }
}

/// @desc Send container open request
function network_send_container_open(_x, _y, _z)
{
    if (global.network_role != NETWORK_ROLE.CLIENT) return;
    
    var _buffer = packet_create(PACKET_TYPE.CONTAINER_OPEN);
    packet_write_container_open(_buffer, _x, _y, _z);
    
    packet_send(global.network_client_socket, _buffer);
    buffer_delete(_buffer);
}

/// @desc Send container close notification
function network_send_container_close()
{
    if (global.network_role != NETWORK_ROLE.CLIENT) return;
    
    var _buffer = packet_create(PACKET_TYPE.CONTAINER_CLOSE);
    packet_send(global.network_client_socket, _buffer);
    buffer_delete(_buffer);
}

/// @desc Send inventory action request (client only)
function network_send_inventory_action(_type, _from_inv, _from_idx, _to_inv, _to_idx, _amount)
{
    if (global.network_role != NETWORK_ROLE.CLIENT) return;
    
    var _buffer = packet_create(PACKET_TYPE.INVENTORY_ACTION);
    packet_write_inventory_action(_buffer, _type, _from_inv, _from_idx, _to_inv, _to_idx, _amount);
    
    packet_send(global.network_client_socket, _buffer);
    buffer_delete(_buffer);
}

/// @desc Send chunk data request (client only)
/// @param {Real} _chunk_x Chunk world X (pixel)
/// @param {Real} _chunk_y Chunk world Y (pixel)
function network_send_chunk_request(_chunk_x, _chunk_y)
{
    if (global.network_role != NETWORK_ROLE.CLIENT) return;
    
    var _buffer = packet_create(PACKET_TYPE.CHUNK_REQUEST);
    packet_write_chunk_request(_buffer, _chunk_x, _chunk_y);
    
    packet_send(global.network_client_socket, _buffer);
    buffer_delete(_buffer);
    
    show_debug_message($"[NET] Sent CHUNK_REQUEST for ({_chunk_x}, {_chunk_y})");
}

/// @desc Handle CHUNK_REQUEST packet (server only)
function _network_handle_chunk_request(_socket, _buffer)
{
    if (global.network_role != NETWORK_ROLE.SERVER) return;
    
    var _data = packet_read_chunk_request(_buffer);
    var _chunk_x = _data.chunk_x;
    var _chunk_y = _data.chunk_y;
    
    var _chunk = chunk_map_get(_chunk_x, _chunk_y);
    
    if (_chunk == undefined)
    {
        // Chunk not loaded, send empty response
        var _resp = packet_create(PACKET_TYPE.CHUNK_DATA);
        packet_write_chunk_data(_resp, _chunk_x, _chunk_y, []);
        packet_send(_socket, _resp);
        buffer_delete(_resp);
        return;
    }
    
    // Collect non-empty tiles
    var _tiles = [];
    var _chunk_data = _chunk.chunk;
    
    for (var _z = 0; _z < CHUNK_DEPTH; ++_z)
    {
        for (var _y = 0; _y < CHUNK_SIZE; ++_y)
        {
            for (var _x = 0; _x < CHUNK_SIZE; ++_x)
            {
                var _tile = _chunk_data[tile_index_xyz(_x, _y, _z)];
                
                if (_tile != TILE_EMPTY)
                {
                    array_push(_tiles, {
                        local_x: _x,
                        local_y: _y,
                        z: _z,
                        tile_id: _tile.get_id()
                    });
                }
            }
        }
    }
    
    // Send chunk data
    var _resp = packet_create(PACKET_TYPE.CHUNK_DATA);
    packet_write_chunk_data(_resp, _chunk_x, _chunk_y, _tiles);
    packet_send(_socket, _resp);
    buffer_delete(_resp);
    
    show_debug_message($"[NET] Sent CHUNK_DATA for ({_chunk_x}, {_chunk_y}): {array_length(_tiles)} tiles");
}

/// @desc Handle CHUNK_DATA packet (client only)
function _network_handle_chunk_data(_buffer)
{
    if (global.network_role != NETWORK_ROLE.CLIENT) return;
    
    var _data = packet_read_chunk_data(_buffer);
    var _chunk_x = _data.chunk_x;
    var _chunk_y = _data.chunk_y;
    var _tiles = _data.tiles;
    
    if (array_length(_tiles) == 0)
    {
        show_debug_message($"[NET] Received empty CHUNK_DATA for ({_chunk_x}, {_chunk_y})");
        return; // Nothing to do
    }
    
    // Populate chunk
    // Ensure we have the chunk loaded/created in pool
    if (!chunk_map_exists(_chunk_x, _chunk_y))
    {
        // Usually game control loop requests it, so it should be there.
        // If not, maybe we force create?
        global.chunk_pool.acquire(_chunk_x, _chunk_y);
    }
    
    var _chunk = chunk_map_get(_chunk_x, _chunk_y);
    if (_chunk != undefined)
    {
        // Clear existing data? Or merge? Usually clear for fresh load.
        chunk_clear(_chunk); 
        
        var _chunk_data = _chunk.chunk;
        
        for (var i = 0; i < array_length(_tiles); ++i)
        {
            var _t = _tiles[i];
            var _item = new Item(_t.tile_id, 1); // Basic tile item
            
            // Direct array access for speed
            var _idx = tile_index_xyz(_t.local_x, _t.local_y, _t.z);
            _chunk_data[@ _idx] = _item;
            
            // Update counts/bitmasks
            _chunk.chunk_count[@ _t.z]++;
            _chunk.chunk_display |= (1 << _t.z);
        }
        
        // Mark for refresh
        _chunk.boolean |= CHUNK_BOOLEAN.GENERATED | CHUNK_BOOLEAN.SURFACE_LIGHTING_REFRESH;
        
        // Trigger generic refresh?
        if (instance_exists(obj_Game_Control))
        {
            obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.LIGHTING; 
        }
        
        show_debug_message($"[NET] Applied CHUNK_DATA for ({_chunk_x}, {_chunk_y})");
    }
}

/// @desc Handle ENTITY_SPAWN packet (Client Only)
function _network_handle_entity_spawn(_buffer)
{
    if (global.network_role != NETWORK_ROLE.CLIENT) return;

    var _eid = buffer_read(_buffer, buffer_u32);
    var _type = buffer_read(_buffer, buffer_u8);
    var _uuid = buffer_read(_buffer, buffer_string);
    var _x = buffer_read(_buffer, buffer_s32) / 32.0;
    var _y = buffer_read(_buffer, buffer_s32) / 32.0;
    var _vx = buffer_read(_buffer, buffer_s16) / 8000.0;
    var _vy = buffer_read(_buffer, buffer_s16) / 8000.0;

    // Check if EID already exists (idempotency)
    var _existing_inst = network_instance_get(_eid);
    if (_existing_inst != noone)
    {
        // Already exists, recreate
        instance_destroy(_existing_inst);
        network_eid_free(_eid);
    }

    // Determine object to spawn
    var _inst = noone;
    var _is_local_player_uuid = (global.player_save_data.uuid == _uuid);

    // Filter out our own spawn packet (we already exist)
    if (_is_local_player_uuid)
    {
        with (obj_Player) { if (is_local) { _inst = id; break; } }
        if (_inst != noone)
        {
            network_eid_assign(_inst, _eid);
            _network_read_spawn_extra(_buffer, _type, _inst);
            return;
        }
    }

    switch (_type)
    {
        case ENTITY_NET_TYPE.PLAYER:
            _inst = instance_create_depth(_x, _y, 0, obj_Client, {
                is_local: false,
                uuid: _uuid
            });
            break;
            
        case ENTITY_NET_TYPE.CREATURE:
            var _creature_id = buffer_read(_buffer, buffer_string);
            _inst = spawn_creature(_x, _y, _creature_id, undefined);
            if (instance_exists(_inst)) _inst.uuid = _uuid;
            break;
            
        case ENTITY_NET_TYPE.ITEM_DROP:
            var _item_id = buffer_read(_buffer, buffer_string);
            var _amount = buffer_read(_buffer, buffer_u16);
            if (_item_id != "")
            {
                var _item = new Item(_item_id, _amount);
                _inst = spawn_item_drop(_x, _y, _item, 0, 0, -0.6, GAME_TICK * 3);
                 if (instance_exists(_inst)) _inst.uuid = _uuid;
            }
            break;
            
        case ENTITY_NET_TYPE.PROJECTILE:
            var _proj_id = buffer_read(_buffer, buffer_string);
            var _dmg = buffer_read(_buffer, buffer_f32);
            _inst = spawn_projectile(_x, _y, _proj_id, _dmg);
            if (instance_exists(_inst)) _inst.uuid = _uuid;
            break;
    }

    if (instance_exists(_inst))
    {
        network_eid_assign(_inst, _eid);

        _inst.interp_start_x = _x;
        _inst.interp_start_y = _y;
        _inst.interp_target_x = _x;
        _inst.interp_target_y = _y;
        _inst.interp_timer = 0;
        
        if (_type == ENTITY_NET_TYPE.PLAYER)
        {
            var _attire_json = buffer_read(_buffer, buffer_string);
            try
            {
                _inst.attire = json_parse(_attire_json);
            }
            catch(_e)
            {
            }
        }
    }
    else
    {
        if (_type == ENTITY_NET_TYPE.PLAYER) buffer_read(_buffer, buffer_string);
    }
}

/// @desc Helper to read extra spawn data (for when we skip spawn)
function _network_read_spawn_extra(_buffer, _type, _inst)
{
    switch (_type)
    {
        case ENTITY_NET_TYPE.CREATURE:
            buffer_read(_buffer, buffer_string); 
            break;
        case ENTITY_NET_TYPE.ITEM_DROP:
            buffer_read(_buffer, buffer_string); 
            buffer_read(_buffer, buffer_u16);    
            break;
        case ENTITY_NET_TYPE.PROJECTILE:
            buffer_read(_buffer, buffer_string); 
            buffer_read(_buffer, buffer_f32);    
            break;
        case ENTITY_NET_TYPE.PLAYER:
            var _json = buffer_read(_buffer, buffer_string); 
            if (instance_exists(_inst))
            {
                try
                {
                    _inst.attire = json_parse(_json);
                }
                catch(_e)
                {
                }
            }
            break;
    }
}

/// @desc Handle ENTITY_DESTROY packet
function _network_handle_entity_destroy(_buffer)
{
    var _eid = buffer_read(_buffer, buffer_u32);
    var _inst = network_instance_get(_eid);
    
    if (instance_exists(_inst))
    {
        if (_inst.object_index == obj_Player && _inst.is_local) return;
        instance_destroy(_inst);
    }
    network_eid_free(_eid);
}

/// @desc Handle ENTITY_MOVE packet (Relative)
function _network_handle_entity_move(_buffer)
{
    var _eid = buffer_read(_buffer, buffer_u32);
    var _dx = buffer_read(_buffer, buffer_s16);
    var _dy = buffer_read(_buffer, buffer_s16);
    var _dvx = buffer_read(_buffer, buffer_s16);
    var _dvy = buffer_read(_buffer, buffer_s16);
    
    var _inst = network_instance_get(_eid);
    if (instance_exists(_inst))
    {
        var _real_dx = _dx / 32.0;
        var _real_dy = _dy / 32.0;
        
        _inst.interp_start_x = _inst.x;
        _inst.interp_start_y = _inst.y;
        
        if (!variable_instance_exists(_inst, "interp_target_x")) _inst.interp_target_x = _inst.x;
        if (!variable_instance_exists(_inst, "interp_target_y")) _inst.interp_target_y = _inst.y;
        
        _inst.interp_target_x += _real_dx;
        _inst.interp_target_y += _real_dy;
        _inst.interp_timer = 0;
        
        if (variable_instance_exists(_inst, "physics_body"))
        {
            _inst.physics_body.vel_x += _dvx / 8000.0;
            _inst.physics_body.vel_y += _dvy / 8000.0;
        }
    }
}

/// @desc Handle ENTITY_TELEPORT packet (Absolute)
function _network_handle_entity_teleport(_buffer)
{
    var _eid = buffer_read(_buffer, buffer_u32);
    var _x = buffer_read(_buffer, buffer_s32) / 32.0;
    var _y = buffer_read(_buffer, buffer_s32) / 32.0;
    var _vx = buffer_read(_buffer, buffer_s16) / 8000.0;
    var _vy = buffer_read(_buffer, buffer_s16) / 8000.0;
    
    var _inst = network_instance_get(_eid);
    if (instance_exists(_inst))
    {
        _inst.interp_start_x = _inst.x;
        _inst.interp_start_y = _inst.y;
        _inst.interp_target_x = _x;
        _inst.interp_target_y = _y;
        _inst.interp_timer = 0;
        
        if (variable_instance_exists(_inst, "physics_body"))
        {
            _inst.physics_body.vel_x = _vx;
            _inst.physics_body.vel_y = _vy;
        }
        else if (_inst.object_index == obj_Player && _inst.is_local)
        {
            _inst.x = _x;
            _inst.y = _y;
        }
    }
}

/// @desc Handle ENTITY_METADATA packet
function _network_handle_entity_metadata(_buffer)
{
    var _eid = buffer_read(_buffer, buffer_u32);
    var _count = buffer_read(_buffer, buffer_u8);
    
    var _inst = network_instance_get(_eid);
    
    for (var i = 0; i < _count; ++i)
    {
        var _key = buffer_read(_buffer, buffer_u8);
        
        switch (_key)
        {
            case ENTITY_META_KEY.HP:
                var _hp = buffer_read(_buffer, buffer_f32);
                var _hp_max = buffer_read(_buffer, buffer_f32);
                if (instance_exists(_inst))
                {
                    _inst.hp = _hp;
                    _inst.hp_max = _hp_max;
                }
                break;
                
            case ENTITY_META_KEY.SELECTED_HOTBAR:
                var _last_tick = buffer_read(_buffer, buffer_u32);
                var _hotbar = buffer_read(_buffer, buffer_u8);
                
                if (instance_exists(_inst))
                {
                    _inst.selected_hotbar = _hotbar;
                    
                    if (_inst.object_index == obj_Player && _inst.is_local)
                    {
                        var _len = array_length(_inst.input_history);
                        var _delete_count = 0;
                        
                        for (var j = 0; j < _len; ++j)
                        {
                            if (_inst.input_history[j].tick > _last_tick) break;
                            
                            ++_delete_count;
                        }
                        
                        if (_delete_count > 0)
                        {
                            array_delete(_inst.input_history, 0, _delete_count);
                        }
                    }
                }
                break;
        }
    }
}


/// @desc Handle TIME_UPDATE (client)
function _network_handle_time_update(_buffer)
{
    var _time = packet_read_time_update(_buffer);
    global.world_save_data.time = _time;
}

/// @desc Handle PLAYER_INFO (client)
function _network_handle_player_info(_buffer)
{
    var _data = packet_read_player_info(_buffer);
    var _uuid = _data.uuid;
    var _attire = _data.attire;
    
    // Find or Create Player
    var _player = noone;
    with (obj_Player)
    {
        if (uuid == _uuid) _player = id;
    }
    
    if (_player == noone)
    {
        with (obj_Client)
        {
            if (uuid == _uuid) _player = id;
        }
    }
    
    if (_player == noone)
    {
        // Create new remote player using struct to set identity BEFORE Create event
        _player = instance_create_depth(0, 0, 0, obj_Client, {
            is_local: false,
            uuid: _uuid
        });
    }
    
    _player.attire = _attire; // Apply synced attire
    
    show_debug_message($"[NET] Synced player info for uuid={_uuid}. Attire: {json_stringify(_attire)}");
}
