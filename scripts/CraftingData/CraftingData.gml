function CraftingData() constructor
{
    ___recipes = [];
    ___recipes_length = 0;
    
    static add_recipe = function(_recipe)
    {
        array_push(___recipes, _recipe);
        
        ++___recipes_length;
        
        return self;
    }
    
    static get_recipes = function()
    {
        return ___recipes;
    }
    
    static get_recipes_length = function()
    {
        return ___recipes_length;
    }
}