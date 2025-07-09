global.creature_data = {}

function init_creature(_directory, _namespace = "phantasia")
{
    static __hostility_type = {
        passive: CREATURE_HOSTILITY_TYPE.PASSIVE,
        hostile: CREATURE_HOSTILITY_TYPE.HOSTILE,
    }
    
    static __movement_type = {
        ground: CREATURE_MOVEMENT_TYPE.DEFAULT,
        flight: CREATURE_MOVEMENT_TYPE.FLY,
        swim: CREATURE_MOVEMENT_TYPE.SWIM,
    }
    
    static __sprite_add = function(_directory, _frames, _xorigin = undefined, _yorigin = undefined)
    {
        if (file_exists($"{_directory}.png"))
        {
            var _sprite = sprite_add($"{_directory}.png", _frames, false, false, 0, 0);
            
            sprite_set_offset(_sprite, _xorigin ?? (sprite_get_width(_sprite) / 2), _yorigin ?? sprite_get_height(_sprite));
            
            return _sprite;
        }
        
        if (!directory_exists(_directory))
        {
            return undefined;
        }
        
        var _data = {}
        
        var _files = file_read_directory(_directory);
        var _files_length = array_length(_files);
        
        for (var i = 0; i < _files_length; ++i)
        {
            var _file = _files[i];
            
            var _sprite = sprite_add($"{_directory}/{_file}", _frames, false, false, 0, 0);
            
            sprite_set_offset(_sprite, _xorigin ?? (sprite_get_width(_sprite) / 2), _yorigin ?? sprite_get_height(_sprite));
            
            _data[$ string_delete(_file, string_length(_file) - 3, 4)] = _sprite;
        }
        
        return _data;
    }
    /*
    static __sprite_delete = function(_name, _sprite)
    {
        if (_sprite == undefined) exit;
        
        if (!is_array(_sprite))
        {
            sprite_delete(_sprite);
            
            exit;
        }
        
        var _length = array_length(_sprite);
        
        for (var i = 0; i < _length; ++i)
        {
            sprite_delete(_sprite[i]);
        }
    }
    
    if (_type & INIT_TYPE.RESET)
    {
        var _creature_data = global.creature_data;
        
        var _names = struct_get_names(_creature_data);
        var _length = array_length(_names);
        
        for (var i = 0; i < _length; ++i)
        {
            var _data = _creature_data[$ _names[i]];
            
            __sprite_delete(_data.sprite_idle);
            __sprite_delete(_data.sprite_moving);
            __sprite_delete(_data.sprite_white);
        }
        
        init_data_reset("creature_data");
    }
    */
    var _files = file_read_directory(_directory);
    var _files_length = array_length(_files);
    
    for (var i = 0; i < _files_length; ++i)
    {
        var _file = _files[i];
        
        dbg_timer("init_creature");
        
        var _json = buffer_load_json($"{_directory}/{_file}/data.json");
        
        var _type = _json.type;
        
        var _data = new CreatureData(_namespace, _file, _json.hp, __hostility_type[$ _type.hostility], __movement_type[$ _type.movement]);
        
        var _sprite = _json.sprite;
        
        var _frames = _sprite.frames;
        
        var _frames_idle   = _frames.idle;
        var _frames_moving = _frames.moving;
        
        var _xorigin = _sprite[$ "xorigin"];
        var _yorigin = _sprite[$ "yorigin"];
        
        _data.set_sprite_idle(__sprite_add($"{_directory}/{_file}/sprite/idle", _frames_idle, _xorigin, _yorigin));
        _data.set_sprite_moving(__sprite_add($"{_directory}/{_file}/sprite/moving", _frames_moving, _xorigin, _yorigin));
        
        _data.set_sprite_idle_emissive(__sprite_add($"{_directory}/{_file}/sprite/idle_emissive", _frames_idle, _xorigin, _yorigin));
        _data.set_sprite_moving_emissive(__sprite_add($"{_directory}/{_file}/sprite/moving_emissive", _frames_moving, _xorigin, _yorigin));
        
        var _attribute = _json.attribute;
        
        _data.set_attribute(new Attribute()
            .set_boolean(_attribute[$ "boolean"])
            .set_collision_box(_attribute[$ "collision_box"])
            .set_hit_box(_attribute[$ "hit_box"])
            .set_eye_level(_attribute[$ "eye_level"])
            .set_gravity(_attribute[$ "gravity"])
            .set_jump_count_max(_attribute[$ "jump_count_max"])
            .set_jump_falloff(_attribute[$ "jump_falloff"])
            .set_jump_height(_attribute[$ "jump_height"])
            .set_jump_time(_attribute[$ "jump_time"])
            .set_movement_speed(_attribute[$ "movement_speed"])
        );
        
        _data.set_drop(_json[$ "drop"]);
        
        global.creature_data[$ $"{_namespace}:{_file}"] = _data;
        
        dbg_timer("init_creature", $"[Init] Loaded Creature: '{_file}'");
        
        delete _json;
    }
    
    show_debug_message(json_stringify(global.creature_data, true))
}