function Sound(_id, _gain = undefined) constructor
{
    ___id = _id;
    
    if (_gain != undefined)
    {
        ___gain = _gain;
    }
    
    static get_id = function()
    {
        return ___id;
    }
    
    static get_gain = function()
    {
        return self[$ "___gain"] ?? 1;
    }
}