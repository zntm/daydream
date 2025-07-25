global.item_data = {}

function init_item(_directory, _namespace)
{
    var _files = file_read_directory(_directory);
    var _files_length = array_length(_files);
    
    for (var i = 0; i < _files_length; ++i)
    {
        var _file = _files[i];
        
        dbg_timer("init_item");
        
        var _json = tag_value_parse(buffer_load_json($"{_directory}/{_file}/data.json"));
        
        var _item_data = new ItemData(_namespace, _file);
        
        _item_data.set_type(_json.type);
        _item_data.set_rarity(_json[$ "rarity"]);
        _item_data.set_inventory(_json[$ "inventory"]);
        _item_data.set_animation_type(_json[$ "animation_type"]);
        _item_data.set_properties(_json[$ "properties"]);
        _item_data.set_placement(_json[$ "placement"]);
        _item_data.set_harvest(_json[$ "harvest"]);
        _item_data.set_drop(_json[$ "drop"]);
        _item_data.set_durability(_json[$ "durability"]);
        _item_data.set_sfx(_json[$ "sfx"]);
        _item_data.set_on_random_tick(_json[$ "on_random_tick"]);
        
        var _sprite_data = _json.sprite;
        
        var _sprite_xoffset = _sprite_data.xoffset;
        var _sprite_yoffset = _sprite_data.yoffset;
        
        var _sprite = sprite_add($"{_directory}/{_file}/sprite.png", _sprite_data.length, false, false, _sprite_xoffset, _sprite_yoffset);
        
        _item_data.set_sprite(_sprite);
        
        var _collision_box = _json[$ "collision_box"];
        
        _item_data.set_collision_box(_collision_box ?? {
            left: _sprite_xoffset,
            top:  _sprite_yoffset,
            right:  sprite_get_width(_sprite),
            bottom: sprite_get_height(_sprite),
            type: "rectangle"
        });
        
        _item_data.set_edge_padding(_sprite_data[$ "edge_padding"]);
        
        carbasa_sprite_add("item", _sprite, $"{_namespace}:{_file}");
        
        global.item_data[$ $"{_namespace}:{_file}"] = _item_data;
        
        delete _json;
        
        dbg_timer("init_item", $"[Init] Loaded Item: \'{_file}\'");
    }
    
    show_debug_message(json_stringify(global.carbasa_page_position.item, 1))
    show_debug_message($"{global.carbasa_surface_size.item & 0xffff} {(global.carbasa_surface_size.item >> 16) & 0xffff}")
}