function ItemCooldown(_id, _seconds) constructor
{
    ___id = _id;
    ___seconds = _seconds;
    
    static get_id = function()
    {
        return ___id;
    }
    
    static get_seconds = function()
    {
        return ___seconds;
    }
}