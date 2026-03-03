global.effect_data = {}
global.effect_data_names = []

/// @function init_effect(_directory, _namespace)
/// @desc Load effect data from generated JSON files
/// @param {String} _directory - Directory containing effect JSON files
/// @param {String} _namespace - Effect namespace (e.g., "phantasia")
function init_effect(_directory, _namespace)
{
    var _files = file_read_directory(_directory);
    var _files_length = array_length(_files);
    
    for (var i = 0; i < _files_length; ++i)
    {
        var _file = _files[i];
        
        if (string_ends_with(_file, ".json"))
        {
            dbg_timer("init_effect0");
            
            var _json = tag_value_parse(buffer_load_json($"{_directory}/{_file}"));
            
            if (is_struct(_json))
            {
                var _id = string_delete(_file, string_length(_file) - 4, 5);
                var _effect_data = new EffectData(_namespace, _id);
                
                _effect_data
                    .set_icon(_json[$ "icon"])
                    .set_type(_json[$ "type"])
                    .set_attribute(_json[$ "attribute"])
                    .set_base_value(_json[$ "base_value"])
                    .set_is_negative(_json[$ "is_negative"])
                    .set_modifiers(_json[$ "modifiers"])
                    .set_min_value(_json[$ "min_value"])
                    .set_max_value(_json[$ "max_value"])
                    .set_particle(_json[$ "particle"])
                    .set_on_effect(_json[$ "on_effect"])
                    .set_on_death(_json[$ "on_death"])
                    .set_on_heal(_json[$ "on_heal"])
                    .set_on_damage(_json[$ "on_damage"])
                    .set_on_interval(_json[$ "on_interval"])
                    .set_on_chance(_json[$ "on_chance"])
                    .set_on_end(_json[$ "on_end"]);
                
                var _full_id = $"{_namespace}:{_id}";
        
                show_debug_message($"[init_effect] Loading effect: {_full_id} from {_file}");
                
                global.effect_data[$ _full_id] = _effect_data;
                array_push(global.effect_data_names, _full_id);
                
                delete _json;
                
                dbg_timer("init_effect", $"[Init] Loaded Effect: '{_id}'");
            }
        }
    }
}
