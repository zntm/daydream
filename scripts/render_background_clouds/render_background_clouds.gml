/// @desc Cloud system - manages a pool of cloud instances for sky rendering
/// Clouds are spawned via a proglang sky script and updated/drawn by GML each frame.

#macro CLOUD_POOL_MAX 32

function CloudInstance() constructor
{
    active = false;
    x = 0;
    y = 0;
    scale = 1;
    alpha = 1;
    speed = 0;
    sprite_id = undefined;
    sprite_sub = 0;
    tint = c_white;
    variant_index = 0;
}

// Global cloud state
global.cloud_pool = array_create(CLOUD_POOL_MAX);
for (var i = 0; i < CLOUD_POOL_MAX; ++i)
{
    global.cloud_pool[i] = new CloudInstance();
}

global.cloud_pool_count = 0;
global.cloud_tint = c_white;
global.cloud_wind_factor = 1.0;
global.cloud_active_sprite_set = "phantasia:world/playground/cloud/default";

/// @function cloud_spawn(_sprite_id, _x, _y, _scale, _alpha, _speed)
/// @desc Spawn a cloud instance
function cloud_spawn(_sprite_id, _x, _y, _scale, _alpha, _speed)
{
    if (global.cloud_pool_count >= CLOUD_POOL_MAX) return -1;
    
    // Find first inactive slot
    var i = 0;
    for (i = 0; i < CLOUD_POOL_MAX; ++i)
    {
        if (!global.cloud_pool[i].active) break;
    }
    
    if (i >= CLOUD_POOL_MAX) return -1;
    
    var _cloud = global.cloud_pool[i];
    
    _cloud.active = true;
    _cloud.x = _x;
    _cloud.y = _y;
    _cloud.scale = _scale;
    _cloud.alpha = _alpha;
    _cloud.speed = _speed;
    _cloud.sprite_id = _sprite_id;
    _cloud.tint = global.cloud_tint;
    _cloud.variant_index = irandom(9999);
    
    // Pick a random sub-image, handling both single and array assets
    var _sprite_data = global.sprite_asset[$ _sprite_id];
    var _spr = -1;
    
    if (is_array(_sprite_data) && array_length(_sprite_data) > 0)
    {
        _sprite_data = _sprite_data[_cloud.variant_index % array_length(_sprite_data)];
    }
    
    if (_sprite_data != undefined && !is_array(_sprite_data)) 
    {
        _spr = _sprite_data.get_sprite();
        if (_spr != -1)
        {
            _cloud.sprite_sub = irandom(sprite_get_number(_spr) - 1);
        }
    }
    
    show_debug_message($"[Clouds] Spawned at {_x}, {_y} with sprite {_sprite_id}");
    
    global.cloud_pool_count++;
    return i;
}

/// @function cloud_clear()
/// @desc Clear all active clouds
function cloud_clear()
{
    for (var i = 0; i < CLOUD_POOL_MAX; ++i)
    {
        global.cloud_pool[i].active = false;
    }
    global.cloud_pool_count = 0;
}

/// @function cloud_set_tint(_tint)
/// @desc Set tint for all active and future clouds
function cloud_set_tint(_tint)
{
    if (is_string(_tint)) _tint = color_get_value(_tint);
    
    global.cloud_tint = _tint;
    
    for (var i = 0; i < CLOUD_POOL_MAX; ++i)
    {
        if (global.cloud_pool[i].active)
        {
            global.cloud_pool[i].tint = _tint;
        }
    }
}

/// @function cloud_set_wind_factor(_factor)
/// @desc Set wind factor for clouds
function cloud_set_wind_factor(_factor)
{
    global.cloud_wind_factor = _factor;
}

/// @function cloud_set_sprites(_sprites)
/// @desc Set default sprite set
function cloud_set_sprites(_sprites)
{
    if (array_length(_sprites) > 0)
    {
        global.cloud_active_sprite_set = _sprites[0];
    }
}

/// @function cloud_set_speed(_min, _max)
/// @desc Set speed range for active clouds? No, this function seems unused or placeholder
function cloud_set_speed(_min, _max)
{
    // Implementation pending or not needed if handled by spawn parameters
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
        
        if (is_array(_sprite_data) && array_length(_sprite_data) > 0)
        {
             _sprite_data = _sprite_data[_cloud.variant_index % array_length(_sprite_data)];
        }
        
        if (_sprite_data != undefined && !is_array(_sprite_data))
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
    if (global.cloud_pool_count <= 0) 
    {
        return;
    }
    
    for (var i = 0; i < CLOUD_POOL_MAX; ++i)
    {
        var _cloud = global.cloud_pool[i];
        
        if (!_cloud.active) continue;
        
        var _sprite_data = global.sprite_asset[$ _cloud.sprite_id];
        
        if (is_array(_sprite_data) && array_length(_sprite_data) > 0)
        {
             _sprite_data = _sprite_data[_cloud.variant_index % array_length(_sprite_data)];
        }
        
        if (_sprite_data == undefined || is_array(_sprite_data)) 
        {
            // Only log errors occasionally to avoid spam
            if (global.time % 300 == 0) {
                 show_debug_message($"[Clouds] ERROR: Sprite missing for cloud {i}: {_cloud.sprite_id}");
            }
            continue;
        }
        
        var _spr = _sprite_data.get_sprite();
        if (_spr != -1)
        {
            var _draw_x = _camera_x + _cloud.x;
            var _draw_y = _camera_y + _cloud.y;
            
            /*
            // Only log occasionaly to avoid spam
            static _draw_counter = 0;
            _draw_counter++;
            
            if (_draw_counter % 300 == 0) // Less frequent (every 5 seconds at 60fps)
            {
                show_debug_message($"[Clouds] Drawing cloud {i} at world ({_draw_x}, {_draw_y}), screen ({_cloud.x}, {_cloud.y}), scale {_cloud.scale}, alpha {_cloud.alpha}, sprite {_cloud.sprite_id}");
            }
            */
            
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
        else
        {
            static _err_counter = 0;
            _err_counter++;
            if (_err_counter % 300 == 0) {
                show_debug_message($"[Clouds] ERROR: get_sprite() returned -1 for cloud {i}: {_cloud.sprite_id}");
            }
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
    
    var _script_id = _world_data.get_background_script();
    if (_script_id == undefined) return;
    
    // Strip @ prefix if present
    if (string_char_at(_script_id, 1) == "@")
    {
        _script_id = string_delete(_script_id, 1, 1);
    }
    
    show_debug_message($"[Clouds] init_background_clouds starting. Script: {_script_id}");
    
    var _sprites = _world_data.get_background_sprites();
    
    // Set wind factor from config
    global.cloud_wind_factor = _world_data.get_background_cloud_wind_factor();
    
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
        camera_width: _camera_width,
        camera_height: _camera_height,
        
        // Pass all the config values
        count: _world_data.get_background_cloud_count(),
        y_min: _world_data.get_background_cloud_y_min(),
        y_max: _world_data.get_background_cloud_y_max(),
        scale_min: _world_data.get_background_cloud_scale_min(),
        scale_max: _world_data.get_background_cloud_scale_max(),
        alpha_min: _world_data.get_background_cloud_alpha_min(),
        alpha_max: _world_data.get_background_cloud_alpha_max(),
        speed_min: _world_data.get_background_cloud_speed_min(),
        speed_max: _world_data.get_background_cloud_speed_max(),
        wind_factor: _world_data.get_background_cloud_wind_factor(),
    };
    
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
