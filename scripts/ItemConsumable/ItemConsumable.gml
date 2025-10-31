function ItemConsumable(_hp, _saturation, _cooldown, _sfx) constructor
{
    ___hp = _hp;
    ___saturation = _saturation;
    
    if (_cooldown != undefined)
    {
        ___cooldown = new ItemCooldown(_cooldown.id, _cooldown.seconds);
    }
    
    if (_sfx != undefined)
    {
        ___sfx = new Sound(_sfx.id, _sfx[$ "gain"]);
    }
    
    static get_hp = function()
    {
        return ___hp;
    }
    
    static get_saturation = function()
    {
        return ___saturation;
    }
    
    static get_cooldown = function()
    {
        return self[$ "___cooldown"];
    }

    static get_sfx = function()
    {
        return self[$ "___sfx"];
    }
}