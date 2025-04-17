global.biome_data = {}

function init_biome(_directory, _namespace = "phantasia", _type = 0)
{
    #region Cave
    
    var _files_cave = file_read_directory($"{_directory}/cave");
    var _files_cave_length = array_length(_files_cave);
    
    for (var i = 0; i < _files_cave_length; ++i)
    {
        var _file = _files_cave[i];
        
        dbg_timer("init_data_biome_surface");
        
        var _json = buffer_load_json($"{_directory}/cave/{_file}");
        
        _file = string_delete(_file, string_length(_file) - 4, 5);
        
        var _biome_data = new BiomeData(_file, BIOME_TYPE.CAVE);
        
        _biome_data.set_sky_colour(_json.sky_colour);
        _biome_data.set_light_colour(_json.light_colour);
        
        _biome_data.set_tile(_json.tile);
        
        var _foliage = _json.foliage;
        
        _biome_data.set_tile_foliage(_foliage.chance, _foliage.tile);
        
        global.biome_data[$ $"{_namespace}:{_file}"] = _biome_data;
        
        delete _json;
        
        dbg_timer("init_data_biome_surface", $"[Init] Loaded Surface Biome: \'{_file}\'");
    }
    
    #endregion
    
    #region Surface
    
    var _files_surface = file_read_directory($"{_directory}/surface");
    var _files_surface_length = array_length(_files_surface);
    
    for (var i = 0; i < _files_surface_length; ++i)
    {
        var _file = _files_surface[i];
        
        dbg_timer("init_data_biome_surface");
        
        var _json = buffer_load_json($"{_directory}/surface/{_file}");
        
        _file = string_delete(_file, string_length(_file) - 4, 5);
        
        var _biome_data = new BiomeData(_file, BIOME_TYPE.SURFACE);
        
        _biome_data.set_map_colour(_json.map_colour);
        _biome_data.set_sky_colour(_json.sky_colour);
        _biome_data.set_light_colour(_json.light_colour);
        
        var _tile = _json.tile;
        
        _biome_data.set_tile_top_layer(_tile.top_layer);
        _biome_data.set_tile_sub_layer(_tile.sub_layer);
        
        var _foliage = _json.foliage;
        
        _biome_data.set_tile_foliage(_foliage.chance, _foliage.tile);
        
        global.biome_data[$ $"{_namespace}:{_file}"] = _biome_data;
        
        delete _json;
        
        dbg_timer("init_data_biome_surface", $"[Init] Loaded Surface Biome: \'{_file}\'");
    }
    
    #endregion
}