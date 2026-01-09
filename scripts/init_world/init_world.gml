#macro WORLDGEN_SIZE_HEAT_BIT 6
#macro WORLDGEN_SIZE_HEAT (1 << WORLDGEN_SIZE_HEAT_BIT)

#macro WORLDGEN_SIZE_HUMIDITY_BIT 6
#macro WORLDGEN_SIZE_HUMIDITY (1 << WORLDGEN_SIZE_HUMIDITY_BIT)

global.world_data = {}

// Region-based world generation system
// Initialized with defaults, can be overridden by world config
global.region_generator = new RegionGenerator({
    cell_size: 256,
    warp_scale: 0.008,
    warp_power: 48
}).set_regions(region_create_defaults());

// Density-based terrain generator
// Overhauls terrain shaping to support 3D features (overhangs, floating islands)
global.terrain_generator = new TerrainGenerator({
    base_surface_y: 400,
    noise_scale: 0.02,
    gradient_strength: 0.015
});

// TerrainShaper for 3D noise-based terrain with overhangs
// Will be re-initialized per world in init_world with world-specific settings
global.terrain_shaper = undefined; // Initialized per world

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
        _world_data.set_surface(_surface);
        
        var _cave = _json.cave;
        _world_data.set_cave(_cave);
        
        // Parse terrain shaping configuration (new 3D density system)
        var _terrain_shaping = _json[$ "terrain_shaping"];
        if (_terrain_shaping != undefined)
        {
            _world_data.set_terrain_shaping(_terrain_shaping);
        }
        else
        {
            // Apply defaults
            _world_data.set_terrain_shaping({});
        }
        
        global.world_data[$ $"{_namespace}:{_id}"] = _world_data;
        
        // Initialize terrain_shaper with the first loaded world's data
        if (global.terrain_shaper == undefined)
        {
            global.terrain_shaper = new TerrainShaper(_world_data);
        }
        
        delete _json;
        
        dbg_timer("init_world", $"[Init] Loaded World: \'{_id}\'");
    }
}