function SFXData() constructor
{
    static set_asset = function(_asset)
    {
        ___asset = [];
        
        var _sfx_asset = global.sfx_asset;
        
        var _length = array_length(_asset);
        
        for (var i = 0; i < _length; ++i)
        {
            array_push(___asset, _sfx_asset[$ _asset[i]]);
        }
        
        return self;
    }
    
    static get_asset = function()
    {
        return ___asset;
    }
    
    static set_falloff = function(_falloff)
    {
        ___falloff_reference = _falloff.reference;
        ___falloff_max = _falloff.max;
        
        return self;
    }
    
    static get_falloff_reference = function()
    {
        return ___falloff_reference;
    }
    
    static get_falloff_max = function()
    {
        return ___falloff_max;
    }
    
    static set_subtitle = function(_subtitle)
    {
        if (_subtitle != undefined)
        {
            ___subtitle = _subtitle;
        }
        
        return self;
    }
    
    static get_subtitle = function()
    {
        return self[$ "___subtitle"];
    }
}