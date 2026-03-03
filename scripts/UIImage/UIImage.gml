/* ui image element - displays sprite or surface */
/* @param {real} _x x position */
/* @param {real} _y y position */
/* @param {asset.gmsprite|id.surface} _source image source */
function UIImage(_x, _y, _source) : UIElement(_x, _y, 0, 0) constructor 
{
    is_surface = false;
    
    source = _source;
    
    image_index = 0;
    
    image_xscale = 1;
    
    image_yscale = 1;
    
    image_angle = 0;
    
    colour = c_white;
    
    alpha = 1;
    
    
    /* set the image source */
    /* @param {asset.gmsprite|id.surface|string|struct} _source new source */
    static set_source = function(_source) 
    {
        /* handle $sprite(name) definition */
        if (is_struct(_source) && _source[$ "is_sprite_def"]) 
        {
            is_surface = false;
            
            var _name = _source.sprite_name;
            var _asset = asset_get_index(_name);
            
            
            if (_asset != -1 && asset_get_type(_name) == asset_sprite) 
            {
                source = _asset;
            } 
            else 
            {
                PRINT($"[UIImage] warning: could not resolve sprite '{_name}'");
                
                source = undefined;
            }
        } 
        /* handle $surface(name) definition */
        else if (is_struct(_source) && _source[$ "is_surface_def"]) 
        {
            is_surface = true;
            
            /* surface name is stored - actual surface id resolved at runtime via binding */
            source = _source.surface_name;
        } 
        /* handle string name (legacy) */
        else if (is_string(_source)) 
        {
            is_surface = false;
            
            var _asset = asset_get_index(_source);
            
            
            if (_asset != -1 && asset_get_type(_source) == asset_sprite) 
            {
                source = _asset;
            } 
            else 
            {
                PRINT($"[UIImage] warning: could not resolve sprite asset '{_source}'");
                
                source = undefined;
            }
        } 
        /* handle direct sprite/surface asset */
        else 
        {
            source = _source;
        }
        
        
        /* update dimensions */
        if (source != undefined) 
        {
            if (is_surface && surface_exists(source)) 
            {
                width = surface_get_width(source);
                height = surface_get_height(source);
            } 
            else if !(is_surface) && sprite_exists(source) 
            {
                width = sprite_get_width(source);
                height = sprite_get_height(source);
            }
        }
        
        return self;
    }
    
    
    static draw_content = function() 
    {
        if (source == undefined) exit;
        
        
        var _base_scale = ui_get_base_scale();
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        
        /* use base_scale for uniform pixel scaling to match positions */
        var _pixel_scale_x = _base_scale.x;
        var _pixel_scale_y = _base_scale.y;
        
        
        if (is_surface) 
        {
            if (surface_exists(source)) 
            {
                var _draw_x = _abs_x * _base_scale.x;
                var _draw_y = _abs_y * _base_scale.y;
                
                draw_surface_ext(source, _draw_x, _draw_y, image_xscale * _pixel_scale_x, image_yscale * _pixel_scale_y, image_angle, colour, alpha);
            }
        } 
        else if (sprite_exists(source)) 
        {
            /* get sprite origin for correct positioning */
            var _ox = sprite_get_xoffset(source);
            var _oy = sprite_get_yoffset(source);
            
            
            /* calculate draw position accounting for origin offset */
            /* position in .ui is top-left, but draw_sprite_ext draws from origin */
            var _draw_x = (_abs_x * _base_scale.x) + (_ox * _pixel_scale_x * image_xscale);
            var _draw_y = (_abs_y * _base_scale.y) + (_oy * _pixel_scale_y * image_yscale);
            
            
            draw_sprite_ext(source, image_index, _draw_x, _draw_y, image_xscale * _pixel_scale_x, image_yscale * _pixel_scale_y, image_angle, colour, alpha);
        }
    }
}
