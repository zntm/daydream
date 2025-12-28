/// @desc Mount configuration data

global.mount_data = {}

enum MOUNT_TYPE {
    CREATURE,   // Existing creature that can be mounted
    SUMMONED    // Summoned entity that exists only while mounted
}

function MountData(_namespace, _id) constructor
{
    id = $"{_namespace}:{_id}";
    type = MOUNT_TYPE.CREATURE;
    
    // Rider positioning relative to mount
    rider_offset_x = 0;
    rider_offset_y = -16;  // Default: sit on top
    
    // Movement capabilities
    can_fly = false;
    can_swim = false;
    can_climb = false;
    
    // Speed modifiers (multiply rider base stats)
    speed_multiplier = 1.5;
    jump_multiplier = 1.2;
    
    // Control mode
    controlled_by_rider = true;  // false = AI-driven with rider as passenger
    
    // Required item to summon (for summoned mounts)
    summon_item = undefined;
    
    // Duration for summoned mounts (undefined = permanent until dismissed)
    summon_duration = undefined;
    
    // Sprite for mount
    sprite = undefined;
    
    /// @desc Set mount type
    static set_type = function(_type)
    {
        type = _type;
        return self;
    }
    
    /// @desc Set rider offset
    static set_rider_offset = function(_x, _y)
    {
        rider_offset_x = _x;
        rider_offset_y = _y;
        return self;
    }
    
    /// @desc Set movement capabilities
    static set_capabilities = function(_fly = false, _swim = false, _climb = false)
    {
        can_fly = _fly;
        can_swim = _swim;
        can_climb = _climb;
        return self;
    }
    
    /// @desc Set speed modifiers
    static set_speed = function(_speed_mult = 1.5, _jump_mult = 1.2)
    {
        speed_multiplier = _speed_mult;
        jump_multiplier = _jump_mult;
        return self;
    }
    
    /// @desc Set control mode
    static set_controlled_by_rider = function(_controlled)
    {
        controlled_by_rider = _controlled;
        return self;
    }
    
    /// @desc Set summon requirements
    static set_summon = function(_item, _duration = undefined)
    {
        summon_item = _item;
        summon_duration = _duration;
        return self;
    }
    
    /// @desc Set sprite
    static set_sprite = function(_sprite)
    {
        sprite = _sprite;
        return self;
    }
}

/// @desc Initialize mount data from directory
/// @param {String} _directory
/// @param {String} _namespace
function init_mount(_directory, _namespace = "phantasia")
{
    var _files = file_read_directory(_directory);
    var _files_length = array_length(_files);
    
    for (var i = 0; i < _files_length; ++i)
    {
        var _file = _files[i];
        var _id = string_delete(_file, string_length(_file) - 4, 5);
        
        var _json = buffer_load_json($"{_directory}/{_file}");
        
        var _data = new MountData(_namespace, _id);
        
        if (_json[$ "type"] == "summoned")
        {
            _data.set_type(MOUNT_TYPE.SUMMONED);
        }
        
        _data.set_rider_offset(
            _json[$ "rider_offset_x"] ?? 0,
            _json[$ "rider_offset_y"] ?? -16
        );
        
        _data.set_capabilities(
            _json[$ "can_fly"] ?? false,
            _json[$ "can_swim"] ?? false,
            _json[$ "can_climb"] ?? false
        );
        
        _data.set_speed(
            _json[$ "speed_multiplier"] ?? 1.5,
            _json[$ "jump_multiplier"] ?? 1.2
        );
        
        _data.set_controlled_by_rider(_json[$ "controlled_by_rider"] ?? true);
        
        if (_json[$ "summon_item"] != undefined)
        {
            _data.set_summon(_json.summon_item, _json[$ "summon_duration"]);
        }
        
        if (_json[$ "sprite"] != undefined)
        {
            _data.set_sprite(_json.sprite);
        }
        
        global.mount_data[$ _data.id] = _data;
        
        delete _json;
    }
}
