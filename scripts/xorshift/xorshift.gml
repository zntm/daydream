function xorshift(_state)
{
    _state ^= _state << 13;
    _state ^= _state >> 17;
    _state ^= _state << 5;
    
    return _state;
}