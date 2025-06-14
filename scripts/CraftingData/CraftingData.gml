function CraftingData(_id, _amount) constructor
{
    ___id = _id;
    
    static get_id = function()
    {
        return ___id;
    }
    
    ___amount = _amount;
    
    static get_amount = function()
    {
        return ___amount;
    }
    
	static set_crafting_stations = function(_crafting_stations)
	{
		if (_crafting_stations != undefined)
		{
    		if (!is_array(_crafting_stations))
    		{
    			___crafting_stations = [ _crafting_stations ];
    			___crafting_stations_length = 1;
    			
    			if (!array_contains(global.crafting_stations, _crafting_stations))
    			{
    				array_push(global.crafting_stations, _crafting_stations);
                    
                    global.item_data[$ _crafting_stations].set_is_crafting_station(true); 
    			}
    			
    			return self;
    		}
    		
            ___crafting_stations = _crafting_stations;
    		___crafting_stations_length = array_length(_crafting_stations);
    		
    		for (var i = 0; i < ___crafting_stations_length; ++i)
    		{
    			var _station = _crafting_stations[i];
    			
    			if (!array_contains(global.crafting_stations, _station))
                {
                    array_push(global.crafting_stations, _station);
                    
                    global.item_data[$ _station].set_is_crafting_station(true);
                }
    		}
		}
		
		return self;
	}
    
    static get_crafting_stations = function()
    {
        return self[$ "___crafting_stations"];
    }
    
    static get_crafting_stations_length = function()
    {
        return self[$ "___crafting_stations_length"] ?? 0;
    }
	
	static set_ingredients = function(_ingredients)
	{
        var _length = array_length(_ingredients);
        
        ___ingredients = [];
        ___ingredients_length = _length;
		
		for (var i = 0; i < _length; ++i)
		{
			var _ingredient = _ingredients[i];
			
			array_push(___ingredients, {
				id: _ingredient.id,
				amount: _ingredient[$ "amount"] ?? 1,
				unlock_recipe: _ingredient[$ "unlock_recipe"] ?? true
			});
		}
		
		return self;
	}
    
    static get_ingredients = function()
    {
        return ___ingredients;
    }
    
    static get_ingredients_length = function()
    {
        return ___ingredients_length;
    }
}