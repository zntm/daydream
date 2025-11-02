global.biome_data = {}

function init_biome_recursive(_directory, _namespace = "phantasia", _id = undefined)
{
    var _files = file_read_directory(_directory);
    var _files_length = array_length(_files);
    
    for (var i = 0; i < _files_length; ++i)
    {
        var _file = _files[i];
        var _subdirectory = $"{_directory}/{_file}";
        
        var _name = ((_id == undefined) ? _file : $"{_id}/{_file}");
        
        if (directory_exists(_subdirectory))
        {
            init_biome_recursive(_subdirectory, _namespace, _name);
            
            continue;
        }
        
        dbg_timer("init_biome");
        
        var _json = tag_value_parse(buffer_load_json(_subdirectory));
        
        var _id2 = string_delete(_file, string_length(_file) - 4, 5);
        
        var _biome_data = new BiomeData(_namespace, _name);
        
        _biome_data.set_background(_json.background);
        
        _biome_data.set_map_colour(_json.map_colour);
        _biome_data.set_sky_colour(_json.sky_colour);
        _biome_data.set_light_colour(_json.light_colour);
        
        var _music = _json[$ "music"];
        
        if (_music != undefined)
        {
            _biome_data.set_music(_music);
        }
        
        var _tile = _json.tile;
        
        _biome_data.set_tile_top_layer(_tile.top_layer);
        _biome_data.set_tile_middle_layer(_tile.middle_layer);
        _biome_data.set_tile_middle_layer(_tile.bottom_layer);
        
        _biome_data.set_tile_foliage(_json.foliage);
        
        _biome_data.set_creature(_json[$ "creatures"]);
        
        _biome_data.set_structure(_json[$ "structures"]);
        
        var _name2 = string_delete(_name, string_length(_name) - 4, 5);
        
        global.biome_data[$ $"{_namespace}:{_name2}"] = _biome_data;
        
        delete _json;
        
        dbg_timer("init_biome", $"[Init] Loaded Biome: \'{_name2}\'");
    }
}