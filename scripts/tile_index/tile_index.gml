function tile_index(_x, _y, _z)
{
    return (_z << (CHUNK_SIZE_BIT * 2)) | ((_y & (CHUNK_SIZE - 1)) << CHUNK_SIZE_BIT) | (_x & (CHUNK_SIZE - 1));
}