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
            global.particle_data[$ _id] ??= [];
            
            array_push(global.particle_data[$ _id], _name);
        }
        
        var _json = buffer_load_json($"{_subdirectory}/data.json");
        
        var _sprite = sprite_add($"{_subdirectory}/sprite.png", (_json[$ "frames"] ?? 1), false, false, 0, 0);
        
        var _sprite_xoffset = round(sprite_get_width(_sprite)  / 2);
        var _sprite_yoffset = round(sprite_get_height(_sprite) / 2);
        
        sprite_set_offset(_sprite, _sprite_xoffset, _sprite_yoffset);
        
        global.particle_data[$ $"{_namespace}:{_file}"] = new ParticleData(_sprite)
            .set_sprite_offset(_sprite_xoffset, _sprite_yoffset)
            .set_velocity(_json[$ "xvelocity"], _json[$ "yvelocity"])
            .set_velocity_on_collision(_json[$ "xvelocity_on_collision"], _json[$ "yvelocity_on_collision"])
            .set_gravity(_json[$ "gravity"])
            .set_collision_box(_json[$ "collision_box"]);
        
        delete _json;
        
        dbg_timer("init_particle", $"[Init] Loaded Particle: \'{_file}\'");
    }
}