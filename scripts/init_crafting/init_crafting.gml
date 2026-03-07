global.crafting_data    = [];
global.crafting_stations = [];

function init_crafting(_namespace = "phantasia", _directory)
{
    var _item_data = global.item_data;

    var _array  = tag_value_parse(buffer_load_json(_directory));
    var _length = array_length(_array);

    for (var i = _length - 1; i >= 0; --i)
    {
        var _data   = _array[i];
        var _result = _data.id;

        if (!init_asset_item_exists(_result))
        {
            PRINT($"[init_crafting] Skipping recipe '{_result}': result item not loaded");

            continue;
        }

        var _ingredients        = _data.ingredients;
        var _ingredients_length = array_length(_ingredients);
        var _valid              = true;

        for (var j = _ingredients_length - 1; j >= 0; --j)
        {
            if (!init_asset_item_exists(_ingredients[j].id))
            {
                PRINT($"[init_crafting] Skipping recipe '{_result}': missing ingredient '{_ingredients[j].id}'");

                _valid = false;

                break;
            }
        }

        if (!_valid) continue;

        array_push(global.crafting_data, new CraftingData(_result, _data[$ "amount"] ?? 1)
            .set_crafting_stations(_data[$ "crafting_stations"])
            .set_ingredients(_ingredients));
    }
}