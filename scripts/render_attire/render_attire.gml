function render_attire(_attire, _index, _x, _y, _xscale, _yscale, _is_blinking = false, _index_arm = undefined, _item = noone)
{
    static __sprite_body = {
        body:           spr_Attire_Base_Body,
        body_arm_left:  spr_Attire_Base_Arm_Left,
        body_arm_right: spr_Attire_Base_Arm_Right,
        body_legs:      spr_Attire_Base_Legs
    }
    
    static __draw_body = function(_sprite, _index, _x, _y, _xscale, _yscale, _angle, _colour_match, _colour_replace)
    {
        static __u_match   = shader_get_uniform(shd_Colour_Replace, "u_match");
        static __u_replace = shader_get_uniform(shd_Colour_Replace, "u_replace");
        static __u_length  = shader_get_uniform(shd_Colour_Replace, "u_length");
        
        shader_set(shd_Colour_Replace);
        
        shader_set_uniform_i_array(__u_match, _colour_match);
        shader_set_uniform_i_array(__u_replace, _colour_replace);
        shader_set_uniform_i(__u_length, ATTIRE_COLOUR_AMOUNT);
        
        draw_sprite_ext(_sprite, _index, _x, _y, _xscale, _yscale, _angle, c_white, 1);
        
        shader_reset();
    }
    
    var _attire_data  = global.attire_data;
    
    var _colour_data  = global.attire_colour_data;
    var _colour_white = global.attire_colour_white_data;
    
    var _colour_body = _colour_data[_attire.body.colour];
    
    var _attire_elements = global.attire_elements_ordered;
     
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
            __draw_body(_sprite_body, ((_index_arm != undefined) && (_element == "body_arm_left") ? _index_arm : _index), _x, _y, _xscale, _yscale, image_angle, _colour_white, _colour_body);
            
            continue;
        }
        
        if (_is_blinking) && (_element == "eyes") continue;
        
        if (is_array(_element))
        {
            var _element_name  = _element[0];
            var _element_index = _element[1];
            
            var _data = _attire_data[$ _element_name];
            
            if (_data == undefined) continue;
            
            var _part = _attire[$ _element_name];
            
            var _part_index  = _part.index;
            var _part_colour = _part.colour;
            
            var _ = _data[_part_index];
            
            var _image_index_arm = ((_index_arm != undefined) && ((_element_name == "shirt") || (_element_name == "shirt_detail")) && (_element_index == 2) ? _index_arm : _index);
            
            if (_ == undefined) continue;
            
            var _sprite_colour = _.get_sprite_colour();
            
            if (_sprite_colour != undefined)
            {
                if (!is_array(_sprite_colour))
                {
                    __draw_body(_sprite_colour, _image_index_arm, _x, _y, _xscale, _yscale, image_angle, _colour_white, _colour_data[_part_colour]);
                }
                else if (_element_index < _.get_sprite_colour_length())
                {
                    __draw_body(_sprite_colour[_element_index], _image_index_arm, _x, _y, _xscale, _yscale, image_angle, _colour_white, _colour_data[_part_colour]);
                }
            }
            
            var _sprite_white = _.get_sprite_white();
            
            if (_sprite_white != undefined)
            {
                if (!is_array(_sprite_white))
                {
                    draw_sprite_ext(_sprite_white, _image_index_arm, _x, _y, _xscale, _yscale, image_angle, c_white, 1);
                }
                else if (_element_index < _.get_sprite_white_length())
                {
                    draw_sprite_ext(_sprite_white[_element_index], _image_index_arm, _x, _y, _xscale, _yscale, image_angle, c_white, 1);
                }
            }
        }
        else
        {
            var _data = _attire_data[$ _element];
            
            if (_data == undefined) continue;
            
            var _part = _attire[$ _element];
            
            var _part_index  = _part.index;
            var _part_colour = _part.colour;
            
            var _ = _data[_part_index];
            
            if (_ == undefined) continue;
            
            var _sprite_colour = _.get_sprite_colour();
            
            if (_sprite_colour != undefined)
            {
                __draw_body(_sprite_colour, _index, _x, _y, _xscale, _yscale, image_angle, _colour_white, _colour_data[_part_colour]);
            }
            
            var _sprite_white = _.get_sprite_white();
            
            if (_sprite_white != undefined)
            {
                draw_sprite_ext(_sprite_white, _index, _x, _y, _xscale, _yscale, image_angle, c_white, 1);
            }
        }
    }
}