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

/*
    ============================================================
    NOISE SYSTEM — Improved
    ============================================================
    Improvements over original:
      - Fixed 32-bit integer masking (was broken in GML 64-bit)
      - Better hash function (xxHash-style finalizer)
      - Quintic smoothstep for seamless, derivative-continuous blending
      - Cleaner, more maintainable structure
    ============================================================
*/

// ── Macros (define these in your Constants object/script) ───────────────────
//
#macro NOISE_SIZE          256
#macro NOISE_SIZE_BIT      8
#macro NOISE_PIXEL_COUNT   65536      // 256 * 256
#macro NOISE_INV_255       0.00392156862745  // 1/255
#macro NOISE_TRANSITION    48         // blend zone width in pixels
#macro NOISE_TRANSITION_INV 0.020833333      // 1/48
//
// ───────────────────────────────────────────────────────────────────────────

global.noise_buffer_r = buffer_create(NOISE_PIXEL_COUNT * 4, buffer_fixed, 4);
global.noise_buffer_g = buffer_create(NOISE_PIXEL_COUNT * 4, buffer_fixed, 4);
global.noise_buffer_b = buffer_create(NOISE_PIXEL_COUNT * 4, buffer_fixed, 4);
global.noise_seed     = 0;

/* Read 256x256 RGBA from spr_Noise into a raw buffer */
var _raw_size = NOISE_SIZE * NOISE_SIZE * 4;
var _buffer   = buffer_create(_raw_size, buffer_fast, 1);
var _surface  = surface_create(NOISE_SIZE, NOISE_SIZE);

surface_set_target(_surface);
draw_sprite(spr_Noise, 0, 0, 0);
surface_reset_target();

buffer_get_surface(_buffer, _surface, 0);

buffer_seek(_buffer, buffer_seek_start, 0);

for (var i = 0; i < NOISE_PIXEL_COUNT; ++i)
{
    var _r = buffer_read(_buffer, buffer_u8);
    var _g = buffer_read(_buffer, buffer_u8);
    var _b = buffer_read(_buffer, buffer_u8);
    buffer_read(_buffer, buffer_u8); // skip alpha

    buffer_poke(global.noise_buffer_r, i << 2, buffer_f32, _r * NOISE_INV_255);
    buffer_poke(global.noise_buffer_g, i << 2, buffer_f32, _g * NOISE_INV_255);
    buffer_poke(global.noise_buffer_b, i << 2, buffer_f32, _b * NOISE_INV_255);
}

buffer_delete(_buffer);
surface_free(_surface);

/* Default channel for backwards compatibility */
global.noise_buffer = global.noise_buffer_r;


// ── Hash helper (xxHash-style 32-bit finalizer) ──────────────────────────────
//
//  Takes two cell integers + seed, returns a reproducible random integer.
//  Masked to 32 bits at every step to stay correct in GML's 64-bit runtime.
//
function _noise_hash(_cx, _cy)
{
    var _h = (global.noise_seed + _cx * 374761393 + _cy * 1111111111) & 0xFFFFFFFF;

    _h = (_h ^ (_h >> 16)) & 0xFFFFFFFF;
    _h = (_h *  0x45d9f3b) & 0xFFFFFFFF;
    _h = (_h ^ (_h >> 16)) & 0xFFFFFFFF;

    return _h;
}


// ── Quintic smoothstep ────────────────────────────────────────────────────────
//
//  6t^5 - 15t^4 + 10t^3
//  Has zero first AND second derivative at t=0 and t=1,
//  so there are no visible gradient seams between cells.
//
function _smoothstep_quintic(_t)
{
    return _t * _t * _t * (_t * (_t * 6.0 - 15.0) + 10.0);
}


// ── Seed function ─────────────────────────────────────────────────────────────

function open_simplex_noise_seed(_seed)
{
    global.noise_seed = floor(_seed);
}


// ── Raw single-cell sample ────────────────────────────────────────────────────

function vnoise_raw(_cx, _cy, _lx, _ly)
{
    var _buf = global.noise_buffer;
    var _h   = _noise_hash(_cx, _cy);

    // Use hash bits to randomly flip/transpose the tile (8 orientations)
    var _nx = (_h & 1) ? ((NOISE_SIZE - 1) - _lx) : _lx;
    var _ny = (_h & 2) ? ((NOISE_SIZE - 1) - _ly) : _ly;

    if (_h & 4)
    {
        var _temp = _nx;
        _nx = _ny;
        _ny = _temp;
    }

    return buffer_peek(_buf, ((_ny << NOISE_SIZE_BIT) | _nx) << 2, buffer_f32);
}


// ── Main noise sampler (bilinear with quintic blend) ──────────────────────────

