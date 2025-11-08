function WorldCelestial(_id, _time_range_min, _time_range_max) constructor
{
    ___id = _id;
    ___time_range_min = _time_range_min;
    ___time_range_max = _time_range_max;
    
    static get_id = function()
    {
        return ___id;
    }
    
    static get_time_range_min = function()
    {
        return ___time_range_min;
    }
    
    static get_time_range_max = function()
    {
        return ___time_range_max;
    }
}

function WorldData(_namespace, _id, _world_height) : ParentData(_namespace, _id) constructor
{
    ___world_height = _world_height;
    
    static get_world_height = function()
    {
        return ___world_height;
    }
    
    static set_spawn_interval = function(_interval)
    {
        ___spawn_interval = _interval;
        
        return self;
    }
    
    static get_spawn_interval = function()
    {
        return ___spawn_interval;
    }
    
    static set_vignette = function(_ystart, _yend, _colour)
    {
        ___vignette_ystart = _ystart;
        ___vignette_yend = _yend;
        ___vignette_colour = _colour;
        
        return self;
    }
    
    static get_vignette_ystart = function()
    {
        return ___vignette_ystart;
    }
    
    static get_vignette_yend = function()
    {
        return ___vignette_yend;
    }
    
    static get_vignette_colour = function()
    {
        return ___vignette_colour;
    }
    
    static set_time = function(_time)
    {
        ___time_start = _time.start;
        ___time_diurnal = _time.diurnal;
        
        return self;
    }
    
    static get_time_start = function()
    {
        return ___time_start;
    }
    
    static get_time_diurnal = function()
    {
        return ___time_diurnal;
    }
    
    static set_celestial = function(_celestial)
    {
        ___celestial = _celestial;
        
        return self;
    }
    
    static get_celestial = function()
    {
        return ___celestial;
    }
    
    static set_cave_biome = function(_cave_biome)
    {
        ___cave_biome = _cave_biome;
        
        return self;
    }
    
    static get_cave_biome = function()
    {
        return ___cave_biome;
    }
    
    static set_surface_biome = function(_surface_biome)
    {
        ___surface_biome = _surface_biome;
        
        return self;
    }
    
    static get_surface_biome = function()
    {
        return ___surface_biome;
    }
    
    static set_surface = function(_start, _noise_offset)
    {
        ___surface_start = _start;
        ___surface_noise_offset = _noise_offset;
        
        return self;
    }
    
    static get_surface_start = function()
    {
        return ___surface_start;
    }
    
    static get_surface_noise_offset = function()
    {
        return ___surface_noise_offset;
    }
    
    static set_cave = function(_start, _system)
    {
        ___cave_start = _start;
        ___cave_system = _system;
        
        return self;
    }
    
    static get_cave_start = function()
    {
        return ___cave_start;
    }
    
    static get_cave_system = function()
    {
        return ___cave_system;
    }
    
    static set_surface_biome_map = function(_map)
    {
        ___surface_biome_map = _map;
        
        return self;
    }
    
    static get_surface_biome_map = function()
    {
        return ___surface_biome_map;
    }
}