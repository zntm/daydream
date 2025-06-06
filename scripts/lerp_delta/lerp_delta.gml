function lerp_delta(_a, _b, _amount, _delta_time = global.delta_time)
{
    return lerp(_b, _a, exp(-_amount * _delta_time));
}