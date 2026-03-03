/// @desc Core relay network system
/// Provides a unified interface for host and client roles
/// Host acts as the relay server, forwarding messages between peers

global.relay = undefined;
global.network_role = RELAY_ROLE.NONE;
global.network_applying_packet = false;

/// @desc Initialize the relay network system
function relay_init()
{
    if (global.relay != undefined)
    {
        global.relay.shutdown();
    }
    global.relay = new RelayNetwork();
}

/// @desc The main relay network controller
function RelayNetwork() constructor
{
    role = RELAY_ROLE.NONE;
    global.network_role = role;
    local_peer_id = "";
    room_code = "";
    
    // Peer tracking: peer_id -> { socket, uuid, player_instance, attire }
    peers = {}
    
    // Socket state
    _server_socket = undefined;     // Host's listening socket
    _host_socket = undefined;       // Client's connection to host
    _socket_to_peer = ds_map_create();  // socket_id -> peer_id (host only)
    
    // Network buffer for packet assembly
    _recv_buffer = buffer_create(8192, buffer_grow, 1);
    
    // Callbacks (set by RelayNetworkManager)
    on_peer_joined = undefined;     // function(peer_id, uuid, attire)
    on_peer_left = undefined;       // function(peer_id)
    on_game_packet = undefined;     // function(from_peer_id, packet_type, buffer)
    on_connected = undefined;       // function(welcome_data)
    on_disconnected = undefined;    // function()
    
    // ========================================================================
    // PUBLIC API
    // ========================================================================
    
    /// @desc Host a new game session
    /// @param {Real} _port Port to listen on (default: 6510)
    /// @returns {String} Room code to share, or "" on failure
    static host = function(_port = 6510)
    {
        if (role != RELAY_ROLE.NONE)
        {
            PRINT("[RELAY] Cannot host: already in a session");
            return "";
        }
        
        _server_socket = network_create_server_raw(network_socket_tcp, _port, 8);
        
        if (_server_socket < 0)
        {
            PRINT($"[RELAY] Failed to create server on port {_port}");
            return "";
        }
        
        role = RELAY_ROLE.HOST;
        global.network_role = role;
        local_peer_id = uuid_generate(irandom(0xffffffff));
        
        // Generate room code from local IP
        var _local_ip = _get_local_ip();
        room_code = invite_code_generate(_local_ip, _port);
        
        // Add self as first peer
        peers[$ local_peer_id] = {
            socket: undefined,  // Host has no socket to self
            uuid: global.current_player.uuid,
            player_instance: noone,
            attire: global.current_player.attire ?? {},
            inventory: global.inventory,
            is_local: true
        }
        
        PRINT($"[RELAY] Hosting on port {_port}");
        PRINT($"[RELAY] Room code: {room_code}");
        PRINT($"[RELAY] Formatted: {invite_code_format(room_code)}");
        
        return room_code;
    }
    
    /// @desc Join an existing game session
    /// @param {String} _code Room/invite code
    /// @returns {Bool} True if connection initiated
    static join = function(_code)
    {
        if (role != RELAY_ROLE.NONE)
        {
            PRINT("[RELAY] Cannot join: already in a session");
            return false;
        }
        
        // Parse invite code
        var _clean_code = invite_code_parse(_code);
        var _decoded = invite_code_decode(_clean_code);
        
        if (_decoded == undefined)
        {
            PRINT($"[RELAY] Invalid invite code: {_code}");
            return false;
        }
        
        // Create socket and connect
        var _socket = network_create_socket(network_socket_tcp);
        
        if (_socket < 0)
        {
            PRINT("[RELAY] Failed to create client socket");
            return false;
        }
        
        var _result = network_connect_raw(_socket, _decoded.ip, _decoded.port);
        
        if (_result < 0)
        {
            PRINT($"[RELAY] Failed to connect to {_decoded.ip}:{_decoded.port}");
            network_destroy(_socket);
            return false;
        }
        
        role = RELAY_ROLE.CLIENT;
        global.network_role = role;
        local_peer_id = uuid_generate(irandom(0xffffffff));
        room_code = _clean_code;
        _host_socket = _socket;
        
        // Send HELLO to host
        var _buf = relay_packet_create(RELAY_PACKET.HELLO);
        relay_write_hello(_buf, local_peer_id, 
            global.current_player.uuid, 
            global.current_player.attire ?? {});
        relay_packet_send(_host_socket, _buf);
        buffer_delete(_buf);
        
        PRINT($"[RELAY] Connecting to {_decoded.ip}:{_decoded.port}...");
        
        return true;
    }
    
    /// @desc Send a packet to a specific peer
    /// @param {String} _peer_id Target peer
    /// @param {Id.Buffer} _buffer Packet to send
    static send_to_peer = function(_peer_id, _buffer)
    {
        if (_peer_id == local_peer_id)
        {
            // Don't send to self
            exit;
        }
        
        if (role == RELAY_ROLE.HOST)
        {
            // Host sends directly
            var _peer = peers[$ _peer_id];
            if (_peer != undefined && _peer.socket != undefined)
            {
                relay_packet_send(_peer.socket, _buffer);
            }
        }
        else if (role == RELAY_ROLE.CLIENT)
        {
            // Client wraps in ROUTE packet for host to forward
            var _route_buf = relay_packet_create(RELAY_PACKET.ROUTE);
            buffer_write(_route_buf, buffer_string, _peer_id);
            
            var _payload_size = buffer_tell(_buffer);
            buffer_write(_route_buf, buffer_u16, _payload_size);
            relay_buffer_copy(_route_buf, _buffer);
            
            relay_packet_send(_host_socket, _route_buf);
            buffer_delete(_route_buf);
        }
    }
    
    /// @desc Broadcast a packet to all peers (excluding self and optionally one peer)
    /// @param {Id.Buffer} _buffer Packet to send
    /// @param {String} _exclude_peer_id Optional peer to exclude
    static broadcast = function(_buffer, _exclude_peer_id = "")
    {
        if (role == RELAY_ROLE.HOST)
        {
            // Host sends directly to each peer
            var _peer_ids = struct_get_names(peers);
            for (var i = 0; i < array_length(_peer_ids); ++i)
            {
                var _pid = _peer_ids[i];
                if (_pid != local_peer_id && _pid != _exclude_peer_id)
                {
                    var _peer = peers[$ _pid];
                    if (_peer != undefined && _peer.socket != undefined)
                    {
                        relay_packet_send(_peer.socket, _buffer);
                    }
                }
            }
        }
        else if (role == RELAY_ROLE.CLIENT)
        {
            // Client wraps in BROADCAST packet for host to forward
            var _bcast_buf = relay_packet_create(RELAY_PACKET.BROADCAST);
            
            var _payload_size = buffer_tell(_buffer);
            buffer_write(_bcast_buf, buffer_u16, _payload_size);
            relay_buffer_copy(_bcast_buf, _buffer);
            
            relay_packet_send(_host_socket, _bcast_buf);
            buffer_delete(_bcast_buf);
        }
    }
    
    /// @desc Get list of all peer IDs (excluding self)
    /// @returns {Array}
    static get_peer_ids = function()
    {
        var _result = [];
        var _all = struct_get_names(peers);
        
        for (var i = 0; i < array_length(_all); ++i)
        {
            if (_all[i] != local_peer_id)
            {
                array_push(_result, _all[i]);
            }
        }
        
        return _result;
    }
    
    /// @desc Get peer count (including self)
    /// @returns {Real}
    static get_peer_count = function()
    {
        return array_length(struct_get_names(peers));
    }
    
    /// @desc Disconnect and cleanup
    static disconnect = function()
    {
        if (role == RELAY_ROLE.HOST)
        {
            // Notify all clients that session is ending
            var _end_buf = relay_packet_create(RELAY_PACKET.SESSION_END);
            broadcast(_end_buf);
            buffer_delete(_end_buf);
            
            // Close all client connections
            var _peer_ids = struct_get_names(peers);
            for (var i = 0; i < array_length(_peer_ids); ++i)
            {
                var _peer = peers[$ _peer_ids[i]];
                if (_peer.socket != undefined)
                {
                    network_destroy(_peer.socket);
                }
            }
            
            // Close server socket
            if (_server_socket != undefined)
            {
                network_destroy(_server_socket);
                _server_socket = undefined;
            }
        }
        else if (role == RELAY_ROLE.CLIENT)
        {
            if (_host_socket != undefined)
            {
                network_destroy(_host_socket);
                _host_socket = undefined;
            }
        }
        
        // Clear state
        role = RELAY_ROLE.NONE;
        global.network_role = role;
        peers = {}
        ds_map_clear(_socket_to_peer);
        local_peer_id = "";
        room_code = "";
        
        if (on_disconnected != undefined)
        {
            on_disconnected();
        }
        
        PRINT("[RELAY] Disconnected");
    }
    
    /// @desc Full shutdown and cleanup
    static shutdown = function()
    {
        disconnect();
        
        ds_map_destroy(_socket_to_peer);
        buffer_delete(_recv_buffer);
    }
    
    // ========================================================================
    // ASYNC NETWORKING HANDLERS
    // ========================================================================
    
    /// @desc Handle async networking event (call from Async - Networking event)
    /// @param {Real} _type_event The async_load[? "type"] value
    static handle_async = function(_type_event)
    {
        switch (_type_event)
        {
            case network_type_connect:
                _on_connect();
                break;
                
            case network_type_disconnect:
                _on_disconnect();
                break;
                
            case network_type_data:
                _on_data();
                break;
        }
    }
    
    /// @desc Handle new connection
    static _on_connect = function()
    {
        if (role == RELAY_ROLE.HOST)
        {
            // A client is connecting
            var _socket = async_load[? "socket"];
            PRINT($"[RELAY] Client socket connected: {_socket}");
            
            // We'll register the peer when we receive their HELLO
            // For now, just track the socket
        }
    }
    
    /// @desc Handle disconnection
    static _on_disconnect = function()
    {
        var _socket = async_load[? "socket"];
        
        if (role == RELAY_ROLE.HOST)
        {
            // A client disconnected
            var _peer_id = _socket_to_peer[? _socket];
            
            if (_peer_id != undefined)
            {
                var _peer = peers[$ _peer_id];
                
                PRINT($"[RELAY] Peer disconnected: {_peer_id}");
                
                // Notify other peers
                var _leave_buf = relay_packet_create(RELAY_PACKET.PEER_LEFT);
                relay_write_peer_left(_leave_buf, _peer_id);
                broadcast(_leave_buf, _peer_id);
                buffer_delete(_leave_buf);
                
                // Cleanup
                struct_remove(peers, _peer_id);
                ds_map_delete(_socket_to_peer, _socket);
                
                // Destroy player instance if exists
                if (_peer != undefined && instance_exists(_peer.player_instance))
                {
                    instance_destroy(_peer.player_instance);
                }
                
                // Callback
                if (on_peer_left != undefined)
                {
                    on_peer_left(_peer_id);
                }
            }
        }
        else if (role == RELAY_ROLE.CLIENT)
        {
            // We got disconnected from host
            PRINT("[RELAY] Disconnected from host (session ended)");
            
            // Clean up all peers
            var _peer_ids = struct_get_names(peers);
            for (var i = 0; i < array_length(_peer_ids); ++i)
            {
                var _peer = peers[$ _peer_ids[i]];
                if (_peer != undefined && instance_exists(_peer.player_instance) && !_peer.is_local)
                {
                    instance_destroy(_peer.player_instance);
                }
            }
            
            role = RELAY_ROLE.NONE;
            global.network_role = role;
            peers = {}
            _host_socket = undefined;
            
            if (on_disconnected != undefined)
            {
                on_disconnected();
            }
        }
    }
    
    /// @desc Handle incoming data
    static _on_data = function()
    {
        var _socket = async_load[? "id"];
        var _buffer = async_load[? "buffer"];
        var _size = async_load[? "size"];
        
        buffer_seek(_buffer, buffer_seek_start, 0);
        
        // Process all complete packets in the buffer
        while (buffer_tell(_buffer) < _size)
        {
            // Check if we have size header
            if (buffer_tell(_buffer) + 2 > _size) break;
            
            var _msg_size = buffer_read(_buffer, buffer_u16);
            var _packet_start = buffer_tell(_buffer);
            
            // Check if we have full packet
            if (_packet_start + _msg_size > _size) break;
            
            // Read packet type
            var _packet_type = buffer_read(_buffer, buffer_u8);
            
            // Route to handler
            if (role == RELAY_ROLE.HOST)
            {
                _handle_host_packet(_socket, _packet_type, _buffer, _msg_size - 1);
            }
            else if (role == RELAY_ROLE.CLIENT)
            {
                _handle_client_packet(_packet_type, _buffer, _msg_size - 1);
            }
            
            // Align to next packet
            buffer_seek(_buffer, buffer_seek_start, _packet_start + _msg_size);
        }
    }
    
    // ========================================================================
    // HOST PACKET HANDLERS
    // ========================================================================
    
    /// @desc Handle packet received by host
    static _handle_host_packet = function(_socket, _type, _buffer, _payload_size)
    {
        switch (_type)
        {
            case RELAY_PACKET.HELLO:
                _host_handle_hello(_socket, _buffer);
                break;
                
            case RELAY_PACKET.ROUTE:
                _host_handle_route(_socket, _buffer);
                break;
                
            case RELAY_PACKET.BROADCAST:
                _host_handle_broadcast(_socket, _buffer);
                break;
                
            case RELAY_PACKET.GAME_PACKET:
            case RELAY_PACKET.VALIDATE_REQUEST:
            case RELAY_PACKET.VALIDATE_VOTE:
            case RELAY_PACKET.VALIDATE_RESULT:
                // Forward to local game logic
                var _from_peer_id = _socket_to_peer[? _socket];
                if (_from_peer_id != undefined && on_game_packet != undefined)
                {
                    on_game_packet(_from_peer_id, _type, _buffer);
                }
                break;
        }
    }
    
    /// @desc Host handles HELLO from new client
    static _host_handle_hello = function(_socket, _buffer)
    {
        var _data = relay_read_hello(_buffer);
        
        PRINT($"[RELAY] HELLO from {_data.peer_id} (uuid: {_data.uuid})");
        
        // Check for UUID collision
        var _uuid = _data.uuid;
        var _collision = false;
        
        // Check against host
        if (_uuid == global.current_player.uuid) _collision = true;
        
        // Check against other peers
        if (!_collision)
        {
            var _peer_ids = struct_get_names(peers);
            for (var i = 0; i < array_length(_peer_ids); ++i)
            {
                if (peers[$ _peer_ids[i]].uuid == _uuid)
                {
                    _collision = true;
                    break;
                }
            }
        }
        
        // Generate new UUID if collision
        if (_collision)
        {
            _uuid = uuid_generate(irandom(0xffffffff));
            PRINT($"[RELAY] UUID collision, assigned new: {_uuid}");
        }
        
        // Register peer
        var _peer_id = _data.peer_id;
        peers[$ _peer_id] = {
            socket: _socket,
            uuid: _uuid,
            player_instance: noone,
            attire: _data.attire,
            inventory: undefined, // Set by RelayNetworkManager on join
            is_local: false
        }
        ds_map_add(_socket_to_peer, _socket, _peer_id);
        
        // Build peer list for WELCOME
        var _peer_list = [];
        var _all_peer_ids = struct_get_names(peers);
        for (var i = 0; i < array_length(_all_peer_ids); ++i)
        {
            var _pid = _all_peer_ids[i];
            var _p = peers[$ _pid];
            array_push(_peer_list, {
                peer_id: _pid,
                uuid: _p.uuid,
                attire: _p.attire
            });
        }
        
        // Send WELCOME to new peer
        var _welcome_buf = relay_packet_create(RELAY_PACKET.WELCOME);
        relay_write_welcome(_welcome_buf, _peer_id, _peer_list, 
            global.current_world.seed, 
            global.current_world.time);
        relay_packet_send(_socket, _welcome_buf);
        buffer_delete(_welcome_buf);
        
        // Notify other peers about new peer
        var _join_buf = relay_packet_create(RELAY_PACKET.PEER_JOINED);
        relay_write_peer_joined(_join_buf, _peer_id, _uuid, _data.attire);
        broadcast(_join_buf, _peer_id);
        buffer_delete(_join_buf);
        
        // Callback
        if (on_peer_joined != undefined)
        {
            on_peer_joined(_peer_id, _uuid, _data.attire);
        }
    }
    
    /// @desc Host handles ROUTE request (forward to specific peer)
    static _host_handle_route = function(_socket, _buffer)
    {
        var _target_peer_id = buffer_read(_buffer, buffer_string);
        var _payload_size = buffer_read(_buffer, buffer_u16);
        
        var _from_peer_id = _socket_to_peer[? _socket];
        if (_from_peer_id == undefined) exit;
        
        // Check if target is the host
        if (_target_peer_id == local_peer_id)
        {
            // Deliver locally
            var _inner_type = buffer_read(_buffer, buffer_u8);
            if (on_game_packet != undefined)
            {
                on_game_packet(_from_peer_id, _inner_type, _buffer);
            }
        }
        else
        {
            // Forward to target peer
            var _target_peer = peers[$ _target_peer_id];
            if (_target_peer != undefined && _target_peer.socket != undefined)
            {
                // Wrap in ROUTED packet
                var _routed_buf = relay_packet_create(RELAY_PACKET.ROUTED);
                buffer_write(_routed_buf, buffer_string, _from_peer_id);
                buffer_write(_routed_buf, buffer_u16, _payload_size);
                
                // Copy payload
                for (var i = 0; i < _payload_size; ++i)
                {
                    buffer_write(_routed_buf, buffer_u8, buffer_read(_buffer, buffer_u8));
                }
                
                relay_packet_send(_target_peer.socket, _routed_buf);
                buffer_delete(_routed_buf);
            }
        }
    }
    
    /// @desc Host handles BROADCAST request (forward to all peers)
    static _host_handle_broadcast = function(_socket, _buffer)
    {
        var _payload_size = buffer_read(_buffer, buffer_u16);
        var _from_peer_id = _socket_to_peer[? _socket];
        if (_from_peer_id == undefined) exit;
        
        // Save payload start position
        var _payload_start = buffer_tell(_buffer);
        
        // Forward to all other peers
        var _peer_ids = struct_get_names(peers);
        for (var i = 0; i < array_length(_peer_ids); ++i)
        {
            var _pid = _peer_ids[i];
            
            // Skip sender
            if (_pid == _from_peer_id) continue;
            
            // Skip self (host) - will handle locally after
            if (_pid == local_peer_id) continue;
            
            var _peer = peers[$ _pid];
            if (_peer.socket == undefined) continue;
            
            // Wrap in ROUTED packet
            var _routed_buf = relay_packet_create(RELAY_PACKET.ROUTED);
            buffer_write(_routed_buf, buffer_string, _from_peer_id);
            buffer_write(_routed_buf, buffer_u16, _payload_size);
            
            // Copy payload
            buffer_seek(_buffer, buffer_seek_start, _payload_start);
            for (var j = 0; j < _payload_size; ++j)
            {
                buffer_write(_routed_buf, buffer_u8, buffer_read(_buffer, buffer_u8));
            }
            
            relay_packet_send(_peer.socket, _routed_buf);
            buffer_delete(_routed_buf);
        }
        
        // Handle locally (for host)
        buffer_seek(_buffer, buffer_seek_start, _payload_start);
        var _inner_type = buffer_read(_buffer, buffer_u8);
        if (on_game_packet != undefined)
        {
            on_game_packet(_from_peer_id, _inner_type, _buffer);
        }
    }
    
    // ========================================================================
    // CLIENT PACKET HANDLERS
    // ========================================================================
    
    /// @desc Handle packet received by client
    static _handle_client_packet = function(_type, _buffer, _payload_size)
    {
        switch (_type)
        {
            case RELAY_PACKET.WELCOME:
                _client_handle_welcome(_buffer);
                break;
                
            case RELAY_PACKET.PEER_JOINED:
                _client_handle_peer_joined(_buffer);
                break;
                
            case RELAY_PACKET.PEER_LEFT:
                _client_handle_peer_left(_buffer);
                break;
                
            case RELAY_PACKET.ROUTED:
                _client_handle_routed(_buffer);
                break;
                
            case RELAY_PACKET.SESSION_END:
                PRINT("[RELAY] Host ended the session");
                disconnect();
                break;
                
            case RELAY_PACKET.GAME_PACKET:
            case RELAY_PACKET.VALIDATE_REQUEST:
            case RELAY_PACKET.VALIDATE_VOTE:
            case RELAY_PACKET.VALIDATE_RESULT:
                // Direct from host
                if (on_game_packet != undefined)
                {
                    // Find host peer_id
                    var _host_peer_id = "";
                    var _pids = struct_get_names(peers);
                    for (var i = 0; i < array_length(_pids); ++i)
                    {
                        if (_pids[i] != local_peer_id)
                        {
                            _host_peer_id = _pids[i];
                            break;
                        }
                    }
                    on_game_packet(_host_peer_id, _type, _buffer);
                }
                break;
        }
    }
    
    /// @desc Client handles WELCOME from host
    static _client_handle_welcome = function(_buffer)
    {
        var _data = relay_read_welcome(_buffer);
        
        PRINT($"[RELAY] WELCOME received, peer_id: {_data.peer_id}");
        PRINT($"[RELAY] World seed: {_data.world_seed}, time: {_data.world_time}");
        PRINT($"[RELAY] {array_length(_data.peers)} peers in session");
        
        // Update our peer_id if host assigned a different one
        local_peer_id = _data.peer_id;
        
        // Register all peers
        for (var i = 0; i < array_length(_data.peers); ++i)
        {
            var _p = _data.peers[i];
            peers[$ _p.peer_id] = {
                socket: undefined,  // Clients don't have direct sockets
                uuid: _p.uuid,
                player_instance: noone,
                attire: _p.attire,
                is_local: (_p.peer_id == local_peer_id)
            }
        }
        
        // Callback with world data
        if (on_connected != undefined)
        {
            on_connected({
                peer_id: _data.peer_id,
                world_seed: _data.world_seed,
                world_time: _data.world_time,
                peers: _data.peers
            });
        }
    }
    
    /// @desc Client handles PEER_JOINED notification
    static _client_handle_peer_joined = function(_buffer)
    {
        var _data = relay_read_peer_joined(_buffer);
        
        PRINT($"[RELAY] Peer joined: {_data.peer_id} (uuid: {_data.uuid})");
        
        peers[$ _data.peer_id] = {
            socket: undefined,
            uuid: _data.uuid,
            player_instance: noone,
            attire: _data.attire,
            is_local: false
        }
        
        if (on_peer_joined != undefined)
        {
            on_peer_joined(_data.peer_id, _data.uuid, _data.attire);
        }
    }
    
    /// @desc Client handles PEER_LEFT notification
    static _client_handle_peer_left = function(_buffer)
    {
        var _peer_id = relay_read_peer_left(_buffer);
        
        PRINT($"[RELAY] Peer left: {_peer_id}");
        
        var _peer = peers[$ _peer_id];
        if (_peer != undefined && instance_exists(_peer.player_instance))
        {
            instance_destroy(_peer.player_instance);
        }
        
        struct_remove(peers, _peer_id);
        
        if (on_peer_left != undefined)
        {
            on_peer_left(_peer_id);
        }
    }
    
    /// @desc Client handles ROUTED packet (message forwarded by host from another peer)
    static _client_handle_routed = function(_buffer)
    {
        var _data = relay_read_routed(_buffer);
        
        // Get packet type from payload
        var _inner_type = buffer_read(_data.payload, buffer_u8);
        
        if (on_game_packet != undefined)
        {
            on_game_packet(_data.from_peer_id, _inner_type, _data.payload);
        }
        
        buffer_delete(_data.payload);
    }
    
    // ========================================================================
    // UTILITY
    // ========================================================================
    
    /// @desc Get local IP address
    /// @returns {String}
    static _get_local_ip = function()
    {
        // GameMaker doesn't have a built-in way to get local IP
        // For now, return a placeholder - user can manually specify
        // In production, could use an extension or external service
        
        // Try to get from os_get_info on some platforms
        var _info = os_get_info();
        if (ds_map_exists(_info, "local_ip"))
        {
            var _ip = _info[? "local_ip"];
            ds_map_destroy(_info);
            return _ip;
        }
        ds_map_destroy(_info);
        
        // Fallback
        return "127.0.0.1";
    }
}
