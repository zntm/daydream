/// @desc Resolve collisions for all active entities using the Quadtree
function control_resolve_collisions()
{
    // Walk the quadtree and resolve narrow-phase collisions for all pairs found
    global.creature_quadtree.walk_collisions(function(_inst_a, _inst_b) {
        // _inst_a and _inst_b are instances (obj_Creature)
        
        // Ensure both still exist (in case of destruction during frame, though rare here)
        if (!instance_exists(_inst_a) || !instance_exists(_inst_b)) return;
        
        // Use the extracted physics resolution logic
        // We access the .physics_body struct from the instance
        physics_resolve_collision(_inst_a.physics_body, _inst_b.physics_body);
    });
}
