/* UI button element - interactive button with click events */
/* @param {real} _x x position */
/* @param {real} _y y position */
/* @param {real} _width button width */
/* @param {real} _height button height */
/* @param {string} _text button text */
function UIButton(_x, _y, _width, _height, _text = "") : UIElement(_x, _y, _width, _height) constructor
{
    text = _text;
    
    colour = c_white;
    
    text_scale = 1;
    
    boolean = MENU_BUTTON_BOOL.IS_VISIBLE;
    
    
    /* visual properties */
    icon = undefined;
    
    icon_index = 0;
    
    icon_xscale = 1;
    icon_yscale = 1;
    
    
    sprite_index = spr_Menu_Button_Main;
    
    
    /* =============================================================================
       setters
       ============================================================================= */
    
    /* set the button sprite */
    /* @param {asset.gmsprite|string|struct} _sprite new sprite */
    static set_sprite_index = function(_sprite)
    {
    	if (is_struct(_sprite) && _sprite[$ "is_sprite_def"])
    	{
    		var _name = _sprite.sprite_name;
    		var _asset = asset_get_index(_name);
    		
    		
    		if (_asset != -1 && asset_get_type(_name) == asset_sprite)
    		{
    			sprite_index = _asset;
    		}
    	}
    	else if (is_string(_sprite))
    	{
    		var _asset = asset_get_index(_sprite);
    		
    		
    		if (_asset != -1 && asset_get_type(_sprite) == asset_sprite)
    		{
    			sprite_index = _asset;
    		}
    		else
    		{
    			PRINT($"[UIButton] warning: could not resolve sprite asset '{_sprite}'");
    		}
    	}
    	else
    	{
    		sprite_index = _sprite;
    	}
    	
    	return self;
    }
    
    
    /* set the button icon */
    /* @param {asset.gmsprite|string|struct} _icon new icon */
    static set_icon = function(_icon)
    {
    	if (is_struct(_icon) && _icon[$ "is_sprite_def"])
    	{
    		var _name = _icon.sprite_name;
    		var _asset = asset_get_index(_name);
    		
    		
    		if (_asset != -1 && asset_get_type(_name) == asset_sprite)
    		{
    			icon = _asset;
    		}
    	}
    	else if (is_string(_icon))
    	{
    		var _asset = asset_get_index(_icon);
    		
    		
    		if (_asset != -1 && asset_get_type(_icon) == asset_sprite)
    		{
    			icon = _asset;
    		}
    		else
    		{
    			PRINT($"[UIButton] warning: could not resolve icon asset '{_icon}'");
    		}
    	}
    	else
    	{
    		icon = _icon;
    	}
    	
    	return self;
    }
    
    
    static update = function()
    {
        if !(visible) exit;
        
        
        /* update children */
        var _child_count = array_length(children);
        
        for (var i = _child_count - 1; i >= 0; --i)
        {
            children[i].update();
        }
        
        
        var _abs_x = get_absolute_x();
        var _abs_y = get_interaction_y();
        
        var _mx = global.gui_mouse_x;
        var _my = global.gui_mouse_y;
        
        var _left = _abs_x;
        var _top = _abs_y;
        
        var _right = _left + width;
        var _bottom = _top + height;
        
        var _is_hovered = (_mx >= _left && _mx <= _right && _my >= _top && _my <= _bottom);
        
        /* check if clipped by a parent scroll area's scissor */
        var _p = parent;
        while (_p != undefined)
        {
            if (instanceof(_p) == "UIScrollArea")
            {
                var _p_left = _p.get_absolute_x();
                var _p_top = _p.get_absolute_y();
                var _p_right = _p_left + _p.width;
                var _p_bottom = _p_top + _p.height;
                
                if (_mx < _p_left || _mx > _p_right || _my < _p_top || _my > _p_bottom)
                {
                    _is_hovered = false;
                    
                    break;
                }
            }
            
            _p = _p.parent;
        }
        
        if (_is_hovered && !(global.ui_hover_consumed ?? false))
        {
            boolean |= MENU_BUTTON_BOOL.IS_HOVER;
            
            global.ui_hover_consumed = true;
            
            if !(global.ui_input_consumed) && (mouse_check_button_pressed(mb_left))
            {
                boolean |= MENU_BUTTON_BOOL.IS_HOLDING;
                
                global.ui_input_consumed = true;
                
                
                if !(boolean & MENU_BUTTON_BOOL.IS_SELECTED)
                {
                    boolean |= MENU_BUTTON_BOOL.IS_SELECTED;
                    
                    
                    sfx_play("phantasia:sfx/menu/button/select", global.settings.audio_ui);
                    
                    
                    emit_event("on_select");
                }
            }
        }
        else
        {
            if (boolean & MENU_BUTTON_BOOL.IS_HOVER)
            {
                boolean ^= MENU_BUTTON_BOOL.IS_HOVER;
            }
            
            
            if (boolean & MENU_BUTTON_BOOL.IS_SELECTED)
            {
                sfx_play("phantasia:sfx/menu/button/deselect", global.settings.audio_ui);
                
                
                boolean ^= MENU_BUTTON_BOOL.IS_SELECTED;
            }
        }
        
        
        if (boolean & MENU_BUTTON_BOOL.IS_HOLDING)
        {
            emit_event("on_select_hold");
        }
        
        
        if (mouse_check_button_released(mb_left))
        {
            if (boolean & MENU_BUTTON_BOOL.IS_SELECTED)
            {
                sfx_play("phantasia:sfx/menu/button/deselect", global.settings.audio_ui);
                
                
                boolean ^= MENU_BUTTON_BOOL.IS_SELECTED;
                
                
                if (_is_hovered)
                {
                    emit_event("on_select_release");
                }
            }
            
            
            if (boolean & MENU_BUTTON_BOOL.IS_HOLDING)
            {
                boolean ^= MENU_BUTTON_BOOL.IS_HOLDING;
            }
        }
        
        
        /* update bindings */
        update_bindings();
    }
    
    
    static draw_content = function()
    {
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        
        var _base_scale = ui_get_base_scale();
        
        var _base_scale_x = _base_scale.x;
        var _base_scale_y = _base_scale.y;
        
        
        var _x = _abs_x * _base_scale_x;
        var _y = _abs_y * _base_scale_y;
        
        
        var _xscale = (width / 16) * _base_scale_x;
        var _yscale = (height / 16) * _base_scale_y;
        
        
        var _asset_name = sprite_get_name(sprite_index);
        var _asset_edge = asset_get_index(_asset_name + "_Edge");
        
        var _asset_exists = sprite_exists(_asset_edge);
        var _asset_offset = (_asset_exists ? sprite_get_height(_asset_edge) * _yscale : 0);
        
        
        var _draw_x = _x + (width * _base_scale_x / 2);
        var _draw_y = _y + (height * _base_scale_y / 2);
        
        
        /* determine if selected/holding for visual offset */
        var _is_active = (boolean & (MENU_BUTTON_BOOL.IS_SELECTED | MENU_BUTTON_BOOL.IS_HOLDING));
        
        var _color = (_is_active ? c_ltgray : c_white);
        var _offset = (_is_active ? _asset_offset : 0);
        
        
        if (boolean & MENU_BUTTON_BOOL.IS_VISIBLE)
        {
            /* draw hover selection frame */
            if (boolean & MENU_BUTTON_BOOL.IS_HOVER) || (_is_active)
            {
                var _sw = (width * _base_scale_x) + 2;
                var _sh = (height * _base_scale_y) + 2;
                
                
                draw_sprite_stretched_ext(spr_Menu_Button_Select, 0, _x - 1, _y - 1 + _offset, _sw, _sh, c_white, 1);
            }
            
            
            /* draw bottom edge if not pressed */
            if !(_is_active) && (_asset_exists)
            {
                draw_sprite_ext(_asset_edge, 0, _draw_x, _draw_y + _asset_offset, _xscale, _yscale, 0, c_white, 1);
            }
            
            
            /* draw main button sprite */
            draw_sprite_ext(sprite_index, (_is_active ? 1 : 0), _draw_x, _draw_y + _offset, _xscale, _yscale, 0, _color, 1);
        }
        
        
        /* draw icon and text */
        var _loca_scale = global.loca_font_scale * _base_scale_x;
        
        
        if (text != "") && (icon != undefined)
        {
            var _tx = _draw_x + (sprite_get_width(icon) * icon_xscale * _base_scale_x / 2);
            var _ix = _draw_x - (string_width(text) * _loca_scale / 2);
            
            
            draw_sprite_ext(icon, icon_index, _ix, _draw_y + _offset, _base_scale_x * icon_xscale, _base_scale_y * icon_yscale, 0, _color, 1);
            
            
            render_text(_tx, _draw_y + _offset, text, _base_scale_x, _base_scale_y, 0, _color, 1);
        }
        else if (text != "")
        {
            render_text(_draw_x, _draw_y + _offset, text, _base_scale_x, _base_scale_y, 0, _color, 1);
        }
        else if (icon != undefined)
        {
            draw_sprite_ext(icon, icon_index, _draw_x, _draw_y + _offset, _base_scale_x * icon_xscale, _base_scale_y * icon_yscale, 0, _color, 1);
        }
    }
}
