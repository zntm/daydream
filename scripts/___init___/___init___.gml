enum VERISON_TYPE {
    ALPHA,
    BETA,
    RELEASE
}

#macro IS_DEVELOPER_MODE 1

#macro IS_ENABLED_BACKUP true
#macro BACKUP_INTERVAL_SECONDS 600 // 10 minutes

#macro PROGRAM_VERSION_MAJOR current_year
#macro PROGRAM_VERSION_MINOR 0
#macro PROGRAM_VERSION_PATCH 1
#macro PROGRAM_VERSION_TYPE VERISON_TYPE.ALPHA
#macro PROGRAM_VERSION_NUMBER (PROGRAM_VERSION_MAJOR << 16) | (PROGRAM_VERSION_MINOR << 8) | (PROGRAM_VERSION_PATCH << 0)

#macro PROGRAM_NAME "Phantasia"

#macro GAME_TICK 60

#macro SITE_DISCORD "https://discord.gg/MetyWwT8fs"

#macro SITE_BLUESKY "https://bsky.app/profile/phantasiagame.bsky.social"
#macro SITE_TWITTER "https://x.com/PhantasiaGame"

cursor_sprite = spr_Mouse;

randomize();

window_set_cursor(cr_none);

gml_pragma("MarkTagAsUsed", "include_me");

sysinfo_init();

#macro NOISE_SIZE           1024
#macro NOISE_SIZE_BIT       10
#macro NOISE_TRANSITION     128
#macro NOISE_TRANSITION_INV 0.0078125
#macro NOISE_INV_255        0.00392156862745098

global.noise_buffer = buffer_create(NOISE_SIZE * NOISE_SIZE * 4, buffer_fixed, 4);
global.noise_seed = 0;

var _buffer = buffer_create(NOISE_SIZE * NOISE_SIZE, buffer_fast, 1);
var _surface = surface_create(NOISE_SIZE, NOISE_SIZE, surface_r8unorm);

surface_set_target(_surface);

draw_sprite(spr_Noise, 0, 0, 0);

surface_reset_target();

buffer_get_surface(_buffer, _surface, 0);

buffer_seek(_buffer, buffer_seek_start, 0);

// Convert u8 noise data to f32 in a contiguous buffer for fast lookup
for (var i = 0; i < 1024 * 1024; ++i)
{
    buffer_poke(global.noise_buffer, i << 2, buffer_f32, buffer_read(_buffer, buffer_u8) * NOISE_INV_255);
}

buffer_delete(_buffer);
surface_free(_surface);

function open_simplex_noise_seed(_seed)
{
    global.noise_seed = floor(_seed);
}

/// @desc Sample noise from buffer with cell hashing (inlined into vnoise for performance)
/// Kept as a standalone for any external callers
function vnoise_raw(_cx, _cy, _lx, _ly)
{
    static _buf = global.noise_buffer;
    
    var _state = global.noise_seed ^ (_cx * 374761393) ^ (_cy * 668265263);
    
    _state ^= _state << 13;
    _state ^= _state >> 17;
    _state ^= _state << 5;
    
    var _orientation = _state & 7;
    var _nx = (_orientation & 1) ? ((NOISE_SIZE - 1) - _lx) : _lx;
    var _ny = (_orientation & 2) ? ((NOISE_SIZE - 1) - _ly) : _ly;
    
    if (_orientation & 4)
    {
        var _temp = _nx;
        
        _nx = _ny;
        _ny = _temp;
    }
    
    return buffer_peek(_buf, ((_ny << NOISE_SIZE_BIT) | _nx) << 2, buffer_f32);
}

