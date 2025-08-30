global.credit_data = [];

function init_credit(_directory)
{
    var _json = buffer_load_json(_directory).data;
    
    var _length = array_length(_json);
    
    for (var i = 0; i < _length; ++i)
    {
        var _data = _json[i];
        
        dbg_timer("init_credit");
        
        var _colour = _data[$ "colour"];
        
        var _entries = _data.entries;
        var _entries_length = array_length(_entries);
        
        global.credit_data[@ i] = {
            header: _data.header,
            colour: ((_colour != undefined) ? hex_parse(_colour) : c_white),
            entries: [],
            entries_length: _entries_length
        }
        
        for (var j = 0; j < _entries_length; ++j)
        {
            var _entry = _entries[j];
            
            if (typeof(_entry) == "string")
            {
                array_push(global.credit_data[@ i].entries, {
                    name: _entry
                });
            }
            else
            {
                array_push(global.credit_data[@ i].entries, _entry);
            }
        }
        
        dbg_timer("init_credit", $"Loaded Credit: '{_data.header}'");
    }
    
    delete _json;
}