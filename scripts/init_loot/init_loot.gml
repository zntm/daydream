global.loot_data = {};

function init_loot(_namespace = "phantasia", _directory)
{
    var _files = file_read_directory(_directory, true);

    for (var i = array_length(_files) - 1; i >= 0; --i)
    {
        var _file = _files[i];

        if (!string_ends_with(_file, ".json")) continue;

        var _json_path = $"{_directory}/{_file}";
        var _array     = buffer_load_json(_json_path);

        if (!is_array(_array)) continue;

        var _length = array_length(_array);

        if (_length == 0) continue;

        /* strip '.json' from the filename to get the id */
        var _id        = string_delete(_file, string_length(_file) - 4, 5);
        var _loot_data = new LootData(_namespace, _id);

        for (var j = _length - 1; j >= 0; --j)
        {
            var _data    = _array[j];
            var _entries = _data[$ "entries"];

            if (is_array(_entries))
            {
                var _entries_parsed = [];

                for (var k = array_length(_entries) - 1; k >= 0; --k)
                {
                    var _entry  = _entries[k];
                    var _parsed = {
                        weight: _entry[$ "weight"] ?? 1
                    };

                    if (struct_exists(_entry, "item"))
                    {
                        var _item      = _entry.item;
                        var _item_id   = init_asset_resolve(_namespace, _item.id);

                        if (init_asset_item_exists(_item_id))
                        {
                            _parsed.item = {
                                id:     _item_id,
                                amount: smart_value_parse(_item[$ "amount"])
                            };

                            array_push(_entries_parsed, _parsed);
                        }
                        else
                        {
                             PRINT($"[init_loot] '{_id}': item '{_item_id}' not loaded, skipping entry");
                        }
                    }
                    else if (struct_exists(_entry, "value"))
                    {
                        _parsed.value = _entry.value;

                        array_push(_entries_parsed, _parsed);
                    }
                }

                _loot_data.set_entries(j, _entries_parsed);
            }

            _loot_data.set_rolls(j, _data[$ "rolls"]);
        }

        global.loot_data[$ $"{_namespace}:{_id}"] = _loot_data;
    }
}

function LootData(_namespace, _id) : ParentData(_namespace, _id) constructor
{
    ___entries = [];
    ___rolls   = [];

    static set_entries = function(_index, _entries)
    {
        if (_entries == undefined) || (!is_array(_entries))
        {
            return self;
        }

        ___entries[@ _index] = _entries;

        return self;
    }

    static get_entries = function(_index = 0)
    {
        return ___entries[_index];
    }

    static get_entries_length = function()
    {
        return array_length(___entries);
    }

    static set_rolls = function(_index, _rolls)
    {
        if (_rolls == undefined)
        {
            return self;
        }

        ___rolls[@ _index] = smart_value_parse(_rolls);

        return self;
    }

    static get_rolls = function(_index = 0)
    {
        return ___rolls[_index];
    }
}
