/* ui page element - tab/page in a container */
/* @param {real} _x x position */
/* @param {real} _y y position */
/* @param {real} _width page width */
/* @param {real} _height page height */
/* @param {string} _page_name page identifier */
function UIPage(_x, _y, _width, _height, _page_name) : UIElement(_x, _y, _width, _height) constructor 
{
    page_name = _page_name;
    
    active_page = ""; /* set by parent container */
    
    
    static update = function() 
    {
        /* only update if this page is active */
        if (page_name != active_page) exit;
        
        
        update_bindings();
        
        
        var _child_count = array_length(children);
        
        for (var i = _child_count - 1; i >= 0; --i) 
        {
            children[i].update();
        }
    }
    
    
    static draw = function() 
    {
        /* only draw if this page is active */
        if (page_name != active_page) exit;
        
        
        var _base_scale = ui_get_base_scale();
        var _abs_x      = get_absolute_x();
        var _abs_y      = get_absolute_y();
        
        var _x1 = _abs_x * _base_scale.x;
        var _y1 = _abs_y * _base_scale.y;
        
        
        draw_content();
        
        
        /* execute custom draw callback if set */
        if (on_draw != undefined)
        {
            on_draw(_x1, _y1, _base_scale.x, _base_scale.y);
        }
        
        
        var _child_count = array_length(children);
        
        for (var i = _child_count - 1; i >= 0; --i) 
        {
            children[i].draw();
        }
    }
    
    
    /* check if this page is currently active */
    static is_active = function() 
    {
        return (page_name == active_page);
    }
}
