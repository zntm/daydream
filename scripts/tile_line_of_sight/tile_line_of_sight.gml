function tile_line_of_sight(_x1, _y1, _x2, _y2)
{
    // Use the new precise raycast
    // This allows vision to pass through gaps in collision boxes (e.g. slopes)
    // whereas the old method blocked on any solid tile.
    
    var _hit = tile_raycast(_x1, _y1, _x2, _y2, CHUNK_DEPTH_DEFAULT, ITEM_TYPE_BIT.SOLID);
    
    // If we hit something, and the distance is less than the full distance 
    // (meaning we hit something "before" the end point), line of sight is blocked.
    // Floating point epsilon might be needed, but usually 'hit' implies 'hit something along the ray'.
    
    return !_hit.hit;
}
