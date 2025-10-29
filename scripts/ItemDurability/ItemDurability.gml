function ItemDurability(_amount, _bar)
{
    ___amount = _amount;
    ___bar = _bar;
    ___bar_length = array_length(_bar);
    
    static get_amount = function()
    {
        return ___amount;
    }
    
    static get_bar = function()
    {
        return ___bar;
    }
    
    static get_bar_length = function()
    {
        return ___bar_length;
    }
}