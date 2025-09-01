global.particle_data = {}

function init_particle_recursive(_directory, _namespace, _id)
{
    var _files = file_read_directory(_directory);
    var _files_length = array_length(_files);
    
    for (var i = 0; i < _files_length; ++i)
    {
        var _file = _files[i];
        var _subdirectory = $"{_directory}/{_file}";
        
        var _name = ((_id == undefined) ? _file : $"{_id}/{_file}");
        
        if (!file_exists($"{_subdirectory}/data.json"))
        {
            init_particle_recursive(_subdirectory, _namespace, _name);
            
            continue;
        }
        
        dbg_timer("init_particle");
        
        if (_id != undefined)
        {
            global.particle_data[$ $"{_namespace}:{_id}"] ??= [];
            
            array_push(global.particle_data[$ $"{_namespace}:{_id}"], $"{_namespace}:{_name}");
        }
        
        var _json = buffer_load_json($"{_subdirectory}/data.json");
        
        var _sprite_data = _json.sprite;
        
        var _sprite = sprite_add($"{_subdirectory}/sprite.png", _sprite_data[$ "length"] ?? 1, false, false, 0, 0);
        
        var _sprite_xoffset = round(sprite_get_width(_sprite)  / 2);
        var _sprite_yoffset = round(sprite_get_height(_sprite) / 2);
        
        sprite_set_offset(_sprite, _sprite_xoffset, _sprite_yoffset);
        
        var _particle_data = new ParticleData(_namespace, _id, _sprite, _sprite_data);
        
        _particle_data.set_properties(_json[$ "properties"]);
        _particle_data.set_lifetime(_json.lifetime);
        _particle_data.set_physics(_json[$ "physics"]);
        
        var _attribute = _json[$ "attribute"];
        
        if (_attribute != undefined)
        {
            _particle_data.set_attribute(new Attribute()
                .set_collision_box(_attribute[$ "collision_box"])
                .set_gravity(_attribute[$ "gravity"])
            );
        }
        
        global.particle_data[$ $"{_namespace}:{_name}"] = _particle_data; 
        
        delete _json;
        
        dbg_timer("init_particle", $"[Init] Loaded Particle: \'{string_delete(_name, string_length(_name) - 4, 5)}\'");
    }
}