/// @desc Loom System - Node-based graph system for world generation
/// Core structs for graphs, nodes, pins, and connections

// ============================================================================
// LOOM PIN - Connection point on a node
// ============================================================================

/// @desc Represents an input or output connection point on a node
/// @param {String} _name Pin identifier
/// @param {String} _type Data type ("value", "bool", "biome", "struct", "any")
/// @param {Bool} _is_output True if output pin, false if input
function LoomPin(_name, _type, _is_output) constructor
{
    name = _name;
    type = _type;
    is_output = _is_output;
    
    // Current value (cached after evaluation)
    value = undefined;
    bounds = [0, 0]; // [min, max] range (cached after bounds evaluation)
    
    // For input pins: reference to connected output pin
    connected_pin = undefined;
    
    // Visual position (relative to node)
    rel_x = 0;
    rel_y = 0;
    
    /// @desc Get the value of this pin
    /// @param {Struct} _context Evaluation context
    /// @returns {Any} Pin value
    static get_value = function(_context)
    {
        if (is_output)
        {
            // Output pins return cached value (set by node.process())
            return value;
        }
        else
        {
            // Input pins pull from connected output
            if (connected_pin != undefined)
            {
                return connected_pin.get_value(_context);
            }
            return value; // Default value if not connected
        }
    }
    
    /// @desc Get the bounds of this pin
    /// @param {Struct} _ctx_min Minimum coordinate context
    /// @param {Struct} _ctx_max Maximum coordinate context
    /// @returns {Array} [min, max] range
    static get_bounds = function(_ctx_min, _ctx_max)
    {
        if (is_output)
        {
            return bounds;
        }
        else
        {
            if (connected_pin != undefined)
            {
                return connected_pin.get_bounds(_ctx_min, _ctx_max);
            }
            return [value ?? 0, value ?? 0];
        }
    }
    
    /// @desc Set default value for unconnected input
    /// @param {Any} _value Default value
    static set_default = function(_value)
    {
        value = _value;
        return self;
    }
    
    /// @desc Connect this input pin to an output pin
    /// @param {Struct.LoomPin} _output_pin The output pin to connect to
    static connect = function(_output_pin)
    {
        if (!is_output && _output_pin.is_output)
        {
            connected_pin = _output_pin;
        }
        return self;
    }
    
    /// @desc Disconnect this input pin
    static disconnect = function()
    {
        connected_pin = undefined;
        return self;
    }
    
    /// @desc Check if this pin is connected
    static is_connected = function()
    {
        return connected_pin != undefined;
    }
}

// ============================================================================
// LOOM NODE - Base node class
// ============================================================================

