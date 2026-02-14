/// @desc UI Area Element - container for layout
/// @param {Real} _x X position
/// @param {Real} _y Y position
/// @param {Real} _width Area width
/// @param {Real} _height Area height
function UIArea(_x, _y, _width, _height) : UIElement(_x, _y, _width, _height) constructor {
    // Areas are transparent by default
    background_color = undefined;
    
    // Layout defaults
    layout = UI_LAYOUT.NONE;
    spacing = 0;
    
    static draw_content = function() {
        // Areas are invisible containers by default
        // But can have background if set
    }
}
