global.crafting_data = {}
global.crafting_data_names = [];

global.crafting_stations = [];

function init_crafting(_directory, _prefix = "phantasia", _type = 0)
{
	var _item_data = global.item_data;
	
    var _json = init_tag_value(buffer_load_json(_directory));
    
    var _names  = struct_get_names(_json);
    var _length = array_length(_names);
    
    for (var i = 0; i < _length; ++i)
    {
        var _name = _names[i];
        
        var _data = new CraftingData();
        
        var _recipes = _json[$ _name];
        var _recipes_length = array_length(_recipes);
        
        for (var j = 0; j < _recipes_length; ++j)
        {
            var _recipe = _recipes[j];
            
            _data.add_recipe(new CraftingRecipe(_recipe[$ "amount"])
    			.set_stations(_recipe[$ "stations"])
    			.set_ingredients(_recipe.ingredients));
        }
        
        global.crafting_data[$ _name] = _data;
        
        array_push(global.crafting_names, _name);
    }
    
	delete _json;
}