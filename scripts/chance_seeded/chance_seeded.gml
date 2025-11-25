function chance_seeded(_chance, _seed)
{
    gml_pragma("forceinline");
    
    return (((xorshift(_seed) & 0xff) / 0xff) < _chance);
}