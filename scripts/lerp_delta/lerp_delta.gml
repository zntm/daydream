/// @desc Calculates a smooth transition between two values regardless of fluctuations in frame time based on the exponential decay formula popularized by Freya Holmér.
/// @param {real} _a The first value.
/// @param {real} _b The second value.
/// @param {real} _amount The amount to interpolate.
/// @param {real} _dt The delta time.
function lerp_delta(_a, _b, _amount, _dt = global.delta_time)
{
    return _b + (_a - _b) * exp(-_amount * _dt);
}
