/// @desc Relay Network Manager - High-level API for the P2P relay netcode system
/// This manages the relay network, P2P validation, and game packet handling
/// Manages relay session lifecycle, player spawning, and game packet routing

// ============================================================================
// GLOBALS
// ============================================================================

global.relay_manager = undefined;

// ============================================================================
// INITIALIZATION
// ============================================================================

/// @desc Initialize the relay network system
function relay_manager_init()
{
    relay_init();
    validator_init();
    
    global.relay_manager = new RelayNetworkManager();
    
    // Set up callbacks
    global.relay.on_connected = method(global.relay_manager, global.relay_manager._on_connected);
    global.relay.on_disconnected = method(global.relay_manager, global.relay_manager._on_disconnected);
    global.relay.on_peer_joined = method(global.relay_manager, global.relay_manager._on_peer_joined);
    global.relay.on_peer_left = method(global.relay_manager, global.relay_manager._on_peer_left);
    global.relay.on_game_packet = method(global.relay_manager, global.relay_manager._on_game_packet);
    
    PRINT("[RELAY_MGR] Initialized");
}

/// @desc Shutdown the relay network system
function relay_manager_shutdown()
{
    if (global.relay != undefined)
    {
        global.relay.shutdown();
        global.relay = undefined;
    }
    
    global.relay_manager = undefined;
    global.validator = undefined;
    
    PRINT("[RELAY_MGR] Shutdown");
}

// ============================================================================
// RELAY NETWORK MANAGER
// ============================================================================

