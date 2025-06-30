global.crafting_data = [];
global.crafting_stations = [];

function init_crafting(_directory, _prefix = "phantasia", _type = 0)
{
    var _item_data = global.item_data;
    
    var _json = tag_value_parse(buffer_load_json(_directory).data);
    
    var _length = array_length(_json);
    
    for (var i = 0; i < _length; ++i)
    {
        var _data = _json[i];
        
        array_push(global.crafting_data, new CraftingData(_data.id, _data[$ "amount"] ?? 1)
            .set_crafting_stations(_data[$ "crafting_stations"])
            .set_ingredients(_data.ingredients));
    }
    
    delete _json;
}