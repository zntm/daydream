/// @desc  Function to calculate the progress (value from 0 to 1) given a result.
/// @param {Real} _value The value used to get the range,
/// @param {Real} _min The minimum value.
/// @param {Real} _max The maximum value.
function normalize(_value, _min, _max)
{
    /*
    if (!DEVELOPER_MODE)
    {
        gml_pragma("forceinline");
    }
    */
    return clamp((_value - _min) / (_max - _min), 0, 1);
}