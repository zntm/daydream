function chance_seeded(_chance, _seed)
{
    return (random_seeded(_seed) < _chance);
}