function RelayNetworkManager() constructor
{
    // State
    is_connected = false;
    is_host = false;
    local_player = noone;
    
    // Persistent data for reconnection
    persistent_data = {}  // uuid -> { inventory, ... }
    
    // Callbacks for game events
    on_session_started = undefined;     // function(room_code)
    on_session_joined = undefined;      // function(welcome_data)
    on_session_ended = undefined;       // function()
    on_player_spawned = undefined;      // function(peer_id, player_instance)
    on_player_left = undefined;         // function(peer_id)
    
    // ========================================================================
    // PUBLIC API
    // ========================================================================
    
    /// @desc Host a new game session
    /// @param {Real} _port Port to listen on
    /// @returns {String} Room code to share, or "" on failure
    static host_session = function(_config = 6510)
    {
        if (!IS_MULTIPLAYER_ENABLED) return "";
        
        var _code = global.relay.host(_config);
        
        if (_code != "")
        {
            is_connected = true;
            is_host = true;
            
            // Set up local player as first peer
            _setup_local_player();
            
            if (on_session_started != undefined)
            {
                on_session_started(_code);
            }
            
            PRINT($"[RELAY_MGR] Hosting session: {_code}");
        }
        
        return _code;
    }
    
    /// @desc Join an existing session
    /// @param {String} _code Room/invite code
    /// @returns {Bool} True if connection initiated
    static join_session = function(_code, _password = "")
    {
        if (!IS_MULTIPLAYER_ENABLED) return false;
        
        var _result = global.relay.join(_code, _password);
        
        if (_result)
        {
            // Connection initiated, wait for WELCOME
            PRINT($"[RELAY_MGR] Joining session: {_code}");
        }
        
        return _result;
    }
    
    /// @desc Leave the current session
    static leave_session = function()
    {
        if (!is_connected) exit;
        
        // Destroy all remote player instances
        var _peer_ids = struct_get_names(global.relay.peers);
        for (var i = 0; i < array_length(_peer_ids); ++i)
        {
            var _peer = global.relay.peers[$ _peer_ids[i]];
            if (_peer != undefined && !_peer.is_local && instance_exists(_peer.player_instance))
            {
                instance_destroy(_peer.player_instance);
            }
        }
        
        global.relay.disconnect();
        
        is_connected = false;
        is_host = false;
        
        if (on_session_ended != undefined)
        {
            on_session_ended();
        }
        
        PRINT("[RELAY_MGR] Left session");
    }
    
    /// @desc Get the current room code
    /// @returns {String}
    static get_room_code = function()
    {
        if (global.relay == undefined) return "";
        return global.relay.room_code;
    }
    
    /// @desc Get formatted room code for display
    /// @returns {String}
    static get_room_code_formatted = function()
    {
        return invite_code_format(get_room_code());
    }
    
    /// @desc Copy room code to clipboard
    static copy_room_code = function()
    {
        return invite_code_copy();
    }
    
    /// @desc Get list of connected player peer IDs
    /// @returns {Array}
    static get_players = function()
    {
        if (global.relay == undefined) return [];
        return struct_get_names(global.relay.peers);
    }
    
    /// @desc Get player count (including self)
    /// @returns {Real}
    static get_player_count = function()
    {
        if (global.relay == undefined) return 0;
        return global.relay.get_peer_count();
    }
    
    /// @desc Check if we're currently in a session
    /// @returns {Bool}
    static is_in_session = function()
    {
        return is_connected && global.relay != undefined && global.relay.role != RELAY_ROLE.NONE;
    }
    
    /// @desc Handle async networking event
    /// @param {Real} _type The async_load[? "type"] value
    static handle_async = function(_type)
    {
        if (global.relay == undefined) exit;
        
        global.relay.handle_async(_type);
    }
    
    /// @desc Update step (call from game loop)
    static update = function()
    {
        if (!is_connected) exit;
        
        if (global.relay != undefined)
        {
            global.relay.update();
        }
        
        // Update validator (timeout checks, periodic movement validation)
        if (global.validator != undefined)
        {
            global.validator.update();
        }
    }
    
    // ========================================================================
    // INTERNAL CALLBACKS
    // ========================================================================
    
    /// @desc Called when client receives WELCOME from host
    static _on_connected = function(_welcome_data)
    {
        is_connected = true;
        is_host = false;
        
        // Apply world data
        global.current_world.seed = _welcome_data.world_seed;
        global.current_world.time = _welcome_data.world_time;
        
        if (_welcome_data.session_config_public != undefined)
        {
            global.relay.session_config_public = _welcome_data.session_config_public;
        }
        
        // Re-seed noise
        open_simplex_noise_seed(_welcome_data.world_seed);
        
        // Clear all world state for regeneration with new seed
        world_cleanup();
        
        // Spawn remote player instances for existing peers
        for (var i = 0; i < array_length(_welcome_data.peers); ++i)
        {
            var _peer_data = _welcome_data.peers[i];
            
            if (_peer_data.peer_id == global.relay.local_peer_id)
            {
                // This is us, update our player
                global.current_player.uuid = _peer_data.uuid;
                _setup_local_player();
            }
            else
            {
                // Remote peer, spawn their player
                _spawn_remote_player(_peer_data.peer_id, _peer_data.uuid, _peer_data.attire);
            }
        }
        
        if (on_session_joined != undefined)
        {
            on_session_joined(_welcome_data);
        }
        
        // Transition to game room if not already there
        if (room != rm_World)
        {
            room_goto(rm_World);
        }
        
        PRINT("[RELAY_MGR] Connected to session");
    }
    
    /// @desc Called when disconnected from session
    static _on_disconnected = function()
    {
        is_connected = false;
        is_host = false;
        
        if (on_session_ended != undefined)
        {
            on_session_ended();
        }
        
        PRINT("[RELAY_MGR] Disconnected from session");
    }
    
    /// @desc Called when a new peer joins (from host or via notification)
    static _on_peer_joined = function(_peer_id, _uuid, _attire)
    {
        _spawn_remote_player(_peer_id, _uuid, _attire);
        
        // If we're host, send world state to new peer
        if (is_host)
        {
            _send_world_state_to_peer(_peer_id);
        }
    }
    
    /// @desc Called when a peer leaves
    static _on_peer_left = function(_peer_id)
    {
        var _peer = global.relay.peers[$ _peer_id];
        
        // Player instance cleanup is handled by RelayNetwork
        
        if (on_player_left != undefined)
        {
            on_player_left(_peer_id);
        }
        
        PRINT($"[RELAY_MGR] Peer left: {_peer_id}");
    }
    
    /// @desc Called when a game packet is received
    static _on_game_packet = function(_from_peer_id, _packet_type, _buffer)
    {
        // Handle relay-specific packet types
        switch (_packet_type)
        {
            case RELAY_PACKET.VALIDATE_REQUEST:
                global.validator.on_validation_request(_from_peer_id, _buffer);
                exit;
                
            case RELAY_PACKET.VALIDATE_VOTE:
                global.validator.on_vote(_from_peer_id, _buffer);
                exit;
                
            case RELAY_PACKET.VALIDATE_RESULT:
                global.validator.on_result(_from_peer_id, _buffer);
                exit;
                
            case RELAY_PACKET.GAME_PACKET:
                // Unwrap game packet
                var _game_data = relay_read_game_packet(_buffer);
                _handle_game_packet(_from_peer_id, _game_data.packet_type, _game_data.payload);
                buffer_delete(_game_data.payload);
                exit;
        }
        
        // For other types, try to handle as game packet
        _handle_game_packet(_from_peer_id, _packet_type, _buffer);
    }
    
    // ========================================================================
    // GAME PACKET HANDLING
    // ========================================================================
    
    /// @desc Handle an unwrapped game packet
    static _handle_game_packet = function(_from_peer_id, _packet_type, _buffer)
    {
        switch (_packet_type)
        {
            case PACKET_TYPE.PLAYER_INPUT:
                _handle_player_input(_from_peer_id, _buffer);
                break;
                
            case PACKET_TYPE.ENTITY_UPDATE:
                _handle_entity_update(_from_peer_id, _buffer);
                break;
                
            case PACKET_TYPE.TILE_UPDATE:
                _handle_tile_update(_buffer);
                break;
                
            case PACKET_TYPE.INVENTORY_UPDATE:
                _handle_inventory_update(_buffer);
                break;
                
            case PACKET_TYPE.CHUNK_REQUEST:
                if (is_host)
                {
                    _handle_chunk_request(_from_peer_id, _buffer);
                }
                break;
                
            case PACKET_TYPE.CHUNK_DATA:
                _handle_chunk_data(_buffer);
                break;
                
            case PACKET_TYPE.TIME_UPDATE:
                _handle_time_update(_buffer);
                break;
                
            case PACKET_TYPE.PLAYER_INFO:
                _handle_player_info(_buffer);
                break;
                
            case PACKET_TYPE.ENTITY_SPAWN:
                _handle_entity_spawn(_buffer);
                break;
                
            case PACKET_TYPE.INVENTORY_ACTION:
                if (is_host) _handle_inventory_action(_from_peer_id, _buffer);
                break;
                
            case PACKET_TYPE.CONTAINER_OPEN:
                if (is_host) _handle_container_open(_from_peer_id, _buffer);
                break;
                
            case PACKET_TYPE.CONTAINER_CLOSE:
                if (is_host) _handle_container_close(_from_peer_id, _buffer);
                break;
                
            case PACKET_TYPE.ENTITY_DESTROY:
                _handle_entity_destroy(_buffer);
                break;
                
            case PACKET_TYPE.ENTITY_MOVE:
                _handle_entity_move(_buffer);
                break;
        }
    }
    
    /// @desc Handle player input packet
    static _handle_player_input = function(_from_peer_id, _buffer)
    {
        var _input = relay_read_input(_buffer);
        var _peer = global.relay.peers[$ _from_peer_id];
        
        if (_peer != undefined && instance_exists(_peer.player_instance))
        {
            _peer.player_instance.network_input = _input;
            _peer.player_instance.selected_hotbar = clamp(_input.selected_hotbar ?? 0, 0, INVENTORY_LENGTH.ROW - 1);
        }
    }
    
    /// @desc Handle entity update packet
    static _handle_entity_update = function(_from_peer_id, _buffer)
    {
        if (room != rm_World) exit;
        
        // NOTE: relay_send_entity_update writes count=1 (u16) before state 
        var _entity_count = buffer_read(_buffer, buffer_u16);
        
        for (var i = 0; i < _entity_count; ++i)
        {
            var _state = new EntityState();
            _state.from_buffer(_buffer);
            
            // Find or spawn entity
            var _inst = _find_entity_by_uuid(_state.uuid);
            
            if (instance_exists(_inst))
            {
                // Update existing entity (interpolation)
                if (variable_instance_exists(_inst, "interp_target_x"))
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
            }
        }
    }
    
    /// @desc Handle tile update packet
    static _handle_tile_update = function(_buffer)
    {
        var _x = buffer_read(_buffer, buffer_s32);
        var _y = buffer_read(_buffer, buffer_s32);
        var _z = buffer_read(_buffer, buffer_s32);
        var _tile_id = buffer_read(_buffer, buffer_string);
        
        // Apply tile update
        var _tile = (_tile_id != "" && _tile_id != "undefined") ? new Tile(_tile_id) : TILE_EMPTY;
        
        global.network_applying_packet = true;
        tile_place(_x, _y, _z, _tile);
        global.network_applying_packet = false;
    }
    
    /// @desc Handle inventory update packet
    static _handle_inventory_update = function(_buffer)
    {
        var _update = relay_read_inventory_update(_buffer);
        
        // Apply to local inventory or specific inventory
        // Assuming global.inventory is the target for now for the local player
        if (variable_global_exists("inventory") && global.inventory != undefined)
        {
            var _arr = global.inventory[$ _update.inv_name];
            if (is_array(_arr) && _update.index < array_length(_arr))
            {
                _arr[@ _update.index] = _update.item;
            }
        }
    }
    
    /// @desc Handle inventory action packet (host only)
    static _handle_inventory_action = function(_from_peer_id, _buffer)
    {
        if (!_peer_can_manage_inventory(_from_peer_id)) exit;
        
        var _data = relay_read_inventory_action(_buffer);
        var _peer = global.relay.peers[$ _from_peer_id];
        if (_peer == undefined) exit;
        
        // Host: Process inventory action on peer's inventory
        // (Simplified: just perform the move/split/etc. on the host's copy of their inventory)
        // In a real scenario, we'd validate this against the host's game state
        
        // For now, let's just use the existing inventory_move/split logic if it's available for generic inventories
        // Actually, since it's just a struct, we can manipulate it here.
        
        var _inv = _peer.inventory;
        if (_inv == undefined) exit;
        
        switch (_data.action)
        {
            case RELAY_INVENTORY_ACTION.MOVE:
                var _item = _inv[$ _data.from_inv][_data.from_idx];
                _inv[$ _data.from_inv][@ _data.from_idx] = INVENTORY_EMPTY;
                _inv[$ _data.to_inv][@ _data.to_idx] = _item;
                break;
                
            case RELAY_INVENTORY_ACTION.SPLIT:
                var _item = _inv[$ _data.from_inv][_data.from_idx];
                if (_item != INVENTORY_EMPTY)
                {
                    var _split_amount = _data.amount;
                    var _new_item = variable_clone(_item).set_amount(_split_amount);
                    _item.add_amount(-_split_amount);
                    
                    _inv[$ _data.to_inv][@ _data.to_idx] = _new_item;
                    
                    if (_item.get_amount() <= 0) _inv[$ _data.from_inv][@ _data.from_idx] = INVENTORY_EMPTY;
                }
                break;
                
            case RELAY_INVENTORY_ACTION.DROP:
                var _item = _inv[$ _data.from_inv][_data.from_idx];
                if (_item != INVENTORY_EMPTY)
                {
                    var _amount = min(_item.get_amount(), _data.amount);
                    var _drop_item = variable_clone(_item).set_amount(_amount);
                    _item.add_amount(-_amount);
                    
                    if (_item.get_amount() <= 0) _inv[$ _data.from_inv][@ _data.from_idx] = INVENTORY_EMPTY;
                    
                    // Note: Host handles actual item drop spawning elsewhere or here
                }
                break;
                
            case RELAY_INVENTORY_ACTION.CRAFT:
                // Handle crafting consumption and output
                // (Simplified for now as the host doesn't track recipe registry fully)
                _inv[$ _data.to_inv][@ _data.to_idx] = new Inventory("mouse", _data.amount); // Placeholder
                break;
        }
        
        // After processing, host should broadcast the update to keep everyone in sync
        // Or at least send it back to the client as confirmation
        relay_send_inventory_update(_from_peer_id, _data.to_inv, _data.to_idx, _inv[$ _data.to_inv][_data.to_idx]);
        relay_send_inventory_update(_from_peer_id, _data.from_inv, _data.from_idx, _inv[$ _data.from_inv][_data.from_idx]);
    }
    
    /// @desc Handle container open packet (host only)
    static _handle_container_open = function(_from_peer_id, _buffer)
    {
        if (!_peer_can_open_containers(_from_peer_id)) exit;
        
        var _x = buffer_read(_buffer, buffer_s32);
        var _y = buffer_read(_buffer, buffer_s32);
        var _z = buffer_read(_buffer, buffer_s32);
        
        var _peer = global.relay.peers[$ _from_peer_id];
        if (_peer == undefined) exit;
        
        _peer.open_container = { x: _x, y: _y, z: _z }
        PRINT($"[RELAY_MGR] Peer {_from_peer_id} opened container at {_x}, {_y}, {_z}");
    }
    
    /// @desc Handle container close packet (host only)
    static _handle_container_close = function(_from_peer_id, _buffer)
    {
        var _peer = global.relay.peers[$ _from_peer_id];
        if (_peer == undefined) exit;
        
        _peer.open_container = undefined;
    }
    
    /// @desc Handle chunk request (host only)
    static _handle_chunk_request = function(_from_peer_id, _buffer)
    {
        var _chunk_x = buffer_read(_buffer, buffer_s32);
        var _chunk_y = buffer_read(_buffer, buffer_s32);
        
        // Get chunk data
        var _chunk = chunk_get(_chunk_x, _chunk_y);
        if (_chunk == undefined) exit;
        
        // Serialize and send
        var _tiles = _chunk.get_sparse_tile_data();
        relay_send_chunk_data(_from_peer_id, _chunk_x, _chunk_y, _tiles);
    }
    
    /// @desc Handle chunk data packet
    static _handle_chunk_data = function(_buffer)
    {
        var _data = relay_read_chunk_data(_buffer);
        var _chunk = chunk_get(_data.chunk_x, _data.chunk_y);
        
        if (_chunk == undefined)
        {
            // Force create chunk if it doesn't exist (client side)
            _chunk = new Chunk(_data.chunk_x, _data.chunk_y);
            chunk_set(_data.chunk_x, _data.chunk_y, _chunk);
        }
        
        // Apply sparse tiles
        for (var i = 0; i < array_length(_data.tiles); ++i)
        {
            var _t = _data.tiles[i];
            var _tile = new Tile(_t.tile_id);
            _chunk.set_tile(_t.local_x, _t.local_y, _t.z, _tile);
        }
        
        // Force chunk rebuild
        _chunk.dirty = true;
    }
    
    /// @desc Handle time update packet
    static _handle_time_update = function(_buffer)
    {
        var _time = relay_read_time_update(_buffer);
        global.current_world.time = _time;
    }
    
    /// @desc Handle player info packet
    static _handle_player_info = function(_buffer)
    {
        var _data = relay_read_player_info(_buffer);
        
        // Update player attire
        var _peer = _find_peer_by_uuid(_data.uuid);
        if (_peer != undefined && instance_exists(_peer.player_instance))
        {
            _peer.player_instance.attire = _data.attire;
        }
    }
    
    /// @desc Handle entity spawn packet
    static _handle_entity_spawn = function(_buffer)
    {
        var _state = relay_read_entity_spawn(_buffer);
        
        // Check if already exists
        if (_find_entity_by_uuid(_state.uuid) != noone) exit;
        
        // Spawn based on type
        var _obj_index = noone;
        var _params = {
            uuid: _state.uuid,
            image_xscale: 1, image_yscale: 1, image_angle: 0
        }
        
        if (_state.entity_type == "player")
        {
            // Handled by _spawn_remote_player, but we might receive a spawn packet for new peers
            // We should rely on PEER_JOINED for players usually, but this acts as a fallback?
            // Actually, for remote player spawn from existing world state, this is useful
            _obj_index = obj_Client;
            _params.is_local = false;
        }
        else if (string_pos("creature:", _state.entity_type) == 1)
        {
            _obj_index = obj_Creature;
            _params._id = string_delete(_state.entity_type, 1, 9); // Remove "creature:"
        }
        else if (_state.entity_type == "item_drop")
        {
            _obj_index = obj_Item_Drop;
            // Initialize item later after create or via params
            _params.item = new Inventory(_state.extra_id, _state.extra_value);
        }
        else if (_state.entity_type == "projectile")
        {
            _obj_index = obj_Projectile;
            _params._id = _state.extra_id;
            _params.damage = _state.extra_value;
        }
        
        if (_obj_index != noone)
        {
            var _inst = instance_create_depth(_state.physics.x, _state.physics.y, 0, _obj_index, _params);
            _state.apply(_inst);
        }
    }
    
    /// @desc Handle entity destroy packet
    static _handle_entity_destroy = function(_buffer)
    {
        var _uuid = relay_read_entity_destroy(_buffer);
        var _inst = _find_entity_by_uuid(_uuid);
        
        if (instance_exists(_inst))
        {
            instance_destroy(_inst);
        }
    }
    
    /// @desc Handle entity move packet
    static _handle_entity_move = function(_buffer)
    {
        var _data = relay_read_entity_move(_buffer);
        
        var _inst = _find_entity_by_uuid(_data.uuid);
        if (instance_exists(_inst))
        {
            _inst.x = _data.x;
            _inst.y = _data.y;
            
            // If interpolating, might need to reset interpolation
            if (variable_instance_exists(_inst, "interp_target_x"))
            {
                _inst.interp_target_x = _data.x;
                _inst.interp_target_y = _data.y;
            }
        }
    }
    
    // ========================================================================
    // HELPER FUNCTIONS
    // ========================================================================
    
    /// @desc Set up local player in peers
    static _setup_local_player = function()
    {
        // Find local player instance
        with (obj_Player)
        {
            if (is_local)
            {
                local_player = id;
                break;
            }
        }
        
        // Update peer entry
        var _peer = global.relay.peers[$ global.relay.local_peer_id];
        if (_peer != undefined)
        {
            _peer.player_instance = local_player;
            _peer.uuid = global.current_player.uuid;
        }
    }
    
    /// @desc Spawn a remote player instance
    static _spawn_remote_player = function(_peer_id, _uuid, _attire)
    {
        // Get spawn location (at local player or origin)
        var _spawn_x = 0;
        var _spawn_y = 0;
        
        with (obj_Player)
        {
            if (is_local)
            {
                _spawn_x = x;
                _spawn_y = y;
                break;
            }
        }
        
        // Create remote player instance
        var _player = instance_create_depth(_spawn_x, _spawn_y, 0, obj_Client, {
            is_local: false,
            uuid: _uuid,
            attire: _attire
        });
        
        // Update peer entry
        var _peer = global.relay.peers[$ _peer_id];
        if (_peer != undefined)
        {
            _peer.player_instance = _player;
            
            // Re-initialize inventory for the remote player
            _peer.inventory = {
                mouse: {
                    item: INVENTORY_EMPTY,
                    type:  "",
                    index: -1
                },
                base:              array_create(INVENTORY_LENGTH.BASE, INVENTORY_EMPTY),
                armor_helmet:      array_create(1, INVENTORY_EMPTY),
                armor_breastplate: array_create(1, INVENTORY_EMPTY),
                armor_leggings:    array_create(1, INVENTORY_EMPTY),
                accessory:         array_create(INVENTORY_LENGTH.ACCESSORY, INVENTORY_EMPTY),
                _container:         []
            }
        }
        
        if (on_player_spawned != undefined)
        {
            on_player_spawned(_peer_id, _player);
        }
        
        PRINT($"[RELAY_MGR] Spawned remote player: {_uuid}");
        
        return _player;
    }
    
    /// @desc Send world state to a newly joined peer
    static _send_world_state_to_peer = function(_peer_id)
    {
        // Send time
        relay_send_time_update(global.current_world.time, _peer_id);
        
        // Send existing entities (Creatures, Items, Projectiles)
        // Note: Players are handled by PEER_JOINED and WELCOME
        
        var _entities_to_sync = [];
        with (obj_Creature) array_push(_entities_to_sync, id);
        with (obj_Item_Drop) array_push(_entities_to_sync, id);
        with (obj_Projectile) array_push(_entities_to_sync, id);
        
        for (var i = 0; i < array_length(_entities_to_sync); ++i)
        {
            relay_send_entity_spawn(_entities_to_sync[i], _peer_id);
        }
    }
    
    /// @desc Find an entity instance by UUID
    static _find_entity_by_uuid = function(_uuid)
    {
        // Players
        with (obj_Player) { if (uuid == _uuid) return id; }
        with (obj_Client) { if (uuid == _uuid) return id; }
        
        // Creatures
        with (obj_Creature) { if (uuid == _uuid) return id; }
        
        // Items
        with (obj_Item_Drop) { if (uuid == _uuid) return id; }
        
        return noone;
    }
    
    /// @desc Find a peer by player UUID
    static _find_peer_by_uuid = function(_uuid)
    {
        var _peer_ids = struct_get_names(global.relay.peers);
        for (var i = 0; i < array_length(_peer_ids); ++i)
        {
            var _peer = global.relay.peers[$ _peer_ids[i]];
            if (_peer.uuid == _uuid) return _peer;
        }
        return undefined;
    }
    
    /// @desc Find a peer by their player instance
    static _find_peer_by_instance = function(_inst)
    {
        var _peer_ids = struct_get_names(global.relay.peers);
        for (var i = 0; i < array_length(_peer_ids); ++i)
        {
            var _peer = global.relay.peers[$ _peer_ids[i]];
            if (_peer.player_instance == _inst) return _peer;
        }
        return undefined;
    }
    
    static _get_peer_permission_level = function(_peer_id)
    {
        if (_peer_id == global.relay.host_peer_id || (_peer_id == global.relay.local_peer_id && is_host))
        {
            return SETTINGS_LEVEL.MAX;
        }
        
        var _peer = global.relay.peers[$ _peer_id];
        if (_peer != undefined && _peer.permission_level != undefined)
        {
            return _peer.permission_level;
        }
        
        return global.relay.session_config_public.default_permission_level ?? SETTINGS_LEVEL.MIN;
    }
    
    static _peer_can_manage_inventory = function(_peer_id)
    {
        return _get_peer_permission_level(_peer_id) >= SETTINGS_LEVEL.MIN;
    }
    
    static _peer_can_open_containers = function(_peer_id)
    {
        if (!(global.relay.session_config_public.allow_containers ?? true))
        {
            return false;
        }
        
        return _get_peer_permission_level(_peer_id) >= SETTINGS_LEVEL.MIN;
    }
}
