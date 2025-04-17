function chance(_chance)
{
    gml_pragma("forceinline");
    
    return (random(1) < _chance);
}