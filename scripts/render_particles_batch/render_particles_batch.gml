/// @desc Batch render all particles from the pool
/// @function render_particles_batch()

function render_particles_batch()
{
    var _pool = global.particle_pool;
    
    // Early exit if no active particles
    if (_pool.active_count <= 0) return;
    
    var _particle_data = global.particle_data;
    var _sprite_asset = global.sprite_asset;
    
    // Cache arrays locally
    var _active = _pool.active;
    var _px = _pool.px;
    var _py = _pool.py;
    var _particle_id = _pool.particle_id;
    var _scale = _pool.scale;
    var _rotation = _pool.rotation;
    var _colour = _pool.colour;
    var _alpha = _pool.alpha;
    var _image_index = _pool.image_index;
    var _timer_life = _pool.timer_life;
    var _timer_life_max = _pool.timer_life_max;
    var _is_additive = _pool.is_additive;
    var _is_fade_out = _pool.is_fade_out;
    var _pool_size = _pool.pool_size;
    
    // First pass: Render additive particles
    gpu_set_blendmode(bm_add);
    
    for (var i = 0; i < _pool_size; ++i)
    {
        if (!_active[i]) continue;
        if (!_is_additive[i]) continue;
        
        var _id = _particle_id[i];
        var _data = _particle_data[$ _id];
        if (_data == undefined) continue;
        
        var _sprite = _sprite_asset[$ _data.get_sprite()];
        if (_sprite == undefined) continue;
        
        var _idx = _image_index[i];
        var _s = _scale[i];
        var _r = _rotation[i];
        var _c = _colour[i];
        var _a = _alpha[i];
        
        // Apply fade out
        if (_is_fade_out[i])
        {
            _a *= _timer_life[i] / _timer_life_max[i];
        }
        
        draw_sprite_ext(_sprite.get_sprite(), _idx, _px[i], _py[i], _s, _s, _r, _c, _a);
    }
    
    // Second pass: Render normal particles
    gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_src_alpha, bm_one);
    
    for (var i = 0; i < _pool_size; ++i)
    {
        if (!_active[i]) continue;
        if (_is_additive[i]) continue;
        
        var _id = _particle_id[i];
        var _data = _particle_data[$ _id];
        if (_data == undefined) continue;
        
        var _sprite = _sprite_asset[$ _data.get_sprite()];
        if (_sprite == undefined) continue;
        
        var _idx = _image_index[i];
        var _s = _scale[i];
        var _r = _rotation[i];
        var _c = _colour[i];
        var _a = _alpha[i];
        
        // Apply fade out
        if (_is_fade_out[i])
        {
            _a *= _timer_life[i] / _timer_life_max[i];
        }
        
        draw_sprite_ext(_sprite.get_sprite(), _idx, _px[i], _py[i], _s, _s, _r, _c, _a);
    }
    
    gpu_set_blendmode(bm_normal);
}
