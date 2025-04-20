function random_seeded(_seed)
{
    _seed ^= 0x8807_23bb;
    
    _seed += round(_seed * 19_320.2832) * ((floor(_seed / 227.244) & 1) ? 1_408.288 : 65_198.245);
    
    if (_seed & (1 << 23))
    {
        _seed = -_seed;
    }
    
    if (_seed & ((1 << 43) | (1 << 27) | (1 << 19)))
    {
        _seed ^= 0xfb7d_f099_23de_b9a1;
    }
    
    return (_seed & 0x7fff_ffff) / 0x7fff_ffff;
}