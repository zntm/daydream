function structure_generate(_inst, _seed, _item_data, _structure_data, _natural_structure_data)
{
    var _data = _inst[$ "data"];
     
    if (_data == undefined)
    {
        _data = _structure_data[$ _inst.structure_id];
        
        if (_data.is_natural())
        {
            var _function = _natural_structure_data[$ _data.get_data()[$ "function"]].get_function();
            
            _data = _function(
                _inst.structure_xrelative,
                _inst.structure_yrelative,
                _inst.image_xscale,
                _inst.image_yscale,
                _seed,
                _data.get_parameter(),
                _item_data
            );
        }
        else
        {
        	_data = _data.get_data();
        }
        
        _inst.data = _data;
    }
    
    return _data;
}