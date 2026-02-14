/// @desc Cloud system - manages a pool of cloud instances for sky rendering
/// Clouds are spawned via a proglang sky script and updated/drawn by GML each frame.

#macro CLOUD_POOL_MAX 32

function CloudInstance() constructor
{
    x = 0;
    y = 0;
    scale = 1;
    alpha = 1;
    speed = 8;
    sprite_id = "";
    sprite_sub = 0;
    tint = c_white;
    active = false;
}

// Global cloud state
global.cloud_pool = [];
global.cloud_pool_count = 0;
global.cloud_tint = c_white;
global.cloud_wind_factor = 2.0;
global.cloud_active_sprite_set = "";

for (var i = 0; i < CLOUD_POOL_MAX; ++i)
{
    global.cloud_pool[@ i] = new CloudInstance();
}

/// @function cloud_spawn(_sprite_id, _x, _y, _scale, _alpha, _speed)
/// @desc Spawn a cloud instance into the pool
function cloud_spawn(_sprite_id, _x, _y, _scale, _alpha, _speed)
{
    if (global.cloud_pool_count >= CLOUD_POOL_MAX) return -1;
    
    for (var i = 0; i < CLOUD_POOL_MAX; ++i)
    {
        var _cloud = global.cloud_pool[i];
        
        if (!_cloud.active)
        {
            _cloud.active = true;
            _cloud.sprite_id = _sprite_id;
            _cloud.x = _x;
            _cloud.y = _y;
            _cloud.scale = _scale;
            _cloud.alpha = _alpha;
            _cloud.speed = _speed;
            _cloud.tint = global.cloud_tint;
            
            show_debug_message($"[Clouds] Spawned at {_x}, {_y} with sprite {_sprite_id}");
            
            // Pick a random sub-image from the sprite set if it's an array
            var _sprite_data = global.sprite_asset[$ _sprite_id];
            if (is_array(_sprite_data))
            {
                _cloud.sprite_sub = irandom(array_length(_sprite_data) - 1);
            }
            else if (_sprite_data != undefined)
            {
                // Single sprite might still have multiple sub-images in GML
                var _spr = _sprite_data.get_sprite();
                if (_spr != -1) _cloud.sprite_sub = irandom(sprite_get_number(_spr) - 1);
            }
            else
            {
                _cloud.sprite_sub = 0;
            }
            
            ++global.cloud_pool_count;
            
            return i;
        }
    }
    
    return -1;
}

/// @function cloud_clear()
/// @desc Clear all cloud instances
function cloud_clear()
{
    for (var i = 0; i < CLOUD_POOL_MAX; ++i)
    {
        global.cloud_pool[i].active = false;
    }
    
    global.cloud_pool_count = 0;
}

/// @function cloud_set_tint(_colour)
/// @desc Set the tint colour for all clouds
function cloud_set_tint(_colour)
{
    global.cloud_tint = is_string(_colour) ? hex_parse(_colour) : _colour;
    
    for (var i = 0; i < CLOUD_POOL_MAX; ++i)
    {
        if (global.cloud_pool[i].active)
        {
            global.cloud_pool[i].tint = global.cloud_tint;
        }
    }
}

/// @function cloud_set_wind_factor(_factor)
/// @desc Set the wind influence multiplier for clouds
function cloud_set_wind_factor(_factor)
{
    global.cloud_wind_factor = _factor;
}

/// @function cloud_set_sprites(_sprite_set_id)
/// @desc Swap all active clouds to a different sprite set
function cloud_set_sprites(_sprite_set_id)
{
    global.cloud_active_sprite_set = _sprite_set_id;
    
    for (var i = 0; i < CLOUD_POOL_MAX; ++i)
    {
        var _cloud = global.cloud_pool[i];
        
        if (_cloud.active)
        {
            _cloud.sprite_id = _sprite_set_id;
            
            var _sprite_data = global.sprite_asset[$ _sprite_set_id];
            if (is_array(_sprite_data))
            {
                _cloud.sprite_sub = irandom(array_length(_sprite_data) - 1);
            }
        }
    }
}

/// @function cloud_set_speed(_speed)
/// @desc Override base speed for all active clouds
function cloud_set_speed(_speed)
{
    for (var i = 0; i < CLOUD_POOL_MAX; ++i)
    {
        if (global.cloud_pool[i].active)
        {
            global.cloud_pool[i].speed = _speed;
        }
    }
}

