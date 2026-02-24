#macro WEATHER_RAIN_PARTICLES_PER_LIGHT 1
#macro WEATHER_LIGHTNING_INTERVAL_MIN   3.0
#macro WEATHER_LIGHTNING_INTERVAL_MAX   8.0

/// @desc Manages rain particles near light sources and lightning bolt spawning.
/// @param {Real} _dt Delta time.
/// @param {Real} _camera_x Camera X.
/// @param {Real} _camera_y Camera Y.
/// @param {Real} _camera_w Camera width.
/// @param {Real} _camera_h Camera height.
function control_weather(_dt, _camera_x, _camera_y, _camera_w, _camera_h)
{
    var _storm = global.current_world.weather.storm;
    
    if (_storm <= 0) exit;
    
    var _wind     = global.current_world.weather.wind;
    var _strength = global.settings.display_strength_weather;
    
    /* --- rain particles near light sources --- */
    var _rain_count = ceil(WEATHER_RAIN_PARTICLES_PER_LIGHT * _storm * _strength);
    
    /* sparse background rain */
    var _bg_rain_count = ceil(2 * _storm * _strength);
    
    repeat (_bg_rain_count)
    {
        var _px = _camera_x + random(_camera_w);
        var _py = _camera_y + random(_camera_h);
        
        spawn_particle(_px, _py, "phantasia:weather/raindrop");
    }
    
    /* --- rain particles near entities --- */
    var _player_rain_count = ceil(2 * _storm * _strength);
    var _creature_rain_count = ceil(1 * _storm * _strength);
    var _item_rain_count = ceil(1 * _storm * _strength);
    
    with (obj_Player)
    {
        if (x < _camera_x - TILE_SIZE * 4) || (x > _camera_x + _camera_w + TILE_SIZE * 4)
            || (y < _camera_y - TILE_SIZE * 4) || (y > _camera_y + _camera_h + TILE_SIZE * 4) continue;
        
        repeat (_player_rain_count)
        {
            var _px = x + random_range(-TILE_SIZE * 2, TILE_SIZE * 2);
            var _py = y + random_range(-TILE_SIZE * 3, TILE_SIZE);
            
            spawn_particle(_px, _py, "phantasia:weather/raindrop");
        }
    }
    
    with (obj_Creature)
    {
        if (x < _camera_x - TILE_SIZE * 4) || (x > _camera_x + _camera_w + TILE_SIZE * 4)
            || (y < _camera_y - TILE_SIZE * 4) || (y > _camera_y + _camera_h + TILE_SIZE * 4) continue;
        
        repeat (_creature_rain_count)
        {
            var _px = x + random_range(-TILE_SIZE * 2, TILE_SIZE * 2);
            var _py = y + random_range(-TILE_SIZE * 3, TILE_SIZE);
            
            spawn_particle(_px, _py, "phantasia:weather/raindrop");
        }
    }
    
    with (obj_Item_Drop)
    {
        if (x < _camera_x - TILE_SIZE * 4) || (x > _camera_x + _camera_w + TILE_SIZE * 4)
            || (y < _camera_y - TILE_SIZE * 4) || (y > _camera_y + _camera_h + TILE_SIZE * 4) continue;
        
        repeat (_item_rain_count)
        {
            var _px = x + random_range(-TILE_SIZE, TILE_SIZE);
            var _py = y + random_range(-TILE_SIZE, TILE_SIZE);
            
            spawn_particle(_px, _py, "phantasia:weather/raindrop");
        }
    }
    
    for (var i = chunk_in_view_length - 1; i >= 0; --i)
    {
        var _c = chunk_in_view[i];
        
        if (_c == undefined) || !(_c.boolean & CHUNK_BOOLEAN.GENERATED) continue;
        
        var _lights        = _c.chunk_lights;
        var _lights_length = array_length(_lights);
        
        for (var j = _lights_length - 1; j >= 0; --j)
        {
            var _light = _lights[j];
            
            /* cull lights outside camera view */
            if (_light.x < _camera_x - TILE_SIZE * 4) || (_light.x > _camera_x + _camera_w + TILE_SIZE * 4)
                || (_light.y < _camera_y - TILE_SIZE * 4) || (_light.y > _camera_y + _camera_h + TILE_SIZE * 4) continue;
            
            repeat (_rain_count)
            {
                var _px = _light.x + random_range(-TILE_SIZE * 3, TILE_SIZE * 3);
                var _py = _light.y + random_range(-TILE_SIZE * 4, -TILE_SIZE);
                
                spawn_particle(_px, _py, "phantasia:weather/raindrop");
            }
        }
    }
    
    /* --- lightning spawning --- */
    static __timer_lightning = 0;
    
    __timer_lightning -= _dt;
    
    if (__timer_lightning <= 0)
    {
        __timer_lightning = random_range(
            WEATHER_LIGHTNING_INTERVAL_MIN / _storm,
            WEATHER_LIGHTNING_INTERVAL_MAX / _storm
        );
        
        /* spawn bolt at random high position within camera view */
        var _lx = _camera_x + random(_camera_w);
        var _ly = _camera_y - TILE_SIZE * 2;
        
        global.lightning_pool.spawn(_lx, _ly);
    }
    
    /* update lightning state machine */
    global.lightning_pool.update(_dt);
}
