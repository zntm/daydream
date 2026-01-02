/// @desc Updates and repopulates the global creature quadtree
function control_quadtree_update()
{
    var _padding = TILE_SIZE * 32;
    var _x = global.camera_x_real - _padding;
    var _y = global.camera_y_real - _padding;
    var _w = global.camera_width + (_padding * 2);
    var _h = global.camera_height + (_padding * 2);
    
    // Create new quadtree centered on view
    // Using a moderate depth (4-6) is usually sufficient for screen-space
    global.creature_quadtree = new Quadtree(_x, _y, _w, _h, 8, 4);
    
    // Populate with active creatures
    with (obj_Creature)
    {
        // Only insert if within bounds (optional, but good for safety)
        // Quadtree insert handles checking if it fits, but we can pre-cull relevant ones
        // matching the quadtree bounds logic implicitly
        global.creature_quadtree.insert(id);
    }
}
