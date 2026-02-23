/// @desc Checks for symmetry within a 8-bit connected tile bitmask to determine if flipping is visually safe.
/// @param {real} _bitmask The 8-bit connection mask.
function tile_connected_index(_bitmask)
{
    var _res = 0;
    
    /* 
       Neighbor bits mapping (bit indices):
       7 6 5
       4   3
       2 1 0
       
       where:
       0: BR, 1: B, 2: BL
       3: R,  4: L
       5: TR, 6: T, 7: TL
    */
    
    /* check horizontal symmetry (swap Left <-> Right) */
    /* pairs: 3<->4, 7<->5, 2<->0 */
    var _r = (_bitmask >> 3) & 1;
    var _l = (_bitmask >> 4) & 1;
    
    var _tl = (_bitmask >> 7) & 1;
    var _tr = (_bitmask >> 5) & 1;
    
    var _bl = (_bitmask >> 2) & 1;
    var _br = (_bitmask >> 0) & 1;
    
    if (_l == _r) && (_tl == _tr) && (_bl == _br)
    {
        _res |= 1; /* can flip on X */
    }
    
    /* check vertical symmetry (swap Top <-> Bottom) */
    /* pairs: 6<->1, 7<->2, 5<->0 */
    var _t = (_bitmask >> 6) & 1;
    var _b = (_bitmask >> 1) & 1;
    
    /* tl, tr, bl, br already extracted */
    if (_t == _b) && (_tl == _bl) && (_tr == _br)
    {
        _res |= 2; /* can flip on Y */
    }
    
    return _res;
}
