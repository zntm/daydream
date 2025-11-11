#macro WORLDGEN_SIZE_HEAT_BIT 6
#macro WORLDGEN_SIZE_HEAT (1 << WORLDGEN_SIZE_HEAT_BIT)

#macro WORLDGEN_SIZE_HUMIDITY_BIT 6
#macro WORLDGEN_SIZE_HUMIDITY (1 << WORLDGEN_SIZE_HUMIDITY_BIT)

global.world_data = {}

function init_world(_directory, _namespace = "phantasia", _type = 0)
{
    var _biome_data = global.biome_data;
    
    var _names = struct_get_names(_biome_data);
    var _names_length = array_length(_names);
     
    var _files = file_read_directory(_directory);
    var _files_length = array_length(_files);
    
    for (var i = 0; i < _files_length; ++i)
    {
        var _file = _files[i];
        
        dbg_timer("init_world");
        
        var _json = tag_value_parse(buffer_load_json($"{_directory}/{_file}"));
        
        var _id = string_delete(_file, string_length(_file) - 4, 5);
        
        var _world_data = new WorldData(_namespace, _id, _json.world_height);
        
        _world_data.set_spawn_interval(_json.spawn_interval);
        
        var _vignette = _json.vignette;
        _world_data.set_vignette(_vignette.ystart, _vignette.yend, _vignette.colour);
        
        _world_data.set_time(_json.time);
        
        var _c = [];
        
        var _celestials = _json.celestials;
        var _celestials_length = array_length(_celestials);
        
        for (var j = 0; j < _celestials_length; ++j)
        {
            var _celestial = _celestials[j];
            
            _c[@ j] = new WorldCelestial(_celestial.id, _celestial.time_range_min, _celestial.time_range_max);
        }
        
        _world_data.set_celestials(_c);
        
        var _biome = _json.biome;
        
        _world_data.set_cave_biome(_biome.cave);
        _world_data.set_surface_biome(_biome.surface);
        
        var _surface = _json.surface;
        _world_data.set_surface(_surface.start, _surface.noise_offset);
        
        var _cave = _json.cave;
        _world_data.set_cave(_cave.start, _cave.system);
        
        global.world_data[$ $"{_namespace}:{_id}"] = _world_data;
        
        delete _json;
        
        dbg_timer("init_world", $"[Init] Loaded World: \'{_id}\'");
    }
}