function xorshift(_state)
{
    _state = int64(_state);
    _state = _state ^ (_state << 12);
    _state = _state ^ (_state >> 25);
    _state = _state ^ (_state << 27);
    
    return int64(_state * 2685821657736338717);
}