function chance_seeded(_chance, _seed)
{
    return (((xorshift(_seed) & 0xff) / 0xff) < _chance);
}