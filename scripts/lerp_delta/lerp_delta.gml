function lerp_delta(_a, _b, _amount, _delta_time = global.delta_time)
{
    // Freya Holmér
    return _b + (_a - _b) * exp(-_amount * _delta_time);
}