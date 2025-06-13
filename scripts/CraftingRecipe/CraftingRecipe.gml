function CraftingRecipe(_amount = 1) constructor
{
    ___amount = _amount;
    
    static get_amount = function()
    {
        return ___amount;
    }
    
	static set_stations = function(_stations)
	{
		if (_stations != undefined)
		{
    		if (!is_array(_stations))
    		{
    			___stations = [ _stations ];
    			___stations_length = 1;
    			
    			if (!array_contains(global.crafting_stations, _stations))
    			{
    				array_push(global.crafting_stations, _stations);
    			}
    			
    			return self;
    		}
    		
            ___stations = _stations;
    		___stations_length = array_length(_stations);
    		
    		for (var i = 0; i < ___stations_length; ++i)
    		{
    			var _station = _stations[i];
    			
    			if (!array_contains(global.crafting_stations, _station))
                {
                    array_push(global.crafting_stations, _station);
                    
                    global.item_data[$ _station].set_is_crafting_station();
                }
    		}
		}
		
		return self;
	}
    
    static get_stations = function()
    {
        return self[$ "___stations"];
    }
    
    static get_stations_length = function()
    {
        return self[$ "___stations_length"] ?? 0;
    }
	
	static set_ingredients = function(_ingredients)
	{
        ___ingredients = [];
        
		var _length = array_length(_ingredients);
		
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
}