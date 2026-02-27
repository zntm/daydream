function inventory_craft_clear(_index, _inventory_target = global.inventory, _out_changed_slots = undefined)
{
    var _data = global.crafting_data[_index];
    
    var _ingredients = _data.get_ingredients();
    var _length = _data.get_ingredients_length();
    
    for (var i = 0; i < _length; ++i)
    {
        var _ingredient = _ingredients[i];
        
        var _id = _ingredient.id;
        var _amount = _ingredient.amount;
        
        var _chest_inventories = (global.crafting_pull_from_chests)
            ? inventory_get_nearby_containers(obj_Player.x, obj_Player.y, TILE_SIZE * 4)
            : [];

        // Consume from player inventory
        for (var j = 0; j < global.inventory_length.base; ++j)
        {
            var _item = _inventory_target.base[j];
            
            if (_item == INVENTORY_EMPTY) || ((is_array(_id)) ? (!array_contains(_id, _item.get_id())) : (_id != _item.get_id())) continue;
            
            var _amount2 = _item.get_amount();
            
            if (_amount2 > _amount)
            {
                _inventory_target.base[@ j].add_amount(-_amount);
                
                if (is_array(_out_changed_slots)) array_push(_out_changed_slots, j);
                
                _amount = 0;
                break;
            }
            
            inventory_delete("base", j, _inventory_target, _out_changed_slots);
            
            _amount -= _amount2;
            
            if (_amount <= 0) break;
        }
        
        // Consume from nearby chests if still needed
        if (_amount > 0)
        {
            for (var j = 0; j < array_length(_chest_inventories); ++j)
            {
                var _chest_inv = _chest_inventories[j];
                for (var k = 0; k < array_length(_chest_inv); ++k)
                {
                    var _item = _chest_inv[k];
                    if (_item == INVENTORY_EMPTY) || ((is_array(_id)) ? (!array_contains(_id, _item.get_id())) : (_id != _item.get_id())) continue;
                    
                    var _amount2 = _item.get_amount();
                    
                    if (_amount2 > _amount)
                    {
                        _chest_inv[@ k].add_amount(-_amount);
                        _amount = 0;
                        break;
                    }
                    
                    _chest_inv[@ k] = INVENTORY_EMPTY;
                    _amount -= _amount2;
                    
                    if (_amount <= 0) break;
                }
                if (_amount <= 0) break;
            }
        }
    }
}