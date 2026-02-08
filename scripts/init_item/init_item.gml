global.item_data = {}

function init_item(_directory, _namespace)
{
    var _files = file_read_directory(_directory);
    var _files_length = array_length(_files);
    
    for (var i = 0; i < _files_length; ++i)
    {
        var _file = _files[i];
        
        if (string_ends_with(_file, ".json"))
        {
            var _id = string_delete(_file, string_length(_file) - 4, 5);
            
            dbg_timer("init_item0");
            
            var _json = tag_value_parse(buffer_load_json($"{_directory}/{_file}"));
            
            if (is_struct(_json))
            {
                var _item_data = new ItemData(_namespace, _id);
                
                var _sprite = _json.sprite;
                
                _item_data.set_sprite(_sprite);
                
                var _item = _json[$ "item"];
                
                _item_data.set_inventory(_json.inventory);
                _item_data.set_item(_item);
                
                if (_item != undefined)
                {
                    _item_data.set_tile(_item[$ "tile"]);
                }
                
                _item_data.set_properties(_json[$ "properties"]);
                _item_data.set_type(_json.type);
                
                var _sprite_asset_obj = global.sprite_asset[$ _sprite];
                if (_sprite_asset_obj != undefined)
                {
                    var _real_sprite = _sprite_asset_obj.get_sprite();
                    var _col_box = _json[$ "collision_box"];
                    
                    var _type_box = TILE_COLLISION_BOX_TYPE.RECTANGLE;
                    var _left     = -sprite_get_xoffset(_real_sprite);
                    var _top      = -sprite_get_yoffset(_real_sprite);
                    var _width    = sprite_get_width(_real_sprite);
                    var _height   = sprite_get_height(_real_sprite);
                    
                    if (_col_box != undefined)
                    {
                        if (_col_box[$ "type"] == "triangle") _type_box = TILE_COLLISION_BOX_TYPE.TRIANGLE;
                        if (_col_box[$ "left"] != undefined)   _left   = _col_box.left;
                        if (_col_box[$ "top"] != undefined)    _top    = _col_box.top;
                        if (_col_box[$ "right"] != undefined)  _width  = _col_box.right;
                        if (_col_box[$ "bottom"] != undefined) _height = _col_box.bottom;
                    }
                    
                    _item_data.set_collision_box(_type_box, _left, _top, _width, _height);
                }
                
                if (_item_data.get_type() & (ITEM_TYPE_BIT.PLATFORM | ITEM_TYPE_BIT.SOLID | ITEM_TYPE_BIT.UNTOUCHABLE))
                {
                    atla_push("item", global.sprite_asset[$ _sprite].get_sprite(), _sprite);
                }
                
                global.item_data[$ $"{_namespace}:{_id}"] = _item_data;
                
                delete _json;
                
                dbg_timer("init_item", $"[Init] Loaded Item: \'{_id}\'");
            }
        }
    }
}