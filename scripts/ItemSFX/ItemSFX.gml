function ItemSFX(_id, _gain) constructor
{
    ___id = _id;
    ___gain = _gain;
    
    static get_id = function()
    {
        return ___id;
    }
    
    static get_gain = function()
    {
        return ___gain;
    }
}