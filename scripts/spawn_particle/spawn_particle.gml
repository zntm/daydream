/// @function spawn_particle(_x, _y, _id, _colour)
/// @desc Spawn a particle using the optimized pool system
/// @param {real} _x X position
/// @param {real} _y Y position
/// @param {string} _id Particle data ID
/// @param {real} _tint Optional blend colour (default: c_white)
function spawn_particle(_x, _y, _id, _tint = c_white)
{
    return global.particle_pool.spawn(_x, _y, _id, _tint);
}
