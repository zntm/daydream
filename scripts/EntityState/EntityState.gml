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
    
    /// @desc Capture state from an entity instance
    /// @param {Id.Instance} _inst
    static capture = function(_inst)
    {
        uuid = _inst.uuid;
        
        // Determine entity type
        if (_inst.object_index == obj_Player)
        {
            entity_type = "player";
        }
        else if (_inst.object_index == obj_Creature)
        {
            entity_type = $"creature:{_inst._id}";
        }
        else
        {
            entity_type = "unknown";
        }
        
        // Core stats
        hp = _inst.hp;
        hp_max = _inst.hp_max;
        
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
            physics.vx = _inst.xvelocity;
            physics.vy = _inst.yvelocity;
            physics.mode = MOVEMENT_MODE.GROUND;
        }
        
        // Timers
        timer_immunity = _inst.timer_immunity;
        timer_regeneration = _inst.timer_regeneration;
        
        // Effects
        effects = {}
        var _effect_names = struct_get_names(_inst.effects);
        for (var i = 0; i < array_length(_effect_names); ++i)
        {
            var _name = _effect_names[i];
            effects[$ _name] = _inst.effects[$ _name];
        }
        
        // Mount state
        if (variable_instance_exists(_inst, "physics_body") && _inst.physics_body.mount != undefined)
        {
            mount_uuid = _inst.physics_body.mount[$ "entity_uuid"] ?? "";
        }
        if (variable_instance_exists(_inst, "physics_body") && _inst.physics_body.rider != undefined)
        {
            rider_uuid = _inst.physics_body.rider[$ "entity_uuid"] ?? "";
        }
        
        return self;
    }
    
    /// @desc Apply state to an entity instance
    /// @param {Id.Instance} _inst
    static apply = function(_inst)
    {
        _inst.uuid = uuid;
        _inst.hp = hp;
        _inst.hp_max = hp_max;
        
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
            _inst.xvelocity = physics.vx;
            _inst.yvelocity = physics.vy;
        }
        
        // Timers
        _inst.timer_immunity = timer_immunity;
        _inst.timer_regeneration = timer_regeneration;
        
        // Effects
        _inst.effects = {}
        var _effect_names = struct_get_names(effects);
        for (var i = 0; i < array_length(_effect_names); ++i)
        {
            var _name = _effect_names[i];
            _inst.effects[$ _name] = effects[$ _name];
        }
        
        return self;
    }
    
    /// @desc Serialize to buffer for network transmission
    /// @param {Id.Buffer} _buffer
    static to_buffer = function(_buffer)
    {
        buffer_write(_buffer, buffer_string, uuid);
        buffer_write(_buffer, buffer_string, entity_type);
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
        
        // Effects as JSON string for flexibility
        buffer_write(_buffer, buffer_string, json_stringify(effects));
        
        return self;
    }
    
    /// @desc Deserialize from buffer
    /// @param {Id.Buffer} _buffer
    static from_buffer = function(_buffer)
    {
        uuid = buffer_read(_buffer, buffer_string);
        entity_type = buffer_read(_buffer, buffer_string);
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
        
        var _effects_json = buffer_read(_buffer, buffer_string);
        effects = json_parse(_effects_json);
        
        return self;
    }
    
    /// @desc Serialize to struct for save files
    static serialize = function()
    {
        return {
            uuid: uuid,
            entity_type: entity_type,
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
