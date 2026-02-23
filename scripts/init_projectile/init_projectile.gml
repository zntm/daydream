global.projectile_data = {}

/// @desc Recursively load all projectile definitions from a directory tree of JSON files.
/// @param {String} _directory  Path to the projectile JSON directory.
/// @param {String} [_namespace] Namespace prefix for IDs.
/// @param {String} [_id] Current subdirectory path segment (used in recursion).
function init_projectile(_directory, _namespace = "phantasia", _id = undefined)
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
                init_projectile(_subdirectory, _namespace, _name);
            }
            
            continue;
        }
        
        if (!string_ends_with(_file, ".json")) continue;
        
        dbg_timer("init_projectile");
        
        var _json = buffer_load_json(_subdirectory);
        
        if (!is_struct(_json)) continue;
        
        /* strip '.json' from name to get the id */
        var _data_id = string_delete(_name, string_length(_name) - 4, 5);
        
        var _data = new ProjectileData(_namespace, _data_id, _json[$ "sprite"]);
        
        /* boolean properties */
        _data.set_boolean(projectile_parse_properties(_json[$ "properties"]));
        
        /* lifetime */
        var _lifetime = _json[$ "lifetime"];
        if (_lifetime != undefined) _data.set_lifetime(smart_value_parse(_lifetime));
        
        /* physics */
        var _physics = _json[$ "physics"];
        
        if (_physics != undefined)
        {
            _data.set_speed(smart_value_parse(_physics[$ "xspeed"] ?? 0));
            _data.set_speed_y(smart_value_parse(_physics[$ "yspeed"] ?? 0));
            _data.set_scale(smart_value_parse(_physics[$ "scale"] ?? 1));
            
            /* rotation can be a struct { value, increment } or a plain number */
            var _rot = _physics[$ "rotation"];
            
            if (is_struct(_rot))
            {
                _data.set_rotation(smart_value_parse(_rot[$ "value"] ?? 0));
                _data.set_rotation_increment(smart_value_parse(_rot[$ "increment"] ?? 0));
            }
            else
            {
                _data.set_rotation(smart_value_parse(_rot ?? 0));
            }
            
            /* on-collision speed overrides */
            var _on_collision = _physics[$ "on_collision"];
            
            if (_on_collision != undefined)
            {
                if (_on_collision[$ "xspeed"] != undefined)
                    _data.set_on_collision_speed_x(smart_value_parse(_on_collision[$ "xspeed"]));
                    
                if (_on_collision[$ "yspeed"] != undefined)
                    _data.set_on_collision_speed_y(smart_value_parse(_on_collision[$ "yspeed"]));
            }
        }
        
        /* attribute (collision box, hit box, gravity) */
        var _attribute = _json[$ "attribute"];
        
        if (_attribute != undefined)
        {
            _data.set_attribute(new Attribute()
                .set_collision_box(_attribute[$ "collision_box_width"], _attribute[$ "collision_box_height"])
                .set_hit_box(_attribute[$ "hit_box_width"], _attribute[$ "hit_box_height"])
                .set_gravity(_attribute[$ "gravity"])
            );
            
            _data.set_gravity(_attribute[$ "gravity"] ?? 0);
        }
        
        /* particles with mode support */
        _data.set_particles(projectile_parse_particles(_json[$ "particles"]));
        
        /* proglang script hooks */
        _data.set_on_shoot(_json[$ "on_shoot"]);
        _data.set_on_tick(_json[$ "on_tick"]);
        _data.set_on_hit_entity(_json[$ "on_hit_entity"]);
        _data.set_on_hit_tile(_json[$ "on_hit_tile"]);
        _data.set_on_land(_json[$ "on_land"]);
        
        global.projectile_data[$ $"{_namespace}:{_data_id}"] = _data;
        
        dbg_timer("init_projectile", $"[Init] Loaded Projectile: '{_data_id}'");
        
        delete _json;
    }
}