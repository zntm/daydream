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
        
        if (string_ends_with(_file, ".json"))
        {
            dbg_timer("init_world");
            
            var _json = tag_value_parse(buffer_load_json($"{_directory}/{_file}"));
            
            if (is_struct(_json))
            {
                var _id = string_delete(_file, string_length(_file) - 4, 5);
                
                var _world_data = new WorldData(_namespace, _id, _json[$ "world_height"]);
                
                _world_data.set_spawn_interval(_json[$ "spawn_interval"]);
                _world_data.set_biome_transition_smoothing(_json[$ "biome_transition_smoothing"] ?? 0.5);
                
                var _vignette = _json[$ "vignette"];
                if (_vignette != undefined)
                {
                    _world_data.set_vignette(_vignette.ystart, _vignette.yend, _vignette.colour);
                }
                
                _world_data.set_time(_json[$ "time"]);
                
                var _celestials = _json[$ "celestials"];
                if (_celestials != undefined)
                {
                    var _c = [];
                    var _celestials_length = array_length(_celestials);
                    
                    for (var j = 0; j < _celestials_length; ++j)
                    {
                        var _celestial = _celestials[j];
                        
                        _c[@ j] = new WorldCelestial(_celestial.id, _celestial.time_range_min, _celestial.time_range_max);
                    }
                    
                    _world_data.set_celestials(_c);
                }
                
                var _biome = _json[$ "biome"];
                if (_biome != undefined)
                {
                    _world_data.set_cave_biome(_biome.cave);
                    _world_data.set_surface_biome(_biome.surface);
                    
                    // Set surface biome map if provided
                    if (struct_exists(_biome.surface, "map"))
                    {
                        _world_data.set_surface_biome_map(_biome.surface.map);
                    }

                    // Parse sky biome configuration (optional)
                    var _sky_biome = _biome[$ "sky"];
                    if (_sky_biome != undefined)
                    {
                        _world_data.set_sky_biome(_sky_biome);
                    }
                }
                
                var _regions = _json[$ "regions"];
                if (_regions != undefined)
                {
                    _world_data.set_regions(_regions);
                }

                var _background = _json[$ "background"];
                if (_background != undefined)
                {
                    _world_data.set_background(_background);
                }
                
                var _surface = _json[$ "surface"];
                if (_surface != undefined)
                {
                    _world_data.set_surface(_surface);
                }
                
                var _cave = _json[$ "cave"];
                if (_cave != undefined)
                {
                    _world_data.set_cave(_cave);
                }
                
                global.world_data[$ $"{_namespace}:{_id}"] = _world_data;
                
                delete _json;
                
                dbg_timer("init_world", $"[Init] Loaded World: \'{_id}\'");
            }
        }
    }
}