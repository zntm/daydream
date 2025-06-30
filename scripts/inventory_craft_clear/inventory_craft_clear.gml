function inventory_craft_clear(_index)
{
    var _data = global.crafting_data[_index];
    
    var _ingredients = _data.get_ingredients();
    var _length = _data.get_ingredients_length();
    
    for (var i = 0; i < _length; ++i)
    {
        var _ingredient = _ingredients[i];
        
        var _id = _ingredient.id;
        var _amount = _ingredient.amount;
        
        for (var j = 0; j < global.inventory_length.base; ++j)
        {
            var _item = global.inventory.base[j];
            
            if (_item == INVENTORY_EMPTY) || ((is_array(_id)) ? (!array_contains(_id, _item.get_id())) : (_id != _item.get_id())) continue;
            
            var _amount2 = _item.get_amount();
            
            if (_amount2 > _amount)
            {
                global.inventory.base[@ j].add_amount(-_amount);
                
                break;
            }
            
            inventory_delete("base", j);
            
            if (_amount2 == _amount) break;
            
            _amount -= _amount2;
        }
    }
}