function vnoise(_x, _y)
{
    var _buf = global.noise_buffer;

    var _cx = _x >> NOISE_SIZE_BIT;
    var _cy = _y >> NOISE_SIZE_BIT;
    var _lx = _x & (NOISE_SIZE - 1);
    var _ly = _y & (NOISE_SIZE - 1);

    var _cx2 = _cx;
    var _cy2 = _cy;
    var _wx  = 1.0;
    var _wy  = 1.0;

    // Determine X blend
    if (_lx < NOISE_TRANSITION)
    {
        _cx2 = _cx - 1;
        _wx  = 0.5 + 0.5 * _smoothstep_quintic(_lx * NOISE_TRANSITION_INV);
    }
    else if (_lx > NOISE_SIZE - NOISE_TRANSITION)
    {
        _cx2 = _cx + 1;
        _wx  = 0.5 + 0.5 * _smoothstep_quintic((NOISE_SIZE - _lx) * NOISE_TRANSITION_INV);
    }

    // Determine Y blend
    if (_ly < NOISE_TRANSITION)
    {
        _cy2 = _cy - 1;
        _wy  = 0.5 + 0.5 * _smoothstep_quintic(_ly * NOISE_TRANSITION_INV);
    }
    else if (_ly > NOISE_SIZE - NOISE_TRANSITION)
    {
        _cy2 = _cy + 1;
        _wy  = 0.5 + 0.5 * _smoothstep_quintic((NOISE_SIZE - _ly) * NOISE_TRANSITION_INV);
    }

    // ── Inline sample: _cx, _cy ──────────────────────────────────────────────
    var _h = _noise_hash(_cx, _cy);
    var _nx = (_h & 1) ? ((NOISE_SIZE - 1) - _lx) : _lx;
    var _ny = (_h & 2) ? ((NOISE_SIZE - 1) - _ly) : _ly;
    if (_h & 4) { var _tmp = _nx; _nx = _ny; _ny = _tmp; }
    var _v11 = buffer_peek(_buf, ((_ny << NOISE_SIZE_BIT) | _nx) << 2, buffer_f32);

    // Early exit — no blending needed
    if (_cx == _cx2 && _cy == _cy2) return _v11;

    // ── X-only blend ─────────────────────────────────────────────────────────
    if (_cx != _cx2 && _cy == _cy2)
    {
        _h = _noise_hash(_cx2, _cy);
        _nx = (_h & 1) ? ((NOISE_SIZE - 1) - _lx) : _lx;
        _ny = (_h & 2) ? ((NOISE_SIZE - 1) - _ly) : _ly;
        if (_h & 4) { _tmp = _nx; _nx = _ny; _ny = _tmp; }
        var _v21 = buffer_peek(_buf, ((_ny << NOISE_SIZE_BIT) | _nx) << 2, buffer_f32);

        return lerp(_v21, _v11, _wx);
    }

    // ── Y-only blend ─────────────────────────────────────────────────────────
    if (_cx == _cx2 && _cy != _cy2)
    {
        _h = _noise_hash(_cx, _cy2);
        _nx = (_h & 1) ? ((NOISE_SIZE - 1) - _lx) : _lx;
        _ny = (_h & 2) ? ((NOISE_SIZE - 1) - _ly) : _ly;
        if (_h & 4) { _tmp = _nx; _nx = _ny; _ny = _tmp; }
        var _v12 = buffer_peek(_buf, ((_ny << NOISE_SIZE_BIT) | _nx) << 2, buffer_f32);

        return lerp(_v12, _v11, _wy);
    }

    // ── Full bilinear blend ───────────────────────────────────────────────────
    _h = _noise_hash(_cx2, _cy);
    _nx = (_h & 1) ? ((NOISE_SIZE - 1) - _lx) : _lx;
    _ny = (_h & 2) ? ((NOISE_SIZE - 1) - _ly) : _ly;
    if (_h & 4) { _tmp = _nx; _nx = _ny; _ny = _tmp; }
    var _v21 = buffer_peek(_buf, ((_ny << NOISE_SIZE_BIT) | _nx) << 2, buffer_f32);

    _h = _noise_hash(_cx, _cy2);
    _nx = (_h & 1) ? ((NOISE_SIZE - 1) - _lx) : _lx;
    _ny = (_h & 2) ? ((NOISE_SIZE - 1) - _ly) : _ly;
    if (_h & 4) { _tmp = _nx; _nx = _ny; _ny = _tmp; }
    var _v12 = buffer_peek(_buf, ((_ny << NOISE_SIZE_BIT) | _nx) << 2, buffer_f32);

    _h = _noise_hash(_cx2, _cy2);
    _nx = (_h & 1) ? ((NOISE_SIZE - 1) - _lx) : _lx;
    _ny = (_h & 2) ? ((NOISE_SIZE - 1) - _ly) : _ly;
    if (_h & 4) { _tmp = _nx; _nx = _ny; _ny = _tmp; }
    var _v22 = buffer_peek(_buf, ((_ny << NOISE_SIZE_BIT) | _nx) << 2, buffer_f32);

    var _vx1 = lerp(_v21, _v11, _wx);
    var _vx2 = lerp(_v22, _v12, _wx);

    return lerp(_vx2, _vx1, _wy);
}


// ── Public API: Fractal / Octave noise ────────────────────────────────────────
//
//  open_simplex_noise(_x, _y, _amplitude, _octaves)
//
//  Returns a value in roughly [0, _amplitude].
//  More octaves = more fine detail, but slower.
//
function open_simplex_noise(_x, _y, _amplitude, _octaves)
{
    // _x = floor(_x * 32);
    // _y = floor(_y * 32);

    _x *= 8;
    _y *= 8;
    
    var _result = 0;
    var _amp    = _amplitude;
    var _freq   = 1;

    repeat (_octaves)
    {
        _amp    *= 0.5;
        _result += vnoise(_x * _freq, _y * _freq) * _amp;
        _freq    = _freq << 1;
    }

    return _result;
}


// ── Utility: Switch active noise channel ──────────────────────────────────────
//
//  Call these to choose which RGB channel of spr_Noise to sample from.
//  Gives you 3 independent noise fields from a single sprite.
//
function noise_use_red()   { global.noise_buffer = global.noise_buffer_r; }
function noise_use_green() { global.noise_buffer = global.noise_buffer_g; }
function noise_use_blue()  { global.noise_buffer = global.noise_buffer_b; }