/// @desc Base class for all Loom nodes
/// @param {String} _type Node type identifier
function LoomNode(_type) constructor
{
    type = _type;
    id = irandom(999999); // Unique instance ID
    
    // Visual position in editor
    x = 0;
    y = 0;
    width = 120;
    height = 60;
    
    // Pin collections
    inputs = {};
    outputs = {};
    input_order = [];  // For consistent iteration order
    output_order = [];
    
    // Inline attributes (editable on node body)
    attributes = {};
    attribute_order = [];
    
    // Display name
    display_name = _type;
    
    /// @desc Add an input pin
    /// @param {String} _name Pin name
    /// @param {String} _type Pin data type
    /// @param {Any} _default Default value
    static add_input = function(_name, _type, _default = undefined)
    {
        var _pin = new LoomPin(_name, _type, false);
        _pin.set_default(_default);
        inputs[$ _name] = _pin;
        array_push(input_order, _name);
        ___recalculate_size();
        return self;
    }
    
    /// @desc Add an output pin
    /// @param {String} _name Pin name
    /// @param {String} _type Pin data type
    static add_output = function(_name, _type)
    {
        var _pin = new LoomPin(_name, _type, true);
        outputs[$ _name] = _pin;
        array_push(output_order, _name);
        ___recalculate_size();
        return self;
    }
    
    /// @desc Get input pin by name
    static get_input = function(_name)
    {
        return inputs[$ _name];
    }
    
    /// @desc Get output pin by name
    static get_output = function(_name)
    {
        return outputs[$ _name];
    }
    
    /// @desc Get input value by name
    /// @param {String} _name Input pin name
    /// @param {Struct} _context Evaluation context
    static get_input_value = function(_name, _context)
    {
        var _pin = inputs[$ _name];
        if (_pin != undefined)
        {
            return _pin.get_value(_context);
        }
        return undefined;
    }
    
    static set_output_value = function(_name, _value)
    {
        var _pin = outputs[$ _name];
        if (_pin != undefined)
        {
            _pin.value = _value;
        }
        return self;
    }
    
    /// @desc Get input bounds by name
    static get_input_bounds = function(_name, _ctx_min, _ctx_max)
    {
        var _pin = inputs[$ _name];
        return (_pin != undefined) ? _pin.get_bounds(_ctx_min, _ctx_max) : [0, 0];
    }
    
    /// @desc Set output bounds by name
    static set_output_bounds = function(_name, _min, _max)
    {
        var _pin = outputs[$ _name];
        if (_pin != undefined) _pin.bounds = [_min, _max];
    }
    
    /// @desc Process bounds (Interval Arithmetic)
    static bounds_process = function(_ctx_min, _ctx_max)
    {
        // Default: use process with avg context (NOT LOSSLESS, subclasses must override)
        // If it's a constant, it works fine.
    }
    
    /// @desc Process the node (compute outputs from inputs)
    /// Override this in subclasses
    /// @param {Struct} _context Evaluation context
    static process = function(_context)
    {
        // Base implementation does nothing
    }
    
    /// @desc Recalculate node size based on pins and attributes
    static ___recalculate_size = function()
    {
        var _pin_count = max(array_length(input_order), array_length(output_order));
        var _attr_count = array_length(attribute_order);
        height = 40 + (_pin_count * 20) + (_attr_count * 24);
        width = max(120, 80 + (_attr_count > 0 ? 40 : 0));
    }
    
    /// @desc Add an inline attribute
    /// @param {String} _name Attribute name
    /// @param {String} _type Attribute type ("value", "string", "color", "bool")
    /// @param {Any} _default Default value
    static add_attribute = function(_name, _type, _default = undefined)
    {
        attributes[$ _name] = {
            name: _name,
            type: _type,
            value: _default
        };
        array_push(attribute_order, _name);
        ___recalculate_size();
        return self;
    }
    
    /// @desc Get attribute value
    /// @param {String} _name Attribute name
    static get_attribute = function(_name)
    {
        var _attr = attributes[$ _name];
        return (_attr != undefined) ? _attr.value : undefined;
    }
    
    /// @desc Set attribute value
    /// @param {String} _name Attribute name
    /// @param {Any} _value New value
    static set_attribute = function(_name, _value)
    {
        var _attr = attributes[$ _name];
        if (_attr != undefined)
        {
            _attr.value = _value;
        }
        return self;
    }
    
    /// @desc Set editor position
    /// @param {Real} _x X position
    /// @param {Real} _y Y position
    static set_position = function(_x, _y)
    {
        x = _x;
        y = _y;
        return self;
    }
}

// ============================================================================
// LOOM CONNECTION - Visual connection between pins
// ============================================================================

/// @desc Represents a visual connection between two pins
/// @param {Struct.LoomPin} _from_pin Output pin
/// @param {Struct.LoomPin} _to_pin Input pin
function LoomConnection(_from_pin, _to_pin) constructor
{
    from_pin = _from_pin;
    to_pin = _to_pin;
    
    // Connect the pins
    _to_pin.connect(_from_pin);
}

// ============================================================================
// LOOM GRAPH - Container for the node network
// ============================================================================

