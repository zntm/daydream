function tile_index_xy(_x, _y)
{
    gml_pragma("forceinline");
    
    return ((_y & (CHUNK_SIZE - 1)) << CHUNK_SIZE_BIT) | (_x & (CHUNK_SIZE - 1));
}