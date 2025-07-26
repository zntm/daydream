function tile_index_xyz(_x, _y, _z)
{
    gml_pragma("forceinline");
    
    return (_z << (CHUNK_SIZE_BIT * 2)) | tile_index_xy(_x, _y);
}