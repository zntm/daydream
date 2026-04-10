#macro WORLDGEN_SIZE_HEAT_BIT 6
#macro WORLDGEN_SIZE_HEAT (1 << WORLDGEN_SIZE_HEAT_BIT)

#macro WORLDGEN_SIZE_HUMIDITY_BIT 6
#macro WORLDGEN_SIZE_HUMIDITY (1 << WORLDGEN_SIZE_HUMIDITY_BIT)

global.world_data = {}

/// @desc Load world data files recursively
/// @param {String} _directory Directory to search
/// @param {String} _namespace Namespace for IDs (default "phantasia")
/// @param {String} [_path_id] Internal tracking for nested folder IDs
function init_world(_namespace = "phantasia", _directory)
{
    var _files = file_read_directory(_directory, true);
    var _files_length = array_length(_files);
    
    for (var i = 0; i < _files_length; ++i)
    {
        var _file = _files[i];
        var _sub_path = $"{_directory}/{_file}";
        
        if (directory_exists(_sub_path)) continue;
        
        if (string_ends_with(_file, ".json"))
        {
            dbg_timer("init_world");
            
            var _json = tag_value_parse(buffer_load_json(_sub_path));
            if (!init_data_namespace_allowed(_json, _file)) continue;
            
            if (is_struct(_json))
            {
                var _name_clean = string_delete(_file, string_length(_file) - 4, 5);
                
                // Use internal ID if provided, otherwise fallback to namespaced filename
                // Example: "playground" -> "phantasia:playground"
                var _internal_id = _json[$ "id"] ?? _name_clean;
                var _full_id = (string_pos(":", _internal_id) > 0) ? _internal_id : $"{_namespace}:{_internal_id}";
                
                var _world_data = new WorldData(_namespace, _full_id, _json[$ "world_height"]);
                
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
                
                var _colorgrade = _json[$ "colorgrade"];
                if (_colorgrade != undefined)
                {
                    _world_data.set_colorgrade(_colorgrade);
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
                
                global.world_data[$ _full_id] = _world_data;
                
                dbg_timer("init_world", $"[Init] Loaded World: \'{_full_id}\'");
                
                delete _json;
            }
        }
    }
}
