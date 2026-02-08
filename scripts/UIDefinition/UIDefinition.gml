/// @desc UI Definition - compiled representation of a UI element
/// This is the data structure that gets instantiated into live UIElements

/// @desc Element type mapping to GML constructors
enum UI_ELEMENT_TYPE
{
    AREA,       // UIBox
    WINDOW,     // UIBox + window features
    POPUP,      // UIBox + modal
    PAGE,       // UIBox (tab page)
    SCROLL,     // UIScrollView
    TEXT,       // UIText
    BUTTON,     // UIButton
    TEXTBOX,    // UIInputField
    IMAGE,      // UIImage
    BAR,        // UISlider (display mode)
    SLIDER      // UISlider (interactive)
}

/// @desc Size value that can be absolute or percentage
function UISizeValue(_value, _is_percentage = false) constructor
{
    value = _value;
    is_percentage = _is_percentage;
    
    /// @desc Resolve the size given a parent size
    /// @param {Real} _parent_size Parent dimension
    /// @returns {Real} Resolved size
    static resolve = function(_parent_size)
    {
        if (is_percentage)
        {
            return (_parent_size * value) / 100;
        }
        return value;
    }
    
    /// @desc Create a copy
    static clone = function()
    {
        return new UISizeValue(value, is_percentage);
    }
}

/// @desc UI Definition - represents a compiled UI element
function UIDefinition(_name, _element_type = UI_ELEMENT_TYPE.AREA) constructor
{
    name = _name;
    element_type = _element_type;
    
    // --- Properties ---
    properties = {};      // Key -> value (resolved literals)
    
    // --- Size properties (special handling for percentages) ---
    width = undefined;    // UISizeValue or undefined (fit content)
    height = undefined;
    min_width = undefined;
    min_height = undefined;
    max_width = undefined;
    max_height = undefined;
    
    // --- Position ---
    x = 0;
    y = 0;
    
    // --- Layout ---
    layout = undefined;       // "vertical", "horizontal", "grid", "block"
    spacing = 0;
    justify = undefined;
    align = undefined;
    
    // --- Spacing ---
    padding = undefined;      // [top, right, bottom, left] or single value
    margin = undefined;
    
    // --- Styling ---
    background = undefined;   // { color, alpha } or color
    border = undefined;       // { color, width }
    corner_radius = 0;
    
    // --- Text ---
    text = undefined;         // String, binding, or locale
    text_colour = undefined;
    text_scale = undefined;
    text_align = undefined;
    
    // --- Image ---
    sprite = undefined;
    surface_binding = undefined;
    image_index = 0;
    scale_mode = undefined;
    
    // --- Window ---
    movable = false;
    resizable = false;
    title = undefined;
    closable = false;
    
    // --- Input ---
    placeholder = undefined;
    max_length = undefined;
    input_mode = undefined;
    allowed_chars = undefined;
    
    // --- Visibility / State ---
    visible = true;
    enabled = true;
    
    // --- Flex ---
    flex = undefined;
    anchor = undefined;
    
    // --- Transitions ---
    transition_in = undefined;   // { type, duration }
    transition_out = undefined;
    
    // --- Data Bindings ---
    // Map of property name -> binding key
    bindings = {};
    
    // --- Event Handlers ---
    // Map of event name -> script ID
    events = {};
    
    // --- Children ---
    children = [];    // Array of UIDefinition
    
    // --- Link Configuration (set at spawn time) ---
    // This is a fluent interface for setting links before spawning
    _pending_links = {};
    
    /// @desc Set a link binding for a property
    /// @param {String} _key The binding key referenced in the UI definition
    /// @param {Function} _resolver Function that returns the current value
    /// @returns {Struct.UIDefinition} Self for chaining
    static set_link = function(_key, _resolver)
    {
        _pending_links[$ _key] = _resolver;
        return self;
    }
    
    /// @desc Clone this definition (for spawning multiple instances)
    static clone = function()
    {
        var _copy = new UIDefinition(name, element_type);
        
        // Copy all properties
        var _keys = struct_get_names(properties);
        for (var i = 0; i < array_length(_keys); ++i)
        {
            _copy.properties[$ _keys[i]] = properties[$ _keys[i]];
        }
        
        // Copy size values
        _copy.width = (width != undefined) ? width.clone() : undefined;
        _copy.height = (height != undefined) ? height.clone() : undefined;
        _copy.min_width = min_width;
        _copy.min_height = min_height;
        _copy.max_width = max_width;
        _copy.max_height = max_height;
        
        // Copy position
        _copy.x = x;
        _copy.y = y;
        
        // Copy layout
        _copy.layout = layout;
        _copy.spacing = spacing;
        _copy.justify = justify;
        _copy.align = align;
        _copy.padding = padding;
        _copy.margin = margin;
        
        // Copy styling
        _copy.background = background;
        _copy.border = border;
        _copy.corner_radius = corner_radius;
        
        // Copy text
        _copy.text = text;
        _copy.text_colour = text_colour;
        _copy.text_scale = text_scale;
        _copy.text_align = text_align;
        
        // Copy image
        _copy.sprite = sprite;
        _copy.surface_binding = surface_binding;
        _copy.image_index = image_index;
        _copy.scale_mode = scale_mode;
        
        // Copy window
        _copy.movable = movable;
        _copy.resizable = resizable;
        _copy.title = title;
        _copy.closable = closable;
        
        // Copy input
        _copy.placeholder = placeholder;
        _copy.max_length = max_length;
        _copy.input_mode = input_mode;
        _copy.allowed_chars = allowed_chars;
        
        // Copy state
        _copy.visible = visible;
        _copy.enabled = enabled;
        _copy.flex = flex;
        _copy.anchor = anchor;
        
        // Copy transitions
        _copy.transition_in = transition_in;
        _copy.transition_out = transition_out;
        
        // Copy bindings
        var _binding_keys = struct_get_names(bindings);
        for (var i = 0; i < array_length(_binding_keys); ++i)
        {
            _copy.bindings[$ _binding_keys[i]] = bindings[$ _binding_keys[i]];
        }
        
        // Copy events
        var _event_keys = struct_get_names(events);
        for (var i = 0; i < array_length(_event_keys); ++i)
        {
            _copy.events[$ _event_keys[i]] = events[$ _event_keys[i]];
        }
        
        // Clone children recursively
        for (var i = 0; i < array_length(children); ++i)
        {
            array_push(_copy.children, children[i].clone());
        }
        
        return _copy;
    }
}

/// @desc Result of compiling a UI file
function UICompileResult() constructor
{
    success = true;
    error = "";
    definitions = {};    // name -> UIDefinition (top-level elements)
    variables = {};      // name -> value (resolved variables)
}
