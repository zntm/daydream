function ParentData(_namespace, _id) constructor
{
    ___namespace = _namespace;
    
    static get_namespace = function()
    {
        return ___namespace;
    }
    
    ___id = _id;
    
    static get_id = function()
    {
        return ___id;
    }
}