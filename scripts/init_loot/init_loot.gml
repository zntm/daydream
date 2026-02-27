global.loot_data = {}

function init_loot(_namespace = "phantasia", _directory)
{
    var _files = file_read_directory(_directory, true);
    
    for (var i = array_length(_files) - 1; i >= 0; --i)
    {
        var _file = _files[i];
        
        var _array = buffer_load_json(_file);
        
        if (!is_array(_array)) continue;
        
        var _length = array_length(_array);
        
        if (_length == 0) continue;
        
        var _id = string_delete(_file, string_length(_id) - 4, 5);
        var _loot_data = new LootData(_namespace, _id);
        
        for (var j = _length - 1; j >= 0; --j)
        {
            var _data = _array[j];
            
            _loot_data
                .set_entries(j, _data[$ "entries"])
                .set_rolls(j, _data[$ "rolls"]);
        }
        
        global.loot_data[$ $"{_namespace}:{_id}"] = _loot_data;
    }
}

function LootData(_namespace, _id) : ParentData(_namespace, _id) constructor
{
    static set_entries = function(_index, _entries)
    {
        if (_entries == undefined) || (!is_array(_entries))
        {
            return self;
        }
        
        for (var i = array_length(_entries) - 1; i >= 0; --i)
        {
            var _entry = _entries[i];
        }
        
        return self;
    }
    
    static get_entries = function()
    {
        return self[$ "___entries"];
    }
    
    static get_entries_length = function()
    {
        return self[$ "___entries_length"] ?? 0;
    }
    
    static set_rolls = function(_index, _rolls)
    {
        if (_rolls == undefined)
        {
            return self;
        }
        
        ___rolls = smart_value_parse(_rolls);
        
        return self;
    }
    
    static get_rolls = function()
    {
        return self[$ "___rolls"] ?? 0;
    }
}

/*
[
    {
        "entries": [
            {
                "item": {
                    "id": "phantasia:coal",
                    "amount": {
                        "type": "irandom",
                        "values": {
                            "min": 2,
                            "max": 4
                        }
                    }
                },
                "weight": 1
            },
            {
                "item": {
                    "id": "phantasia:twig",
                    "amount": {
                        "type": "irandom",
                        "values": {
                            "min": 1,
                            "max": 2
                        }
                    }
                },
                "weight": 1
            },
            {
                "value": "$EMPTY",
                "weight": 2
            }
        ],
        "rolls": {
            "type": "irandom",
            "values": {
                "min": 3,
                "max": 8
            }
        }
    }
]
*/
