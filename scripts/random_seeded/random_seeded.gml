function random_seeded(_value, _seed)
{
    return ((xorshift(_seed) & 0x7fff_ffff) / 0x7fff_ffff) * _value;
}