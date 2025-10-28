function ItemDrop(_id, _amount = 1, _chance = undefined) constructor
{
    ___id = _id;
    ___amount = _amount;
    ___chance = _chance;
    
    static get_id = function()
    {
        return ___id;
    }
    
    static get_amount = function()
    {
        return ___amount;
    }
    
    static get_chance = function()
    {
        return ___chance;
    }
}