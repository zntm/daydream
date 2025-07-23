function tile_connected_index_y(_index)
{
    if
    (_index == 0b010_00_010) ||
    (_index == 0b000_10_000) ||
    (_index == 0b000_01_000) ||
    (_index == 0b010_10_010) ||
    (_index == 0b010_01_010) ||
    (_index == 0b111_11_111)
    {
        return -1;
    }
    
    return 1;
}