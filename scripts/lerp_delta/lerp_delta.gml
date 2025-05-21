function lerp_delta(_a, _b, _amount, _delta_time = global.delta_time)
{
    return lerp(_a, _b, 1 - exp(-_amount * _delta_time));
}