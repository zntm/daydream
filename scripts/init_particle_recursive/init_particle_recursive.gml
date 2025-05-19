global.particle_data = {}

function init_particle_recursive(_directory, _namespace, _id)
{
    var _files = file_read_directory(_directory);
    var _files_length = array_length(_files);
    
    for (var i = 0; i < _files_length; ++i)
    {
        var _file = _files[i];
        var _subdirectory = $"{_directory}/{_file}";
        
        show_debug_message(_subdirectory)
        
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
            .set_speed(_json[$ "xspeed"], _json[$ "yspeed"])
            .set_collision_box(_json[$ "collision_box"]);
        
        /*
        var _xspeed_on_collision = _json[$ "xspeed_on_collision"];
        var _yspeed_on_collision = _json[$ "yspeed_on_collision"];
        
        var _destroy_on_collision = _json[$ "destroy_on_collision"] ?? false;
        
        var _requires_sunlight = _json[$ "requires_sunlight"] ?? false;
        
        global.particle_data[$ $"{_namespace}:{_file}"] = {
            sprite:   _sprite,
            boolean: (_requires_sunlight << 5) | (_destroy_on_collision << 4) | ((_json[$ "additive"] ?? false) << 3) | ((_json[$ "stretch_animation"] ?? false) << 2) | (((_json[$ "collision"] ?? true) || (_destroy_on_collision) || (_xspeed_on_collision != undefined) || (_yspeed_on_collision != undefined)) << 1) | (_json[$ "fade_out"] ?? false),
            
            xspeed: _json[$ "xspeed"] ?? 0,
            yspeed: _json[$ "yspeed"] ?? 0,
            
            scale:   _json[$ "scale"] ?? 1,
            gravity: _json[$ "gravity"] ?? PHYSICS_GLOBAL_GRAVITY,
            
            rotation: _json[$ "rotation"] ?? 0,
            lifetime: _json.lifetime,
            
            xspeed_on_collision: _xspeed_on_collision,
            yspeed_on_collision: _yspeed_on_collision,
            
            animation_speed: _json[$ "animation_speed"] ?? 1,
            
            sprite_xoffset: _sprite_xoffset,
            sprite_yoffset: _sprite_yoffset,
            
            bbox_left: _bbox_left,
            bbox_top: _bbox_top,
            bbox_right: _bbox_right,
            bbox_bottom: _bbox_bottom,
        }
        */
        delete _json;
        
        dbg_timer("init_particle", $"[Init] Loaded Particle: \'{_file}\'");
    }
}