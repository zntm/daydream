/// @desc UI Page Element - tab/page in a container
/// @param {Real} _x X position
/// @param {Real} _y Y position
/// @param {Real} _width Page width
/// @param {Real} _height Page height
/// @param {String} _page_name Page identifier
function UIPage(_x, _y, _width, _height, _page_name) : UIElement(_x, _y, _width, _height) constructor {
    page_name = _page_name;
    active_page = ""; // Set by parent container
    
    static update = function() {
        // Only update if this page is active
        if (page_name != active_page) return;
        
        update_bindings();
        
        var _child_count = array_length(children);
        for (var i = 0; i < _child_count; i++) {
            children[i].update();
        }
    }
    
    static draw = function() {
        // Only draw if this page is active
        if (page_name != active_page) return;
        
        draw_content();
        
        var _child_count = array_length(children);
        for (var i = 0; i < _child_count; i++) {
            children[i].draw();
        }
    }
    
    /// @desc Check if this page is currently active
    static is_active = function() {
        return page_name == active_page;
    }
}
