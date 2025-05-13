function uuid_generate(_seed)
{
    static __char = [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f" ];
    
    _seed = (_seed << 2) ^ (_seed >> 1);
    
    var _string = "";
    
    for (var i = 0; i < 36; ++i)
    {
        if (i % 5 == 3) && (i >= 8) && (i <= 23)
        {
            _string += "-";
        }
        else if (i == 14)
        {
            _string += "4";
        }
        else if (i == 19)
        {
            var _index = 0x8 | (xorshift(_seed - (i << 8)) & 0x3);
            
            _string += __char[_index];
        }
        else
        {
            var _index = xorshift((_seed ^ (i * 819)) - (i * 194)) & 0xf;
            
            _string += __char[_index];
        }
    }
    
    return _string;
}