/// @desc Container for a complete node graph
/// @param {String} _name Graph name
function LoomGraph(_name = "Untitled") constructor
{
    name = _name;
    nodes = [];
    connections = [];
    
    // Cached evaluation order (topologically sorted)
    ___eval_order = [];
    ___needs_sort = true;
    
    /// @desc Add a node to the graph
    /// @param {Struct.LoomNode} _node Node to add
    static add_node = function(_node)
    {
        array_push(nodes, _node);
        ___needs_sort = true;
        return _node;
    }
    
    /// @desc Remove a node from the graph
    /// @param {Struct.LoomNode} _node Node to remove
    static remove_node = function(_node)
    {
        // Remove connections involving this node
        for (var i = array_length(connections) - 1; i >= 0; --i)
        {
            var _conn = connections[i];
            // Check if connection involves this node's pins
            var _involves_node = false;
            
            var _in_names = struct_get_names(_node.inputs);
            for (var j = 0; j < array_length(_in_names); ++j)
            {
                if (_conn.to_pin == _node.inputs[$ _in_names[j]])
                {
                    _involves_node = true;
                    break;
                }
            }
            
            if (!_involves_node)
            {
                var _out_names = struct_get_names(_node.outputs);
                for (var j = 0; j < array_length(_out_names); ++j)
                {
                    if (_conn.from_pin == _node.outputs[$ _out_names[j]])
                    {
                        _involves_node = true;
                        break;
                    }
                }
            }
            
            if (_involves_node)
            {
                _conn.to_pin.disconnect();
                array_delete(connections, i, 1);
            }
        }
        
        // Remove node
        for (var i = 0; i < array_length(nodes); ++i)
        {
            if (nodes[i] == _node)
            {
                array_delete(nodes, i, 1);
                break;
            }
        }
        
        ___needs_sort = true;
        return self;
    }
    
    /// @desc Connect two pins
    /// @param {Struct.LoomPin} _from_pin Output pin
    /// @param {Struct.LoomPin} _to_pin Input pin
    static connect = function(_from_pin, _to_pin)
    {
        // Validate
        if (_from_pin == undefined || _to_pin == undefined)
        {
            show_debug_message("LoomGraph.connect: Undefined pin provided");
            return undefined;
        }

        if (!_from_pin.is_output || _to_pin.is_output)
        {
            show_debug_message("LoomGraph.connect: Invalid connection (must be output -> input)");
            return undefined;
        }
        
        // Disconnect existing connection on input
        if (_to_pin.is_connected())
        {
            disconnect_pin(_to_pin);
        }
        
        var _conn = new LoomConnection(_from_pin, _to_pin);
        array_push(connections, _conn);
        ___needs_sort = true;
        
        // Call on_connect callback on the target node if it exists
        for (var i = 0; i < array_length(nodes); ++i)
        {
            var _node = nodes[i];
            var _in_names = struct_get_names(_node.inputs);
            for (var j = 0; j < array_length(_in_names); ++j)
            {
                if (_node.inputs[$ _in_names[j]] == _to_pin)
                {
                    if (variable_struct_exists(_node, "on_connect"))
                    {
                        _node.on_connect(_in_names[j]);
                    }
                    break;
                }
            }
        }
        
        return _conn;
    }
    
    /// @desc Disconnect an input pin
    /// @param {Struct.LoomPin} _pin Input pin to disconnect
    static disconnect_pin = function(_pin)
    {
        if (_pin == undefined) return;
        
        for (var i = array_length(connections) - 1; i >= 0; --i)
        {
            if (connections[i].to_pin == _pin)
            {
                _pin.disconnect();
                array_delete(connections, i, 1);
                break;
            }
        }
        ___needs_sort = true;
        return self;
    }
    
    /// @desc Evaluate the graph with given context
    /// @param {Struct} _context Evaluation context (x, y, z, seed, world_data, etc.)
    /// @returns {Struct} Output values from result nodes
    static evaluate = function(_context)
    {
        if (___needs_sort)
        {
            ___topological_sort();
            ___needs_sort = false;
        }
        
        // Process nodes in order
        for (var i = 0; i < array_length(___eval_order); ++i)
        {
            ___eval_order[i].process(_context);
        }
        
        // Collect results from output nodes
        var _results = {};
        for (var i = 0; i < array_length(nodes); ++i)
        {
            var _node = nodes[i];
            if (string_pos("Result", _node.type) > 0 || string_pos("Output", _node.type) > 0)
            {
                var _out_names = struct_get_names(_node.outputs);
                for (var j = 0; j < array_length(_out_names); ++j)
                {
                    _results[$ _node.display_name + "." + _out_names[j]] = _node.outputs[$ _out_names[j]].value;
                }
            }
        }
        
        return _results;
    }
    
    /// @desc Evaluate bounds for the entire graph
    static evaluate_bounds = function(_ctx_min, _ctx_max)
    {
        if (___needs_sort)
        {
            ___topological_sort();
            ___needs_sort = false;
        }
        
        // Process bounds in order
        for (var i = 0; i < array_length(___eval_order); ++i)
        {
            ___eval_order[i].bounds_process(_ctx_min, _ctx_max);
        }
    }
    
    /// @desc Topological sort of nodes for evaluation order
    static ___topological_sort = function()
    {
        ___eval_order = [];
        
        // Simple Kahn's algorithm
        var _in_degree = {};
        var _node_count = array_length(nodes);
        
        // Initialize in-degrees
        for (var i = 0; i < _node_count; ++i)
        {
            _in_degree[$ string(nodes[i].id)] = 0;
        }
        
        // Count incoming edges
        for (var i = 0; i < array_length(connections); ++i)
        {
            var _conn = connections[i];
            // Find node that owns the to_pin
            for (var j = 0; j < _node_count; ++j)
            {
                var _node = nodes[j];
                var _in_names = struct_get_names(_node.inputs);
                for (var k = 0; k < array_length(_in_names); ++k)
                {
                    if (_node.inputs[$ _in_names[k]] == _conn.to_pin)
                    {
                        _in_degree[$ string(_node.id)]++;
                        break;
                    }
                }
            }
        }
        
        // Find nodes with no incoming edges
        var _queue = [];
        for (var i = 0; i < _node_count; ++i)
        {
            if (_in_degree[$ string(nodes[i].id)] == 0)
            {
                array_push(_queue, nodes[i]);
            }
        }
        
        // Process queue
        while (array_length(_queue) > 0)
        {
            var _node = _queue[0];
            array_delete(_queue, 0, 1);
            array_push(___eval_order, _node);
            
            // Reduce in-degree of connected nodes
            var _out_names = struct_get_names(_node.outputs);
            for (var i = 0; i < array_length(_out_names); ++i)
            {
                var _pin = _node.outputs[$ _out_names[i]];
                
                // Find connections from this pin
                for (var j = 0; j < array_length(connections); ++j)
                {
                    if (connections[j].from_pin == _pin)
                    {
                        // Find node that owns the to_pin
                        for (var k = 0; k < _node_count; ++k)
                        {
                            var _target = nodes[k];
                            var _in_names = struct_get_names(_target.inputs);
                            for (var l = 0; l < array_length(_in_names); ++l)
                            {
                                if (_target.inputs[$ _in_names[l]] == connections[j].to_pin)
                                {
                                    _in_degree[$ string(_target.id)]--;
                                    if (_in_degree[$ string(_target.id)] == 0)
                                    {
                                        array_push(_queue, _target);
                                    }
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// @desc Get node at position
    /// @param {Real} _x X position
    /// @param {Real} _y Y position
    /// @returns {Struct.LoomNode|undefined} Node at position or undefined
    static get_node_at = function(_x, _y)
    {
        for (var i = array_length(nodes) - 1; i >= 0; --i)
        {
            var _node = nodes[i];
            if (_x >= _node.x && _x <= _node.x + _node.width &&
                _y >= _node.y && _y <= _node.y + _node.height)
            {
                return _node;
            }
        }
        return undefined;
    }
    
    /// @desc Get which preview types are affected by a node (downstream traversal)
    /// @param {Struct.LoomNode} _node Starting node
    /// @returns {Struct} { terrain: bool, biome: bool }
    static get_affected_preview_types = function(_node)
    {
        var _res = { terrain: false, biome: false };
        if (_node == undefined) return _res;
        
        var _visited = {};
        var _queue = [_node];
        _visited[$ string(_node.id)] = true;
        
        while (array_length(_queue) > 0)
        {
            var _curr = _queue[0];
            array_delete(_queue, 0, 1);
            
            // Check if this is a result node
            if (_curr.type == "Result") _res.terrain = true;
            if (_curr.type == "ResultBiome") _res.biome = true;
            
            // If both are true, we can stop
            if (_res.terrain && _res.biome) break;
            
            // Traverse downstream
            var _out_names = struct_get_names(_curr.outputs);
            for (var i = 0; i < array_length(_out_names); ++i)
            {
                var _pin = _curr.outputs[$ _out_names[i]];
                
                // Find connections from this pin
                for (var j = 0; j < array_length(connections); ++j)
                {
                    if (connections[j].from_pin == _pin)
                    {
                        var _to_pin = connections[j].to_pin;
                        // Find node that owns this to_pin
                        for (var k = 0; k < array_length(nodes); ++k)
                        {
                            var _target = nodes[k];
                            // Check if this node has the pin
                            var _found = false;
                            var _in_names = struct_get_names(_target.inputs);
                            for (var l = 0; l < array_length(_in_names); ++l)
                            {
                                if (_target.inputs[$ _in_names[l]] == _to_pin)
                                {
                                    _found = true;
                                    break;
                                }
                            }
                            
                            if (_found && !struct_exists(_visited, string(_target.id)))
                            {
                                _visited[$ string(_target.id)] = true;
                                array_push(_queue, _target);
                            }
                        }
                    }
                }
            }
        }
        
        return _res;
    }
}
