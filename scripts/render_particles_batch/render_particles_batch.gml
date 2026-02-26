/// @desc Batch render all particles from the pool
/// @function render_particles_batch()

function render_particles_batch()
{
    var _pool = global.particle_pool;
    
    // Update particle visuals (positions, lifetime, colours, etc.) each frame
    // This was missing, causing particles to be spawned but never visible
    _pool.update_visuals(global.delta_time);
    
    if (_pool.active_count <= 0) exit;
    
    var _particle_data = global.particle_data;
    var _sprite_asset = global.sprite_asset;
    
    var _active = _pool.active;
    var _particle_id = _pool.particle_id;
    var _x = _pool.px;
    var _y = _pool.py;
    var _xscale = _pool.xscale;
    var _yscale = _pool.yscale;
    var _rotation = _pool.rotation;
    var _colour = _pool.colour;
    var _alpha = _pool.alpha;
    var _image_index = _pool.image_index;
    var _timer_life = _pool.timer_life;
    var _timer_life_max = _pool.timer_life_max;
    var _is_additive = _pool.is_additive;

    var _pool_size = _pool.pool_size;
    
    BLENDMODE_ADD;
    
    for (var i = 0; i < _pool_size; ++i)
    {
        if (!_active[i]) || (!_is_additive[i]) continue;
        
        var _sprite = _sprite_asset[$ global.particle_data[$ _particle_id[i]].get_sprite()];
        
        if (_sprite == undefined) continue;
        
        draw_sprite_ext(
            _sprite.get_sprite(),
            _image_index[i],
            _x[i],
            _y[i],
            _xscale[i],
            _yscale[i],
            _rotation[i],
            _colour[i],
            _alpha[i]
        );
    }
    
    BLENDMODE_TINT;
    
    for (var i = 0; i < _pool_size; ++i)
    {
        if (!_active[i]) || (_is_additive[i]) continue;
        
        var _sprite = _sprite_asset[$ global.particle_data[$ _particle_id[i]].get_sprite()];
        
        if (_sprite == undefined) continue;
        
        draw_sprite_ext(
            _sprite.get_sprite(),
            _image_index[i],
            _x[i],
            _y[i],
            _xscale[i],
            _yscale[i],
            _rotation[i],
            _colour[i],
            _alpha[i]
        );
    }
    
    BLENDMODE_NORMAL;
}
