function xorshift(_state)
{
    var _ = _state;
    
    _state ^= _state << 13;
    _state ^= _state >> 17;
    _state ^= _state << 5;
    
    return _state;
}