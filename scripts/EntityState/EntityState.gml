/// @desc Serializable entity state for multiplayer sync and save/load

function EntityState() constructor
{
    // Identity
    uuid = "";
    entity_type = "";  // "player", "creature:phantasia:slime", "mount:horse"
    
    // Core stats
    hp = 0;
    hp_max = 0;
    
    // Physics snapshot
    physics = {
        x: 0,
        y: 0,
        vx: 0,
        vy: 0,
        mode: MOVEMENT_MODE.GROUND
    }
    
    // Timers
    timer_immunity = 0;
    timer_regeneration = 0;
    
    // Effects (map of effect_id -> { duration, level })
    effects = {}
    
    // Mount relationship
    mount_uuid = "";
    rider_uuid = "";
    
    // Item/Projectile attributes
    extra_id = "";     // For item ID or projectile ID
    extra_value = 0;   // For item amount or damage
    
    /// @desc Capture state from an entity instance
    /// @param {Id.Instance} _inst
    static capture = function(_inst)
    {
        uuid = _inst.uuid;
        
        // Determine entity type
        // Note: obj_Client is the object used for remote players on the server
        if (_inst.object_index == obj_Player || _inst.object_index == obj_Client)
        {
            entity_type = "player";
            extra_value = _inst.selected_hotbar;
            
            // Resolve item ID for visual sync
            var _inv = global.inventory;
            if (global.network_role == RELAY_ROLE.HOST && !_inst.is_local)
            {
                var _peer = obj_Game_Control.relay_manager._find_peer_by_instance(_inst);
                if (_peer != undefined) _inv = _peer.inventory;
            }
            
            var _item = _inv.base[_inst.selected_hotbar];
            extra_id = (_item == INVENTORY_EMPTY) ? "" : _item.get_id();
        }
        else if (_inst.object_index == obj_Creature)
        {
            entity_type = $"creature:{_inst._id}";
        }
        else if (_inst.object_index == obj_Item_Drop)
        {
            entity_type = "item_drop";
            if (struct_exists(_inst, "item"))
            {
                extra_id = _inst.item.get_id();
                extra_value = _inst.item.get_amount();
            }
        }
        else if (_inst.object_index == obj_Projectile)
        {
            entity_type = "projectile";
            extra_id = _inst._id;
            extra_value = _inst.damage;
        }
        else
        {
            entity_type = "unknown";
        }
        
        // Core stats
        if (variable_instance_exists(_inst, "hp")) hp = _inst.hp;
        if (variable_instance_exists(_inst, "hp_max")) hp_max = _inst.hp_max;
        
        // Physics
        if (variable_instance_exists(_inst, "physics_body"))
        {
            var _body = _inst.physics_body;
            physics.x = _body.pos_x;
            physics.y = _body.pos_y;
            physics.vx = _body.vel_x;
            physics.vy = _body.vel_y;
            physics.mode = _body.mode;
        }
        else
        {
            // Legacy support
            physics.x = _inst.x;
            physics.y = _inst.y;
            if (variable_instance_exists(_inst, "xvelocity")) physics.vx = _inst.xvelocity;
            if (variable_instance_exists(_inst, "yvelocity")) physics.vy = _inst.yvelocity;
            physics.mode = MOVEMENT_MODE.GROUND;
        }
        
        // Timers
        if (variable_instance_exists(_inst, "timer_immunity")) timer_immunity = _inst.timer_immunity;
        if (variable_instance_exists(_inst, "timer_regeneration")) timer_regeneration = _inst.timer_regeneration;
        
        // Effects
        effects = {}
        if (variable_instance_exists(_inst, "effects"))
        {
            var _effect_names = struct_get_names(_inst.effects);
            for (var i = 0; i < array_length(_effect_names); ++i)
            {
                var _name = _effect_names[i];
                effects[$ _name] = _inst.effects[$ _name];
            }
        }
        
        // Mount state
        if (variable_instance_exists(_inst, "physics_body"))
        {
            if (_inst.physics_body.mount != undefined) mount_uuid = _inst.physics_body.mount[$ "entity_uuid"] ?? "";
            if (_inst.physics_body.rider != undefined) rider_uuid = _inst.physics_body.rider[$ "entity_uuid"] ?? "";
        }
        
        return self;
    }
    
    /// @desc Apply state to an entity instance
    /// @param {Id.Instance} _inst
    static apply = function(_inst)
    {
        _inst.uuid = uuid;
        if (variable_instance_exists(_inst, "hp")) _inst.hp = hp;
        if (variable_instance_exists(_inst, "hp_max")) _inst.hp_max = hp_max;
        
        // Physics
        if (variable_instance_exists(_inst, "physics_body"))
        {
            var _body = _inst.physics_body;
            _body.pos_x = physics.x;
            _body.pos_y = physics.y;
            _body.vel_x = physics.vx;
            _body.vel_y = physics.vy;
            _body.mode = physics.mode;
            _body.sync_to_instance(_inst);
        }
        else
        {
            _inst.x = physics.x;
            _inst.y = physics.y;
            if (variable_instance_exists(_inst, "xvelocity")) _inst.xvelocity = physics.vx;
            if (variable_instance_exists(_inst, "yvelocity")) _inst.yvelocity = physics.vy;
        }
        
        if (entity_type == "player")
        {
            if (variable_instance_exists(_inst, "selected_hotbar")) _inst.selected_hotbar = extra_value;
            _inst.extra_id = extra_id; // Store held item ID for visuals
        }
        
        // Timers
        if (variable_instance_exists(_inst, "timer_immunity")) _inst.timer_immunity = timer_immunity;
        if (variable_instance_exists(_inst, "timer_regeneration")) _inst.timer_regeneration = timer_regeneration;
        
        // Effects
        if (variable_instance_exists(_inst, "effects"))
        {
            _inst.effects = {}
            var _effect_names = struct_get_names(effects);
            for (var i = 0; i < array_length(_effect_names); ++i)
            {
                var _name = _effect_names[i];
                _inst.effects[$ _name] = effects[$ _name];
            }
        }
        
        return self;
    }
    
    /// @desc Serialize to buffer for network transmission
    /// @param {Id.Buffer} _buffer
    static to_buffer = function(_buffer)
    {
        buffer_write(_buffer, buffer_string, uuid);
        buffer_write(_buffer, buffer_string, entity_type);
        buffer_write(_buffer, buffer_string, extra_id);
        buffer_write(_buffer, buffer_f32, extra_value);
        buffer_write(_buffer, buffer_f32, hp);
        buffer_write(_buffer, buffer_f32, hp_max);
        buffer_write(_buffer, buffer_f32, physics.x);
        buffer_write(_buffer, buffer_f32, physics.y);
        buffer_write(_buffer, buffer_f32, physics.vx);
        buffer_write(_buffer, buffer_f32, physics.vy);
        buffer_write(_buffer, buffer_u8, physics.mode);
        buffer_write(_buffer, buffer_f32, timer_immunity);
        buffer_write(_buffer, buffer_f32, timer_regeneration);
        buffer_write(_buffer, buffer_string, mount_uuid);
        buffer_write(_buffer, buffer_string, rider_uuid);
        
        // Effects: Binary serialization
        var _effect_names = struct_get_names(effects);
        var _effect_count = array_length(_effect_names);
        buffer_write(_buffer, buffer_u8, _effect_count);
        
        for (var i = 0; i < _effect_count; ++i)
        {
            var _name = _effect_names[i];
            var _effect_data = effects[$ _name];
            buffer_write(_buffer, buffer_string, _name);
            // Each effect is expected to be { duration, level } or similar simple struct
            buffer_write(_buffer, buffer_string, json_stringify(_effect_data));
        }
        
        return self;
    }
    
    /// @desc Deserialize from buffer
    static from_buffer = function(_buffer)
    {
        uuid = buffer_read(_buffer, buffer_string);
        entity_type = buffer_read(_buffer, buffer_string);
        extra_id = buffer_read(_buffer, buffer_string);
        extra_value = buffer_read(_buffer, buffer_f32);
        hp = buffer_read(_buffer, buffer_f32);
        hp_max = buffer_read(_buffer, buffer_f32);
        physics.x = buffer_read(_buffer, buffer_f32);
        physics.y = buffer_read(_buffer, buffer_f32);
        physics.vx = buffer_read(_buffer, buffer_f32);
        physics.vy = buffer_read(_buffer, buffer_f32);
        physics.mode = buffer_read(_buffer, buffer_u8);
        timer_immunity = buffer_read(_buffer, buffer_f32);
        timer_regeneration = buffer_read(_buffer, buffer_f32);
        mount_uuid = buffer_read(_buffer, buffer_string);
        rider_uuid = buffer_read(_buffer, buffer_string);
        
        // Effects: Binary deserialization
        var _effect_count = buffer_read(_buffer, buffer_u8);
        effects = {}
        
        for (var i = 0; i < _effect_count; ++i)
        {
            var _name = buffer_read(_buffer, buffer_string);
            var _effect_data_json = buffer_read(_buffer, buffer_string);
            try
            {
                effects[$ _name] = json_parse(_effect_data_json);
            }
            catch (_e)
            {
                show_debug_message($"[NET] Error parsing effect '{_name}': {_e.message}");
                effects[$ _name] = {}
            }
        }
        
        return self;
    }
    
    /// @desc Serialize to struct for save files
    static serialize = function()
    {
        return {
            uuid: uuid,
            entity_type: entity_type,
            extra_id: extra_id,
            extra_value: extra_value,
            hp: hp,
            hp_max: hp_max,
            physics: physics,
            timer_immunity: timer_immunity,
            timer_regeneration: timer_regeneration,
            effects: effects,
            mount_uuid: mount_uuid,
            rider_uuid: rider_uuid
        }
    }
    
    /// @desc Deserialize from struct
    static deserialize = function(_data)
    {
        uuid = _data.uuid;
        entity_type = _data.entity_type;
        extra_id = _data.extra_id ?? "";
        extra_value = _data.extra_value ?? 0;
        hp = _data.hp;
        hp_max = _data.hp_max;
        physics = _data.physics;
        timer_immunity = _data.timer_immunity;
        timer_regeneration = _data.timer_regeneration;
        effects = _data.effects;
        mount_uuid = _data.mount_uuid;
        rider_uuid = _data.rider_uuid;
        
        return self;
    }
}
