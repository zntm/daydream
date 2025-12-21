/// @function effect_calculate_value(_data, _level)
/// @desc Calculate the final effect value using the new EffectData system
/// @param {Struct.EffectData} _data - The effect data
/// @param {Real} _level - The effect level
/// @returns {Real} The calculated effect value
function effect_calculate_value(_data, _level)
{
    // Use the new EffectData.calculate_value method
    return _data.calculate_value(_level);
}