#macro WORLDGEN_SIZE_HEAT_BIT 6
#macro WORLDGEN_SIZE_HEAT (1 << WORLDGEN_SIZE_HEAT_BIT)

#macro WORLDGEN_SIZE_HUMIDITY_BIT 6
#macro WORLDGEN_SIZE_HUMIDITY (1 << WORLDGEN_SIZE_HUMIDITY_BIT)

global.world_data = {}

function init_world(_directory, _namespace = "phantasia", _type = 0)
{
    static __biome_map_buffer = -1;
    static __biome_map_surface = -1;
    
    if (!buffer_exists(__biome_map_buffer))
    {
        __biome_map_buffer = buffer_create(WORLDGEN_SIZE_HUMIDITY * WORLDGEN_SIZE_HEAT * 4, buffer_fixed, 1);
    }
    
    if (!surface_exists(__biome_map_surface))
    {
        __biome_map_surface = surface_create(WORLDGEN_SIZE_HUMIDITY, WORLDGEN_SIZE_HEAT);
    }
    
    var _biome_data = global.biome_data;
    
    var _names = struct_get_names(_biome_data);
    var _names_length = array_length(_names);
     
    var _files = file_read_directory(_directory);
    var _files_length = array_length(_files);
    
    for (var i = 0; i < _files_length; ++i)
    {
        var _file = _files[i];
        
        dbg_timer("init_world");
        
        var _json = json_parse(buffer_load_text($"{_directory}/{_file}/data.json"));
        
        var _world_data = new WorldData(_json.world_height);
        
        var _vignette = _json.vignette;
        
        _world_data.set_vignette(_vignette.start, _vignette[$ "end"], _vignette.colour);
        
        var _time = _json.time;
        
        _world_data.set_time(_time.length, _time.diurnal);
        
        var _celestial = {}
        
        var _files_celestial = file_read_directory($"{_directory}/{_file}/celestial");
        var _files_celestial_length = array_length(_files_celestial);
        
        for (var j = 0; j < _files_celestial_length; ++j)
        {
            var _file_celestial = _files_celestial[j];
            
            var _sprite = sprite_add($"{_directory}/{_file}/celestial/{_file_celestial}", 1, false, false, 0, 0);
            
            sprite_set_offset(_sprite, round(sprite_get_width(_sprite) / 2), sprite_get_height(_sprite) / 2);
            
            _celestial[$ string_delete(_file_celestial, string_length(_file_celestial) - 3, 4)] = _sprite;
        }
        
        _world_data.set_celestial(_celestial, _json[$ "celestial"]);
        
        var _biome = _json.biome;
        
        _world_data.set_cave_biome(_biome.cave);
        _world_data.set_surface_biome(_biome.surface);
        
        var _surface = _json.surface;
        
        _world_data.set_surface(_surface.start, _surface.offset);
        
        var _cave = _json.cave;
        
        _world_data.set_cave(_cave.start, _cave.system);
        
        #region Biome Map
        
        var _sprite = sprite_add($"{_directory}/{_file}/map.png", 1, false, false, 0, 0);
        
        surface_set_target(__biome_map_surface);
        
        draw_sprite(_sprite, 0, 0, 0);
        
        surface_reset_target();
        
        buffer_get_surface(__biome_map_buffer, __biome_map_surface, 0);
        
        var _surface_biome_map = array_create(WORLDGEN_SIZE_HUMIDITY * WORLDGEN_SIZE_HEAT, 0);
        
        for (var j = 0; j < _names_length; ++j)
        {
            var _name = _names[j];
            
            var _map_colour = _biome_data[$ _name].get_map_colour();
            
            if (_map_colour == undefined) continue;
            
            buffer_seek(__biome_map_buffer, buffer_seek_start, 0);
            
            for (var l = 0; l < WORLDGEN_SIZE_HUMIDITY; ++l)
            {
                var _index_humidity = l << WORLDGEN_SIZE_HEAT_BIT;
                
                for (var m = 0; m < WORLDGEN_SIZE_HEAT; ++m)
                {
                    var _colour = buffer_read(__biome_map_buffer, buffer_u32) & 0xffffff;
                    
                    if (_map_colour == _colour)
                    {
                        _surface_biome_map[@ _index_humidity | m] = _name;
                    }
                }
            }
        }
        
        buffer_delete(__biome_map_buffer);
        
        _world_data.set_surface_biome_map(_surface_biome_map);
        
        #endregion
        
        global.world_data[$ $"{_namespace}:{_file}"] = _world_data;
        
        delete _json;
        
        dbg_timer("init_world", $"[Init] Loaded World: \'{_file}\'");
    }
}