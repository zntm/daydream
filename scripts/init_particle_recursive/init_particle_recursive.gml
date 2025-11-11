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
        
        if (!file_exists(_subdirectory))
        {
            if (directory_exists(_subdirectory))
            {
                init_particle_recursive(_subdirectory, _namespace, _name);
            }
            
            continue;
        }
        
        dbg_timer("init_particle");
        
        if (_id != undefined)
        {
            global.particle_data[$ $"{_namespace}:{_id}"] ??= [];
            
            array_push(global.particle_data[$ $"{_namespace}:{_id}"], $"{_namespace}:{_name}");
        }
        
        var _json = buffer_load_json(_subdirectory);
        
        var _particle_data = new ParticleData(_namespace, _id, _json.sprite);
        
        _particle_data.set_properties(_json[$ "properties"]);
        _particle_data.set_lifetime(_json.lifetime);
        _particle_data.set_physics(_json[$ "physics"]);
        
        var _attribute = _json[$ "attribute"];
        
        if (_attribute != undefined)
        {
            _particle_data.set_attribute(new Attribute()
                .set_collision_box(_attribute[$ "collision_box_width"], _attribute[$ "collision_box_height"])
                .set_gravity(_attribute[$ "gravity"])
            );
        }
        
        global.particle_data[$ $"{_namespace}:{string_delete(_name, string_length(_name) - 4, 5)}"] = _particle_data; 
        
        delete _json;
        
        dbg_timer("init_particle", $"[Init] Loaded Particle: \'{string_delete(_name, string_length(_name) - 4, 5)}\'");
    }
}