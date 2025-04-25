function chance_seeded(_chance, _seed)
{
    return (random_seeded(1, _seed) < _chance);
}