function vnoise(_x, _y)
{
    static _buf = global.noise_buffer;
    static _seed_ref = global.noise_seed;
    
    var _cx = _x >> NOISE_SIZE_BIT;
    var _cy = _y >> NOISE_SIZE_BIT;
    
    var _lx = _x & (NOISE_SIZE - 1);
    var _ly = _y & (NOISE_SIZE - 1);
    
    var _cx2 = _cx;
    var _cy2 = _cy;
    
    var _wx = 1.0;
    var _wy = 1.0;
    
    if (_lx < NOISE_TRANSITION)
    {
        _cx2 = _cx - 1;
        
        var _t = _lx * NOISE_TRANSITION_INV;
        
        _wx = 0.5 + 0.5 * (_t * _t * (3 - 2 * _t));
    }
    else if (_lx > NOISE_SIZE - NOISE_TRANSITION)
    {
        _cx2 = _cx + 1;
        
        var _t = (NOISE_SIZE - _lx) * NOISE_TRANSITION_INV;
        
        _wx = 0.5 + 0.5 * (_t * _t * (3 - 2 * _t));
    }
    
    if (_ly < NOISE_TRANSITION)
    {
        _cy2 = _cy - 1;
        
        var _t = _ly * NOISE_TRANSITION_INV;
        
        _wy = 0.5 + 0.5 * (_t * _t * (3 - 2 * _t));
    }
    else if (_ly > NOISE_SIZE - NOISE_TRANSITION)
    {
        _cy2 = _cy + 1;
        
        var _t = (NOISE_SIZE - _ly) * NOISE_TRANSITION_INV;
        
        _wy = 0.5 + 0.5 * (_t * _t * (3 - 2 * _t));
    }
    
    // --- Inline vnoise_raw for _cx, _cy ---
    var _seed = global.noise_seed;
    
    var _state = _seed ^ (_cx * 374761393) ^ (_cy * 668265263);
    _state ^= _state << 13;
    _state ^= _state >> 17;
    _state ^= _state << 5;
    var _o = _state & 7;
    var _nx = (_o & 1) ? ((NOISE_SIZE - 1) - _lx) : _lx;
    var _ny = (_o & 2) ? ((NOISE_SIZE - 1) - _ly) : _ly;
    if (_o & 4) { var _tmp = _nx; _nx = _ny; _ny = _tmp; }
    var _v11 = buffer_peek(_buf, ((_ny << NOISE_SIZE_BIT) | _nx) << 2, buffer_f32);
    
    if (_cx == _cx2) && (_cy == _cy2)
    {
        return _v11;
    }
    
    if (_cx != _cx2) && (_cy == _cy2)
    {
        // Inline vnoise_raw for _cx2, _cy
        _state = _seed ^ (_cx2 * 374761393) ^ (_cy * 668265263);
        _state ^= _state << 13;
        _state ^= _state >> 17;
        _state ^= _state << 5;
        _o = _state & 7;
        _nx = (_o & 1) ? ((NOISE_SIZE - 1) - _lx) : _lx;
        _ny = (_o & 2) ? ((NOISE_SIZE - 1) - _ly) : _ly;
        if (_o & 4) { _tmp = _nx; _nx = _ny; _ny = _tmp; }
        var _v21 = buffer_peek(_buf, ((_ny << NOISE_SIZE_BIT) | _nx) << 2, buffer_f32);
        
        return lerp(_v21, _v11, _wx);
    }
    
    if (_cx == _cx2) && (_cy != _cy2)
    {
        // Inline vnoise_raw for _cx, _cy2
        _state = _seed ^ (_cx * 374761393) ^ (_cy2 * 668265263);
        _state ^= _state << 13;
        _state ^= _state >> 17;
        _state ^= _state << 5;
        _o = _state & 7;
        _nx = (_o & 1) ? ((NOISE_SIZE - 1) - _lx) : _lx;
        _ny = (_o & 2) ? ((NOISE_SIZE - 1) - _ly) : _ly;
        if (_o & 4) { _tmp = _nx; _nx = _ny; _ny = _tmp; }
        var _v12 = buffer_peek(_buf, ((_ny << NOISE_SIZE_BIT) | _nx) << 2, buffer_f32);
        
        return lerp(_v12, _v11, _wy);
    }
    
    // Full bilinear: need _v21, _v12, _v22
    // Inline vnoise_raw for _cx2, _cy
    _state = _seed ^ (_cx2 * 374761393) ^ (_cy * 668265263);
    _state ^= _state << 13;
    _state ^= _state >> 17;
    _state ^= _state << 5;
    _o = _state & 7;
    _nx = (_o & 1) ? ((NOISE_SIZE - 1) - _lx) : _lx;
    _ny = (_o & 2) ? ((NOISE_SIZE - 1) - _ly) : _ly;
    if (_o & 4) { _tmp = _nx; _nx = _ny; _ny = _tmp; }
    var _v21 = buffer_peek(_buf, ((_ny << NOISE_SIZE_BIT) | _nx) << 2, buffer_f32);
    
    // Inline vnoise_raw for _cx, _cy2
    _state = _seed ^ (_cx * 374761393) ^ (_cy2 * 668265263);
    _state ^= _state << 13;
    _state ^= _state >> 17;
    _state ^= _state << 5;
    _o = _state & 7;
    _nx = (_o & 1) ? ((NOISE_SIZE - 1) - _lx) : _lx;
    _ny = (_o & 2) ? ((NOISE_SIZE - 1) - _ly) : _ly;
    if (_o & 4) { _tmp = _nx; _nx = _ny; _ny = _tmp; }
    var _v12 = buffer_peek(_buf, ((_ny << NOISE_SIZE_BIT) | _nx) << 2, buffer_f32);
    
    // Inline vnoise_raw for _cx2, _cy2
    _state = _seed ^ (_cx2 * 374761393) ^ (_cy2 * 668265263);
    _state ^= _state << 13;
    _state ^= _state >> 17;
    _state ^= _state << 5;
    _o = _state & 7;
    _nx = (_o & 1) ? ((NOISE_SIZE - 1) - _lx) : _lx;
    _ny = (_o & 2) ? ((NOISE_SIZE - 1) - _ly) : _ly;
    if (_o & 4) { _tmp = _nx; _nx = _ny; _ny = _tmp; }
    var _v22 = buffer_peek(_buf, ((_ny << NOISE_SIZE_BIT) | _nx) << 2, buffer_f32);
    
    var _vx1 = lerp(_v21, _v11, _wx);
    var _vx2 = lerp(_v22, _v12, _wx);
    
    return lerp(_vx2, _vx1, _wy);
}

function open_simplex_noise(_x, _y, _amplitude, _octaves)
{
    // Floor once upfront — _freq is always a power-of-2 integer,
    // so subsequent multiplications stay integral
    _x = floor(_x * 32);
    _y = floor(_y * 32);
    
    var _result = 0;
    var _amp    = _amplitude;
    var _freq   = 1;
    
    repeat (_octaves)
    {
        _amp *= 0.5;
        
        _result += vnoise(_x * _freq, _y * _freq) * _amp;
        
        _freq = _freq << 1;
    }
    
    return _result;
}