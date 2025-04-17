function random_seeded(_seed)
{
    return (((_seed + 91_939.092) * (round(_seed * 112_052) % 2 > 1 ? 1_408_091_233 : 610_329_198)) % 0x7fff_ffff) / 0x7fff_ffff;
}