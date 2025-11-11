global.projectile_data = {}

function init_projectile(_directory, _namespace = "phantasia")
{
    var _files = file_read_directory(_directory);
    var _files_length = array_length(_files);
    
    for (var i = 0; i < _files_length; ++i)
    {
        var _file = _files[i];
        
        dbg_timer("init_projectile");
        
        var _json = buffer_load_json($"{_directory}/{_file}");
        
        var _id = string_delete(_file, string_length(_file) - 4, 5);
        
        var _data = new ProjectileData(_namespace, _id, _json.sprite);
        
        _data.set_properties(_json[$ "properties"]);
        _data.set_lifetime(_json.lifetime);
        _data.set_physics(_json[$ "physics"]);
        
        var _attribute = _json.attribute;
        
        _data.set_attribute(new Attribute()
            .set_collision_box(_attribute[$ "collision_box_width"], _attribute[$ "collision_box_height"])
            .set_hit_box(_attribute[$ "hit_box_width"], _attribute[$ "hit_box_height"])
            .set_gravity(_attribute[$ "gravity"])
        );
        
        global.projectile_data[$ $"{_namespace}:{_id}"] = _data;
        
        dbg_timer("init_projectile", $"[Init] Loaded Projectile: '{_id}'");
        
        delete _json;
    }
}