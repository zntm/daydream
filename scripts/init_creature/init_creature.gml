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
    
    var _files = file_read_directory(_directory);
    var _files_length = array_length(_files);
    
    for (var i = 0; i < _files_length; ++i)
    {
        var _file = _files[i];
        
        if (string_ends_with(_file, ".json"))
        {
            dbg_timer("init_creature");
            
            var _json = buffer_load_json($"{_directory}/{_file}");
            
            if (is_struct(_json))
            {
                var _id = string_delete(_file, string_length(_file) - 4, 5);
                
                var _data = new CreatureData(_namespace, _id, _json.hp, __hostility_type[$ _json.hostility_type], __movement_type[$ _json.movement_type]);
                
                _data.set_sprite(_json.sprite);
                
                var _attribute = _json.attribute;
                
                _data.set_attribute(new Attribute()
                    .set_boolean(_attribute[$ "boolean"])
                    .set_collision_box(_attribute[$ "collision_box_width"], _attribute[$ "collision_box_height"])
                    .set_hit_box(_attribute[$ "hit_box_width"], _attribute[$ "hit_box_height"])
                    .set_eye_level(_attribute[$ "eye_level"])
                    .set_gravity(_attribute[$ "gravity"])
                    .set_jump_count_max(_attribute[$ "jump_count_max"])
                    .set_jump_falloff(_attribute[$ "jump_falloff"])
                    .set_jump_height(_attribute[$ "jump_height"])
                    .set_jump_time(_attribute[$ "jump_time"])
                    .set_movement_speed(_attribute[$ "movement_speed"])
                    .set_regeneration_amount(_attribute[$ "regeneration_amount"])
                    .set_regeneration_time(_attribute[$ "regeneration_time"])
                );
                
                _data.set_drops(_json[$ "drops"]);
                _data.set_properties(_json[$ "properties"]);
                _data.set_contact_damage(_json[$ "contact_damage"]);
                _data.set_predators(_json[$ "predators"]);
                global.creature_data[$ $"{_namespace}:{_id}"] = _data;
                
                dbg_timer("init_creature", $"[Init] Loaded Creature: '{_file}'");
                
                delete _json;
            }
        }
    }
}
