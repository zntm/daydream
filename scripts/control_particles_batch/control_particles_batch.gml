/// @desc Batch update all particles in the pool
/// @function control_particles_batch(_dt)
/// @param {real} _dt Delta time

function control_particles_batch(_dt)
{
    var _pool = global.particle_pool;
    
    // Early exit if no active particles
    if (_pool.active_count <= 0) exit;
    
    var _dt_normalized = _dt / GAME_TICK;
    
    // Cache arrays locally for faster access
    var _active = _pool.active;
    var _px = _pool.px;
    var _py = _pool.py;
    var _vx = _pool.vx;
    var _vy = _pool.vy;
    var _timer_life = _pool.timer_life;
    var _has_gravity = _pool.has_gravity;
    var _gravity = _pool.gravity;
    var _rotation = _pool.rotation;
    var _rotation_increment = _pool.rotation_increment;
    var _pool_size = _pool.pool_size;
    
    // Camera bounds for culling
    var _camera_x = global.camera_x;
    var _camera_y = global.camera_y;
    var _camera_width = global.camera_width;
    var _camera_height = global.camera_height;
    var _camera_x2 = _camera_x + _camera_width;
    var _camera_y2 = _camera_y + _camera_height;
    
    // Batch process all particles
    for (var i = 0; i < _pool_size; ++i)
    {
        if (!_active[i]) continue;
        
        // Update lifetime
        _timer_life[@ i] -= _dt_normalized;
        
        if (_timer_life[i] <= 0)
        {
            _pool.release(i);
            continue;
        }
        
        // Update position
        _px[@ i] += _vx[i] * _dt;
        _py[@ i] += _vy[i] * _dt;
        
        // Apply gravity
        if (_has_gravity[i])
        {
            _vy[@ i] += _gravity[i] * _dt;
        }
        
        // Update rotation
        if (_rotation_increment[i] != 0)
        {
            _rotation[@ i] += _rotation_increment[i] * _dt;
        }
        
        // Cull off-screen particles
        var _x = _px[i];
        var _y = _py[i];
        
        if (_x < _camera_x - 32 || _x > _camera_x2 + 32 ||
            _y < _camera_y - 32 || _y > _camera_y2 + 32)
        {
            _pool.release(i);
        }
    }
}