/// @function update_background_clouds(_dt, _camera_width)
/// @desc Update cloud positions (drift + wind)
function update_background_clouds(_dt, _camera_width)
{
    if (global.cloud_pool_count <= 0) return;
    
    var _wind = global.world_save_data.weather_wind;
    var _wind_factor = global.cloud_wind_factor;
    
    for (var i = 0; i < CLOUD_POOL_MAX; ++i)
    {
        var _cloud = global.cloud_pool[i];
        
        if (!_cloud.active) continue;
        
        // Get sprite width for wrapping
        var _sprite_width = 64; // Default fallback
        var _sprite_data = global.sprite_asset[$ _cloud.sprite_id];
        if (_sprite_data != undefined)
        {
            var _spr = _sprite_data.get_sprite();
            if (_spr != -1) _sprite_width = sprite_get_width(_spr) * _cloud.scale;
        }
        
        // Drift horizontally
        _cloud.x += (_cloud.speed + _wind * _wind_factor) * _dt;
        
        // Wrap around screen
        if (_cloud.x > _camera_width + _sprite_width)
        {
            _cloud.x = -_sprite_width;
        }
        else if (_cloud.x < -_sprite_width)
        {
            _cloud.x = _camera_width + _sprite_width;
        }
    }
}

/// @function render_background_clouds(_camera_x, _camera_y, _camera_width, _camera_height)
/// @desc Draw all active cloud instances
function render_background_clouds(_camera_x, _camera_y, _camera_width, _camera_height)
{
    if (global.cloud_pool_count <= 0) return;
    
    for (var i = 0; i < CLOUD_POOL_MAX; ++i)
    {
        var _cloud = global.cloud_pool[i];
        
        if (!_cloud.active) continue;
        
        var _sprite_data = global.sprite_asset[$ _cloud.sprite_id];
        if (_sprite_data == undefined) continue;
        
        var _spr = _sprite_data.get_sprite();
        if (_spr != -1)
        {
            var _draw_x = _camera_x + _cloud.x;
            var _draw_y = _camera_y + _cloud.y;
            
            // Only log once every 60 frames to avoid spam, or if it's the first few frames
            if (global.time % 60 == 0)
            {
                show_debug_message($"[Clouds] Drawing cloud {i} at world ({_draw_x}, {_draw_y}), screen ({_cloud.x}, {_cloud.y}), scale {_cloud.scale}, alpha {_cloud.alpha}");
            }
            
            draw_sprite_ext(
                _spr, _cloud.sprite_sub,
                _draw_x,
                _draw_y,
                _cloud.scale, _cloud.scale,
                0,
                _cloud.tint,
                _cloud.alpha
            );
        }
    }
}

/// @function init_background_clouds()
/// @desc Initialize cloud system by calling the world's sky script via proglang
function init_background_clouds()
{
    cloud_clear();
    
    var _world_data = global.world_data[$ global.world_save_data.dimension];
    if (_world_data == undefined) return;
    
    var _script_id = _world_data.get_sky_objects_script();
    if (_script_id == undefined) return;
    
    var _sprites = _world_data.get_sky_objects_sprites();
    var _config = _world_data.get_sky_objects_config();
    
    // Set wind factor from config
    global.cloud_wind_factor = _config[$ "wind_factor"] ?? 2.0;
    
    // Set the default sprite set
    if (array_length(_sprites) > 0)
    {
        global.cloud_active_sprite_set = _sprites[0];
    }
    
    // Call the sky script with context
    var _camera_width = global.camera_width;
    var _camera_height = global.camera_height;
    
    var _context = {
        camera_width: _camera_width,
        camera_height: _camera_height,
    };
    
    var _parameter = {
        sprites: _sprites,
        config: _config,
        camera_width: _camera_width,
        camera_height: _camera_height,
    };
    
    show_debug_message($"[Clouds] init_background_clouds starting. Script: {_script_id}");
    if (struct_exists(global.proglang_scripts, _script_id))
    {
        proglang_call(_script_id, [_parameter], _context);
        show_debug_message($"[Clouds] Script called successfully. Active clouds: {global.cloud_pool_count}");
    }
    else
    {
        show_debug_message($"[Clouds] Sky script NOT found in global.proglang_scripts: '{_script_id}'");
        var _keys = struct_get_names(global.proglang_scripts);
        show_debug_message($"[Clouds] Available scripts: {string(_keys)}");
    }
}
