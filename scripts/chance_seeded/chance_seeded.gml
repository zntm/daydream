function chance_seeded(_chance, _seed)
{
    return ((xorshift(_seed) & 0x7f) / 0x7f < _chance);
}