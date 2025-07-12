function tile_connected_index_x(_index, _seed)
{
    if
    (_index == 0b111_00_000) ||
    (_index == 0b000_11_000) ||
    (_index == 0b000_00_111) ||
    (_index == 0b111_11_000) ||
    (_index == 0b000_11_111) ||
    (_index == 0b111_00_111) ||
    (_index == 0b111_11_111)
    {
        var _xorshift = xorshift(_seed);
        
        if (_xorshift & 1)
        {
            return -1;
        }
    }
    
    return 1;
}