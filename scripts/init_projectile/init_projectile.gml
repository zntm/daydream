global.projectile_data = {}

function init_projectile(_directory, _namespace = "phantasia")
{
    var _files = file_read_directory(_directory);
    var _files_length = array_length(_files);
    
    for (var i = 0; i < _files_length; ++i)
    {
        var _file = _files[i];
        
        dbg_timer("init_projectile");
        
        var _json = buffer_load_json($"{_directory}/{_file}/data.json");
        
        var _data = new ProjectileData(_namespace, _file);
        
        var _sprite_data = _json.sprite;
        
        var _sprite_xoffset = _sprite_data.xoffset;
        var _sprite_yoffset = _sprite_data.yoffset;
        
        var _sprite = sprite_add($"{_directory}/{_file}/sprite.png", _sprite_data.length, false, false, _sprite_xoffset, _sprite_yoffset);
        
        _data.set_sprite(_sprite);
        
        _data.set_lifetime(_json.lifetime);
        _data.set_physics(_json[$ "physics"]);
        
        var _attribute = _json.attribute;
        
        _data.set_attribute(new Attribute()
            .set_hit_box(_attribute[$ "hit_box"])
            .set_gravity(_attribute[$ "gravity"])
        );
        
        global.projectile_data[$ $"{_namespace}:{_file}"] = _data;
        
        dbg_timer("init_projectile", $"[Init] Loaded Projectile: '{_file}'");
        
        delete _json;
    }
}