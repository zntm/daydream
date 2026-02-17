/// @desc P2P Validator - Consensus-based action validation for cheat prevention
/// Actions are validated by all peers before being confirmed

global.validator = undefined;

/// @desc Initialize the P2P validator
function validator_init()
{
    global.validator = new P2PValidator();
}

/// @desc Action types that can be validated
enum ACTION_TYPE {
    MOVEMENT,       // Position update
    TILE_PLACE,     // Placing a block
    TILE_BREAK,     // Breaking a block
    ITEM_DROP,      // Dropping an item
    ITEM_PICKUP,    // Picking up an item
    ATTACK,         // Attacking an entity
    USE_ITEM,       // Using an item/tool
    
    __SIZE
}

/// @desc P2P Validator for consensus-based validation
function P2PValidator() constructor
{
    // Pending actions awaiting validation
    // action_id -> { type, data, votes: { peer_id: bool }, submitted_at, local, callback }
    pending = {}
    
    // Configuration
    validation_timeout_ms = 2000;   // 2 seconds to collect votes
    movement_check_interval = 30;   // Validate movement every 30 ticks (~1 second)
    
    // Movement tracking for validation
    _last_validated_positions = {}  // peer_id -> { x, y, tick }
    _movement_tick_counter = 0;
    
    // Speed limits (pixels per tick)
    max_ground_speed = 4.0;
    max_fly_speed = 10.0;
    max_fall_speed = 25.0;
    speed_tolerance = 1.5;  // 50% tolerance for network jitter
    
    // ========================================================================
    // PUBLIC API
    // ========================================================================
    
    /// @desc Submit an action for P2P validation
    /// @param {Enum.ACTION_TYPE} _type Action type
    /// @param {Struct} _data Action data
    /// @param {Function} _on_result Optional callback(action_id, approved)
    /// @returns {String} action_id
    static request_validation = function(_type, _data, _on_result = undefined)
    {
        var _action_id = uuid_generate(irandom(0xffffffff));
        
        pending[$ _action_id] = {
            type: _type,
            data: _data,
            votes: {},
            submitted_at: current_time,
            local: true,
            callback: _on_result,
            applied_optimistically: false
        }
        
        // Build validation request packet
        var _buf = relay_packet_create(RELAY_PACKET.VALIDATE_REQUEST);
        buffer_write(_buf, buffer_string, global.relay.local_peer_id);
        buffer_write(_buf, buffer_string, _action_id);
        buffer_write(_buf, buffer_u8, _type);
        _serialize_action_data(_buf, _type, _data);
        
        // Broadcast to all peers
        global.relay.broadcast(_buf);
        buffer_delete(_buf);
        
        show_debug_message($"[VALIDATOR] Requested validation for {_type}, id: {_action_id}");
        
        return _action_id;
    }
    
    /// @desc Apply action optimistically (before consensus)
    /// @param {String} _action_id
    static apply_optimistic = function(_action_id)
    {
        var _action = pending[$ _action_id];
        if (_action == undefined) return;
        
        _action.applied_optimistically = true;
        _apply_action(_action.type, _action.data);
    }
    
    /// @desc Process incoming validation request from another peer
    /// @param {String} _requester_id Peer requesting validation
    /// @param {Id.Buffer} _buffer Buffer positioned after packet type
    static on_validation_request = function(_requester_id, _buffer)
    {
        var _action_id = buffer_read(_buffer, buffer_string);
        var _type = buffer_read(_buffer, buffer_u8);
        var _data = _deserialize_action_data(_buffer, _type);
        
        // Validate the action locally
        var _valid = _validate_action(_type, _data, _requester_id);
        
        var _is_valid = _valid ? "VALID" : "INVALID";
        
        show_debug_message($"[VALIDATOR] Validating action {_type} from {_requester_id}: {_is_valid}");
        
        // Send vote back to requester
        var _vote_buf = relay_packet_create(RELAY_PACKET.VALIDATE_VOTE);
        buffer_write(_vote_buf, buffer_string, _action_id);
        buffer_write(_vote_buf, buffer_bool, _valid);
        
        global.relay.send_to_peer(_requester_id, _vote_buf);
        buffer_delete(_vote_buf);
        
        // If valid, store locally (pending confirmation)
        if (_valid)
        {
            pending[$ _action_id] = {
                type: _type,
                data: _data,
                requester: _requester_id,
                local: false
            }
        }
    }
    
    /// @desc Process incoming vote from a peer
    /// @param {String} _voter_id Peer who voted
    /// @param {Id.Buffer} _buffer Buffer positioned after packet type
    static on_vote = function(_voter_id, _buffer)
    {
        var _action_id = buffer_read(_buffer, buffer_string);
        var _valid = buffer_read(_buffer, buffer_bool);
        
        var _action = pending[$ _action_id];
        if (_action == undefined || !_action.local) return;
        
        _action.votes[$ _voter_id] = _valid;
        
        show_debug_message($"[VALIDATOR] Vote from {_voter_id} on {_action_id}: {_valid}");
        
        // Check if we have enough votes
        _check_consensus(_action_id);
    }
    
    /// @desc Process validation result broadcast
    /// @param {String} _requester_id Original requester
    /// @param {Id.Buffer} _buffer
    static on_result = function(_requester_id, _buffer)
    {
        var _action_id = buffer_read(_buffer, buffer_string);
        var _approved = buffer_read(_buffer, buffer_bool);
        
        var _action = pending[$ _action_id];
        if (_action == undefined) return;
        
        var _is_approved = _approved ? "APPROVED" : "REJECTED";
        
        show_debug_message($"[VALIDATOR] Result for {_action_id}: {_is_approved}");
        
        if (_approved && !_action.local)
        {
            // Apply the action locally
            _apply_action(_action.type, _action.data);
        }
        
        struct_remove(pending, _action_id);
    }
    
    /// @desc Update step - check timeouts and periodic movement validation
    static update = function()
    {
        var _now = current_time;
        var _expired = [];
        
        // Check for timed out actions
        var _action_ids = struct_get_names(pending);
        for (var i = 0; i < array_length(_action_ids); ++i)
        {
            var _aid = _action_ids[i];
            var _action = pending[$ _aid];
            
            if (_action.local && (_now - _action.submitted_at) > validation_timeout_ms)
            {
                array_push(_expired, _aid);
            }
        }
        
        // Handle expired actions (treat as rejected for safety)
        for (var i = 0; i < array_length(_expired); ++i)
        {
            var _aid = _expired[i];
            var _action = pending[$ _aid];
            
            show_debug_message($"[VALIDATOR] Action {_aid} timed out");
            
            // If applied optimistically, need to rollback
            if (_action.applied_optimistically)
            {
                _rollback_action(_action.type, _action.data);
            }
            
            if (_action.callback != undefined)
            {
                _action.callback(_aid, false);
            }
            
            struct_remove(pending, _aid);
        }
        
        // Periodic movement validation
        _movement_tick_counter++;
        if (_movement_tick_counter >= movement_check_interval)
        {
            _movement_tick_counter = 0;
            _validate_all_movements();
        }
    }
    
    // ========================================================================
    // VALIDATION LOGIC
    // ========================================================================
    
    /// @desc Validate an action
    /// @returns {Bool}
    static _validate_action = function(_type, _data, _requester_id)
    {
        switch (_type)
        {
            case ACTION_TYPE.MOVEMENT:
                return _validate_movement(_data, _requester_id);
                
            case ACTION_TYPE.TILE_PLACE:
            case ACTION_TYPE.TILE_BREAK:
                return _validate_tile_action(_data, _requester_id);
                
            case ACTION_TYPE.ATTACK:
                return _validate_attack(_data, _requester_id);
                
            case ACTION_TYPE.ITEM_DROP:
            case ACTION_TYPE.ITEM_PICKUP:
                return _validate_item_action(_data, _requester_id);
                
            default:
                return true;  // Unknown actions pass by default
        }
    }
    
    /// @desc Validate movement (anti-speedhack)
    static _validate_movement = function(_data, _peer_id)
    {
        // Get last known position
        var _last = _last_validated_positions[$ _peer_id];
        
        if (_last == undefined)
        {
            // First position, accept it
            _last_validated_positions[$ _peer_id] = {
                x: _data.x,
                y: _data.y,
                tick: _data.tick
            }
            return true;
        }
        
        // Calculate distance moved
        var _distance = point_distance(_last.x, _last.y, _data.x, _data.y);
        var _ticks_elapsed = max(1, _data.tick - _last.tick);
        var _speed_per_tick = _distance / _ticks_elapsed;
        
        // Determine max allowed speed
        var _max_speed = max_ground_speed;
        if (_data.is_flying) _max_speed = max_fly_speed;
        
        // Apply tolerance
        var _allowed_speed = _max_speed * speed_tolerance;
        
        // Validate
        var _valid = (_speed_per_tick <= _allowed_speed);
        
        if (!_valid)
        {
            show_debug_message($"[VALIDATOR] Movement rejected: speed={_speed_per_tick}, max={_allowed_speed}");
        }
        else
        {
            // Update last known position
            _last_validated_positions[$ _peer_id] = {
                x: _data.x,
                y: _data.y,
                tick: _data.tick
            }
        }
        
        return _valid;
    }
    
    /// @desc Validate tile placement/breaking (reach check)
    static _validate_tile_action = function(_data, _peer_id)
    {
        // Get peer's player instance
        var _peer = global.relay.peers[$ _peer_id];
        if (_peer == undefined || !instance_exists(_peer.player_instance))
        {
            return false;
        }
        
        var _player = _peer.player_instance;
        var _tile_px = _data.x * TILE_SIZE + TILE_SIZE / 2;
        var _tile_py = _data.y * TILE_SIZE + TILE_SIZE / 2;
        
        var _distance = point_distance(_player.x, _player.y, _tile_px, _tile_py);
        var _max_reach = 400;  // ~25 tiles
        
        var _valid = (_distance <= _max_reach);
        
        if (!_valid)
        {
            show_debug_message($"[VALIDATOR] Tile action rejected: distance={_distance}, max={_max_reach}");
        }
        
        return _valid;
    }
    
    /// @desc Validate attack (reach check)
    static _validate_attack = function(_data, _peer_id)
    {
        var _peer = global.relay.peers[$ _peer_id];
        if (_peer == undefined || !instance_exists(_peer.player_instance))
        {
            return false;
        }
        
        var _player = _peer.player_instance;
        var _distance = point_distance(_player.x, _player.y, _data.target_x, _data.target_y);
        var _max_reach = 100;  // Melee range
        
        return (_distance <= _max_reach);
    }
    
    /// @desc Validate item actions
    static _validate_item_action = function(_data, _peer_id)
    {
        // Basic validation - items must exist, player must be in range
        var _peer = global.relay.peers[$ _peer_id];
        if (_peer == undefined || !instance_exists(_peer.player_instance))
        {
            return false;
        }
        
        // For item pickup, check if item is near player
        if (_data.action_type == ACTION_TYPE.ITEM_PICKUP)
        {
            var _player = _peer.player_instance;
            var _distance = point_distance(_player.x, _player.y, _data.item_x, _data.item_y);
            return (_distance <= 64);  // Pickup range
        }
        
        return true;
    }
    
    // ========================================================================
    // CONSENSUS
    // ========================================================================
    
    /// @desc Check if we have consensus on an action
    static _check_consensus = function(_action_id)
    {
        var _action = pending[$ _action_id];
        if (_action == undefined || !_action.local) return;
        
        var _peer_count = global.relay.get_peer_count() - 1;  // Exclude self
        
        // Single player case
        if (_peer_count == 0)
        {
            _finalize_action(_action_id, true);
            return;
        }
        
        var _vote_count = array_length(struct_get_names(_action.votes));
        
        // Not enough votes yet
        if (_vote_count < _peer_count) return;
        
        // Tally votes
        var _yes = 0, _no = 0;
        var _voter_ids = struct_get_names(_action.votes);
        for (var i = 0; i < array_length(_voter_ids); ++i)
        {
            if (_action.votes[$ _voter_ids[i]]) _yes++;
            else _no++;
        }
        
        // Simple majority
        var _approved = (_yes > _no);
        
        _finalize_action(_action_id, _approved);
    }
    
    /// @desc Finalize an action after consensus
    static _finalize_action = function(_action_id, _approved)
    {
        var _action = pending[$ _action_id];
        if (_action == undefined) return;
        
        var _is_approved = _approved ? "APPROVED" : "REJECTED";
        
        show_debug_message($"[VALIDATOR] Finalizing {_action_id}: {_is_approved}");
        
        if (_approved)
        {
            // Apply if not already applied optimistically
            if (!_action.applied_optimistically)
            {
                _apply_action(_action.type, _action.data);
            }
            
            // Broadcast result to all peers
            var _result_buf = relay_packet_create(RELAY_PACKET.VALIDATE_RESULT);
            buffer_write(_result_buf, buffer_string, _action_id);
            buffer_write(_result_buf, buffer_bool, true);
            global.relay.broadcast(_result_buf);
            buffer_delete(_result_buf);
        }
        else
        {
            // Rollback if applied optimistically
            if (_action.applied_optimistically)
            {
                _rollback_action(_action.type, _action.data);
            }
            
            // Broadcast rejection
            var _result_buf = relay_packet_create(RELAY_PACKET.VALIDATE_RESULT);
            buffer_write(_result_buf, buffer_string, _action_id);
            buffer_write(_result_buf, buffer_bool, false);
            global.relay.broadcast(_result_buf);
            buffer_delete(_result_buf);
        }
        
        // Callback
        if (_action.callback != undefined)
        {
            _action.callback(_action_id, _approved);
        }
        
        struct_remove(pending, _action_id);
    }
    
    // ========================================================================
    // ACTION APPLICATION
    // ========================================================================
    
    /// @desc Apply a validated action
    static _apply_action = function(_type, _data)
    {
        switch (_type)
        {
            case ACTION_TYPE.TILE_PLACE:
                var _tile = new Tile(_data.tile_id);
                tile_place(_data.x, _data.y, _data.z, _tile);
                break;
                
            case ACTION_TYPE.TILE_BREAK:
                tile_place(_data.x, _data.y, _data.z, TILE_EMPTY);
                break;
                
            case ACTION_TYPE.MOVEMENT:
                // Movement is handled differently - just update position tracking
                break;
                
            // Other action types would be handled here
        }
    }
    
    /// @desc Rollback an optimistically applied action
    static _rollback_action = function(_type, _data)
    {
        switch (_type)
        {
            case ACTION_TYPE.TILE_PLACE:
                // Revert to empty (or previous state if tracked)
                tile_place(_data.x, _data.y, _data.z, TILE_EMPTY);
                show_debug_message("[VALIDATOR] Rolled back tile placement");
                break;
                
            case ACTION_TYPE.TILE_BREAK:
                // Restore the tile (need previous state)
                if (_data.previous_tile_id != undefined)
                {
                    var _tile = new Tile(_data.previous_tile_id);
                    tile_place(_data.x, _data.y, _data.z, _tile);
                }
                show_debug_message("[VALIDATOR] Rolled back tile break");
                break;
        }
    }
    
    // ========================================================================
    // PERIODIC MOVEMENT VALIDATION
    // ========================================================================
    
    /// @desc Validate all peer movements periodically
    static _validate_all_movements = function()
    {
        var _peer_ids = global.relay.get_peer_ids();
        
        for (var i = 0; i < array_length(_peer_ids); ++i)
        {
            var _pid = _peer_ids[i];
            var _peer = global.relay.peers[$ _pid];
            
            if (_peer == undefined || !instance_exists(_peer.player_instance)) continue;
            
            var _player = _peer.player_instance;
            var _is_flying = variable_instance_exists(_player, "is_flying") && _player.is_flying;
            
            var _movement_data = {
                x: _player.x,
                y: _player.y,
                tick: current_time,  // Using current_time as tick proxy
                is_flying: _is_flying
            }
            
            var _valid = _validate_movement(_movement_data, _pid);
            
            if (!_valid)
            {
                show_debug_message($"[VALIDATOR] Peer {_pid} failed movement validation!");
                // Could implement penalty system here (kick, snap back, etc.)
            }
        }
    }
    
    // ========================================================================
    // SERIALIZATION
    // ========================================================================
    
    /// @desc Serialize action data to buffer
    static _serialize_action_data = function(_buffer, _type, _data)
    {
        switch (_type)
        {
            case ACTION_TYPE.MOVEMENT:
                buffer_write(_buffer, buffer_f32, _data.x);
                buffer_write(_buffer, buffer_f32, _data.y);
                buffer_write(_buffer, buffer_u32, _data.tick ?? 0);
                buffer_write(_buffer, buffer_bool, _data.is_flying ?? false);
                break;
                
            case ACTION_TYPE.TILE_PLACE:
            case ACTION_TYPE.TILE_BREAK:
                buffer_write(_buffer, buffer_s32, _data.x);
                buffer_write(_buffer, buffer_s32, _data.y);
                buffer_write(_buffer, buffer_u8, _data.z);
                buffer_write(_buffer, buffer_string, _data.tile_id ?? "");
                buffer_write(_buffer, buffer_string, _data.previous_tile_id ?? "");
                break;
                
            case ACTION_TYPE.ATTACK:
                buffer_write(_buffer, buffer_f32, _data.target_x);
                buffer_write(_buffer, buffer_f32, _data.target_y);
                buffer_write(_buffer, buffer_string, _data.target_uuid ?? "");
                buffer_write(_buffer, buffer_f32, _data.damage ?? 0);
                break;
                
            case ACTION_TYPE.ITEM_DROP:
            case ACTION_TYPE.ITEM_PICKUP:
                buffer_write(_buffer, buffer_f32, _data.item_x ?? 0);
                buffer_write(_buffer, buffer_f32, _data.item_y ?? 0);
                buffer_write(_buffer, buffer_string, _data.item_id ?? "");
                buffer_write(_buffer, buffer_u16, _data.amount ?? 1);
                break;
                
            default:
                buffer_write(_buffer, buffer_string, json_stringify(_data));
                break;
        }
    }
    
    /// @desc Deserialize action data from buffer
    static _deserialize_action_data = function(_buffer, _type)
    {
        switch (_type)
        {
            case ACTION_TYPE.MOVEMENT:
                return {
                    x: buffer_read(_buffer, buffer_f32),
                    y: buffer_read(_buffer, buffer_f32),
                    tick: buffer_read(_buffer, buffer_u32),
                    is_flying: buffer_read(_buffer, buffer_bool)
                }
                
            case ACTION_TYPE.TILE_PLACE:
            case ACTION_TYPE.TILE_BREAK:
                return {
                    x: buffer_read(_buffer, buffer_s32),
                    y: buffer_read(_buffer, buffer_s32),
                    z: buffer_read(_buffer, buffer_u8),
                    tile_id: buffer_read(_buffer, buffer_string),
                    previous_tile_id: buffer_read(_buffer, buffer_string)
                }
                
            case ACTION_TYPE.ATTACK:
                return {
                    target_x: buffer_read(_buffer, buffer_f32),
                    target_y: buffer_read(_buffer, buffer_f32),
                    target_uuid: buffer_read(_buffer, buffer_string),
                    damage: buffer_read(_buffer, buffer_f32)
                }
                
            case ACTION_TYPE.ITEM_DROP:
            case ACTION_TYPE.ITEM_PICKUP:
                return {
                    item_x: buffer_read(_buffer, buffer_f32),
                    item_y: buffer_read(_buffer, buffer_f32),
                    item_id: buffer_read(_buffer, buffer_string),
                    amount: buffer_read(_buffer, buffer_u16)
                }
                
            default:
                var _json = buffer_read(_buffer, buffer_string);
                try { return json_parse(_json); } catch(_e) { return {} }
        }
    }
}
