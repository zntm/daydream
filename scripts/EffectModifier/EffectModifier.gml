enum EFFECT_OPERATION {
    ADD,
    SUBTRACT,
    MULTIPLY,
    DIVIDE,
    POWER
}

global.effect_operation = {
    "add":      EFFECT_OPERATION.ADD,
    "subtract": EFFECT_OPERATION.SUBTRACT,
    "multiply": EFFECT_OPERATION.MULTIPLY,
    "divide":   EFFECT_OPERATION.DIVIDE,
    "power":    EFFECT_OPERATION.POWER
}

/// @function EffectModifier(_value, _operation)
/// @desc Represents a modifier operation for effects and attribute buffs
/// @param {Real|String} _value - The value or "level" for dynamic calculation
/// @param {String} _operation - Operation type (add, subtract, multiply, divide, power)
function EffectModifier(_value, _operation) constructor
{
    static __operation = global.effect_operation;
    
    ___value = _value;
    ___operation = __operation[$ _operation];
    
    static get_value = function()
    {
        return ___value;
    }
    
    static get_operation = function()
    {
        return ___operation;
    }
    
    /// @function calculate(_base, _level)
    /// @desc Apply this modifier to a base value
    /// @param {Real} _base - The base value to modify
    /// @param {Real} _level - The effect level (used if value is "level")
    /// @returns {Real} The modified value
    static calculate = function(_base, _level)
    {
        var _val = (___value == "level") ? _level : ___value;
        
        switch (___operation)
        {
            case EFFECT_OPERATION.ADD:
                return _base + _val;
            case EFFECT_OPERATION.SUBTRACT:
                return _base - _val;
            case EFFECT_OPERATION.MULTIPLY:
                return _base * _val;
            case EFFECT_OPERATION.DIVIDE:
                return _base / _val;
            case EFFECT_OPERATION.POWER:
                return power(_base, _val);
        }
        
        return _base;
    }
}
