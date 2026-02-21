function render_attire(_attire, _index, _x, _y, _xscale, _yscale, _is_blinking = false, _index_arm = undefined, _item = noone)
{
    static __sprite_body = {
        body:           spr_Attire_Base_Body,
        body_arm_left:  spr_Attire_Base_Arm_Left,
        body_arm_right: spr_Attire_Base_Arm_Right,
        body_legs:      spr_Attire_Base_Legs
    }
    
    static __draw_body = function(_sprite_or_asset, _index, _x, _y, _xscale, _yscale, _angle, _colour_match, _colour_replace)
    {
        static __u_match   = shader_get_uniform(shd_Colour_Replace, "u_match");
        static __u_replace = shader_get_uniform(shd_Colour_Replace, "u_replace");
        static __u_length  = shader_get_uniform(shd_Colour_Replace, "u_length");
        
        shader_set(shd_Colour_Replace);
        
        shader_set_uniform_f_array(__u_match, _colour_match);
        shader_set_uniform_f_array(__u_replace, _colour_replace);
        shader_set_uniform_f(__u_length, ATTIRE_COLOUR_AMOUNT);
        
        // Get sprite ID from SpriteAsset object or use raw sprite ID
        // Sprite origin is already set by sprite_add, so draw at base position
        var _sprite = is_struct(_sprite_or_asset) ? _sprite_or_asset.get_sprite() : _sprite_or_asset;
        
        draw_sprite_ext(_sprite, _index, _x, _y, _xscale, _yscale, _angle, c_white, 1);
        
        shader_reset();
    }
    
    static __draw_sprite_white = function(_sprite_or_asset, _index, _x, _y, _xscale, _yscale, _angle)
    {
        // Get sprite ID from SpriteAsset object or use raw sprite ID
        // Sprite origin is already set by sprite_add, so draw at base position
        var _sprite = is_struct(_sprite_or_asset) ? _sprite_or_asset.get_sprite() : _sprite_or_asset;
        
        draw_sprite_ext(_sprite, _index, _x, _y, _xscale, _yscale, _angle, c_white, 1);
    }
    
    var _attire_is_array = is_array(_attire);
    var _attire_data     = global.attire_data;
    
    var _colour_data  = global.attire_colour_data;
    var _colour_white = global.attire_colour_white_data;
    
    // Body colour is usually at index 0 in the array or in body.colour in struct
    var _body_colour_index = _attire_is_array ? _attire[0] : _attire.body.colour;
    var _colour_body = _colour_data[_body_colour_index];
    
    var _attire_elements = global.attire_elements_ordered;
    
    var _angle = self[$ "image_angle"] ?? 0;
     
    for (var i = 0; i < ATTIRE_ELEMENTS_ORDERED_LENGTH; ++i)
    {
        var _element = _attire_elements[i];
        
        if (instance_exists(_item)) && (_element == "body_arm_left")
        {
            draw_sprite_ext(_item.sprite_index, _item.image_index, _item.x, _item.y, _item.image_xscale, _item.image_yscale, _item.image_angle, c_white, 1);
        }
        
        var _sprite_body = __sprite_body[$ _element];
        
        if (_sprite_body != undefined)
        {
            __draw_body(_sprite_body, ((_index_arm != undefined) && (_element == "body_arm_left") ? _index_arm : _index), _x, _y, _xscale, _yscale, _angle, _colour_white, _colour_body);
            
            continue;
        }
        
        if (_is_blinking) && (_element == "eyes") continue;
        
        var _element_name  = is_array(_element) ? _element[0] : _element;
        var _element_index = is_array(_element) ? _element[1] : 0;
        
        var _data = _attire_data[$ _element_name];
        if (_data == undefined) continue;
        
        var _part_index  = 0;
        var _part_colour = 0;
        
        if (_attire_is_array)
        {
            // Map element name to array index
            switch (_element_name)
            {
                case "body":         _part_index = 0; _part_colour = _attire[0]; break;
                case "headwear":     _part_index = 0; _part_colour = 0;          break; // Headwear index not in current array?
                case "hair":         _part_index = _attire[1]; _part_colour = 0; break;
                case "eyes":         _part_index = 0; _part_colour = 0;          break;
                case "face":         _part_index = 0; _part_colour = 0;          break;
                case "shirt":        _part_index = _attire[2]; _part_colour = 0; break;
                case "shirt_detail": _part_index = 0; _part_colour = 0;          break;
                case "pants":        _part_index = 0; _part_colour = 0;          break;
                case "footwear":     _part_index = 0; _part_colour = 0;          break;
            }
        }
        else
        {
            var _part = _attire[$ _element_name];
            _part_index  = _part.index;
            _part_colour = _part.colour;
        }
        
        var _ = _data[_part_index];
        if (_ == undefined) continue;
        
        var _image_index = ((_index_arm != undefined) && ((_element_name == "shirt") || (_element_name == "shirt_detail")) && (_element_index == 2) ? _index_arm : _index);
        
        var _sprite_colour = _.get_sprite_colour();
        
        if (_sprite_colour != undefined)
        {
            if (is_array(_sprite_colour))
            {
                // Handle complex cases (nested arrays or frame-based arrays)
                if (is_array(_element) && (_element_index < array_length(_sprite_colour)))
                {
                    var _s = _sprite_colour[_element_index];
                    if (is_array(_s))
                    {
                         if (_image_index < array_length(_s))
                             __draw_body(_s[_image_index], 0, _x, _y, _xscale, _yscale, _angle, _colour_white, _colour_data[_part_colour]);
                    }
                    else
                    {
                         __draw_body(_s, _image_index, _x, _y, _xscale, _yscale, _angle, _colour_white, _colour_data[_part_colour]);
                    }
                }
                else if (_image_index < array_length(_sprite_colour))
                {
                    __draw_body(_sprite_colour[_image_index], 0, _x, _y, _xscale, _yscale, _angle, _colour_white, _colour_data[_part_colour]);
                }
            }
            else
            {
                __draw_body(_sprite_colour, _image_index, _x, _y, _xscale, _yscale, _angle, _colour_white, _colour_data[_part_colour]);
            }
        }
        
        var _sprite_white = _.get_sprite_white();
        
        if (_sprite_white != undefined)
        {
            if (is_array(_sprite_white))
            {
                if (is_array(_element) && (_element_index < array_length(_sprite_white)))
                {
                    var _s = _sprite_white[_element_index];
                    if (is_array(_s))
                    {
                         if (_image_index < array_length(_s))
                             __draw_sprite_white(_s[_image_index], 0, _x, _y, _xscale, _yscale, _angle);
                    }
                    else
                    {
                         __draw_sprite_white(_s, _image_index, _x, _y, _xscale, _yscale, _angle);
                    }
                }
                else if (_image_index < array_length(_sprite_white))
                {
                    __draw_sprite_white(_sprite_white[_image_index], 0, _x, _y, _xscale, _yscale, _angle);
                }
            }
            else
            {
                __draw_sprite_white(_sprite_white, _image_index, _x, _y, _xscale, _yscale, _angle);
            }
        }
    }
}
