/// @desc Generic Quadtree for spatial partitioning
/// @param {real} _x Bounds X
/// @param {real} _y Bounds Y
/// @param {real} _w Bounds Width
/// @param {real} _h Bounds Height
/// @param {real} _max_objects Max objects per node before split
/// @param {real} _max_levels Max depth levels
/// @param {real} _level Current level (internal)
function Quadtree(_x, _y, _w, _h, _max_objects = 10, _max_levels = 5, _level = 0) constructor
{
    bounds_x = _x;
    bounds_y = _y;
    bounds_w = _w;
    bounds_h = _h;
    
    max_objects = _max_objects;
    max_levels = _max_levels;
    level = _level;
    
    objects = [];
    nodes = array_create(4, undefined);
    has_children = false;
    
    /// @desc Clear the quadtree
    static clear = function()
    {
        objects = [];
        for (var i = 0; i < 4; ++i)
        {
            if (nodes[i] != undefined)
            {
                nodes[i].clear();
                delete nodes[i];
                nodes[i] = undefined;
            }
        }
        has_children = false;
    }
    
    /// @desc Split the node into 4 subnodes
    static split = function()
    {
        var _sub_w = bounds_w / 2;
        var _sub_h = bounds_h / 2;
        var _x = bounds_x;
        var _y = bounds_y;
        
        nodes[0] = new Quadtree(_x + _sub_w, _y, _sub_w, _sub_h, max_objects, max_levels, level + 1);          // Top Right
        nodes[1] = new Quadtree(_x, _y, _sub_w, _sub_h, max_objects, max_levels, level + 1);                   // Top Left
        nodes[2] = new Quadtree(_x, _y + _sub_h, _sub_w, _sub_h, max_objects, max_levels, level + 1);          // Bottom Left
        nodes[3] = new Quadtree(_x + _sub_w, _y + _sub_h, _sub_w, _sub_h, max_objects, max_levels, level + 1); // Bottom Right
        
        has_children = true;
    }
    
    /// @desc Get the index of the node that the object belongs to
    /// @param {any} _rect Object handle or struct
    /// @returns {real} Index 0-3, or -1 if it doesn't fit completely in a child
    static get_index = function(_rect)
    {
        var _rx, _ry, _rw, _rh;
        
        // Robust detection of instances vs structs
        if (instance_exists(_rect))
        {
            _rx = _rect.bbox_left;
            _ry = _rect.bbox_top;
            _rw = _rect.bbox_right - _rect.bbox_left;
            _rh = _rect.bbox_bottom - _rect.bbox_top;
        }
        else if (is_struct(_rect))
        {
            if (struct_exists(_rect, "pos_x")) // PhysicsBody
            {
                var _half_w = (_rect[$ "width"] ?? 8) / 2;
                var _half_h = (_rect[$ "height"] ?? 8) / 2;
                _rx = _rect.pos_x - _half_w;
                _ry = _rect.pos_y - _half_h;
                _rw = _half_w * 2;
                _rh = _half_h * 2;
            }
            else // Simple rect struct
            {
                _rx = _rect[$ "x"] ?? 0;
                _ry = _rect[$ "y"] ?? 0;
                _rw = _rect[$ "width"] ?? 0;
                _rh = _rect[$ "height"] ?? 0;
            }
        }
        else return -1;
    
        var _index = -1;
        var _vertical_midpoint = bounds_x + (bounds_w / 2);
        var _horizontal_midpoint = bounds_y + (bounds_h / 2);
        
        var _top_quadrant = (_ry < _horizontal_midpoint && _ry + _rh < _horizontal_midpoint);
        var _bottom_quadrant = (_ry > _horizontal_midpoint);
        
        if (_rx < _vertical_midpoint && _rx + _rw < _vertical_midpoint)
        {
            if (_top_quadrant) _index = 1;      // Top Left
            else if (_bottom_quadrant) _index = 2; // Bottom Left
        }
        else if (_rx > _vertical_midpoint)
        {
            if (_top_quadrant) _index = 0;      // Top Right
            else if (_bottom_quadrant) _index = 3; // Bottom Right
        }
        
        return _index;
    }
    
    /// @desc Insert an object into the tree
    /// @param {struct} _item
    static insert = function(_item)
    {
        if (has_children)
        {
            var _index = get_index(_item);
            
            if (_index != -1)
            {
                nodes[_index].insert(_item);
                return;
            }
        }
        
        array_push(objects, _item);
        
        if (array_length(objects) > max_objects && level < max_levels)
        {
            if (!has_children)
            {
                split();
            }
            
            var i = 0;
            while (i < array_length(objects))
            {
                var _obj = objects[i];
                var _index = get_index(_obj);
                
                if (_index != -1)
                {
                    array_delete(objects, i, 1);
                    nodes[_index].insert(_obj);
                }
                else
                {
                    i++;
                }
            }
        }
    }
    
    /// @desc Remove an object from the tree (slow, requires search)
    /// @param {struct} _item
    static remove = function(_item)
    {
        // Try to find in current objects
        var _idx = array_get_index(objects, _item);
        if (_idx != -1)
        {
            array_delete(objects, _idx, 1);
            return true;
        }
        
        // Try children
        if (has_children)
        {
            var _index = get_index(_item);
            if (_index != -1)
            {
                return nodes[_index].remove(_item);
            }
            else
            {
                // If index is -1, it *should* have been in this node's objects list.
                // But edge case: maybe it moved? 
                // For now, assume it was in objects if index is -1. 
                // Since we checked objects and didn't find it, we might need to search ALL children 
                // if we want to be safe (e.g. strict removal), but standard Quadtree expects consistent bounds.
                
                // Fallback: check all children just in case
                for (var i = 0; i < 4; ++i)
                {
                    if (nodes[i].remove(_item)) return true;
                }
            }
        }
        
        return false;
    }

    /// @desc Standard query for a rectangle
    static query_rect = function(_x1, _y1, _x2, _y2, _return_list = [])
    {
        // Check if query range overlaps this node's bounds
        // (If calling query_rect directly on a subnode, this is redundant but cheap)
        if (_x1 > bounds_x + bounds_w || _x2 < bounds_x || _y1 > bounds_y + bounds_h || _y2 < bounds_y)
        {
            return _return_list;
        }
        
        // Add all objects in this node that overlap
        // (Note: Objects in this node definitely overlap the *area* covered by this node 
        //  but might not overlap the query rect)
        var _len = array_length(objects);
        for (var i = 0; i < _len; ++i)
        {
            var _obj = objects[i];
            
            // Extract bounds 
             var _ox1, _oy1, _ox2, _oy2;
            if (struct_exists(_obj, "bbox_left"))
            {
                _ox1 = _obj.bbox_left;
                _oy1 = _obj.bbox_top;
                _ox2 = _obj.bbox_right;
                _oy2 = _obj.bbox_bottom;
            }
            else if (struct_exists(_obj, "pos_x"))
            {
                var _half_w = (_obj[$ "width"] ?? 8) / 2;
                var _half_h = (_obj[$ "height"] ?? 8) / 2;
                _ox1 = _obj.pos_x - _half_w;
                _oy1 = _obj.pos_y - _half_h;
                _ox2 = _obj.pos_x + _half_w;
                _oy2 = _obj.pos_y + _half_h;
            }
            else
            {
                _ox1 = _obj.x;
                _oy1 = _obj.y;
                _ox2 = _obj.x + _obj.width;
                _oy2 = _obj.y + _obj.height;
            }
            
            if (_ox1 < _x2 && _ox2 > _x1 && _oy1 < _y2 && _oy2 > _y1)
            {
                 array_push(_return_list, _obj);
            }
        }
        
        if (has_children)
        {
            nodes[0].query_rect(_x1, _y1, _x2, _y2, _return_list);
            nodes[1].query_rect(_x1, _y1, _x2, _y2, _return_list);
            nodes[2].query_rect(_x1, _y1, _x2, _y2, _return_list);
            nodes[3].query_rect(_x1, _y1, _x2, _y2, _return_list);
        }
        
        return _return_list;
    }
    
    // ========================================================================
    // BROAD PHASE COLLISION WALKER
    // ========================================================================
    
    /// @desc Broad phase collision pass.
    /// Finds all potentially colliding pairs in the tree and calls the callback.
    /// Optimizes by skipping quadrants that don't overlap with the object being checked.
    /// @param {function} _callback Function to call with (_obj_a, _obj_b)
    static walk_collisions = function(_callback)
    {
        // 1. Check objects within this node against each other
        var _len = array_length(objects);
        for (var i = 0; i < _len; ++i)
        {
            var _obj_a = objects[i];
            
            // A vs other A's in this node
            for (var j = i + 1; j < _len; ++j)
            {
                var _obj_b = objects[j];
                _callback(_obj_a, _obj_b);
            }
            
            // A vs all children (recursively)
            if (has_children)
            {
                check_child_collisions(_obj_a, _callback);
            }
        }
        
        // 2. Recurse into children
        if (has_children)
        {
            nodes[0].walk_collisions(_callback);
            nodes[1].walk_collisions(_callback);
            nodes[2].walk_collisions(_callback);
            nodes[3].walk_collisions(_callback);
        }
    }
    
    /// @desc Helper to check an object against all valid descendants
    /// @param {struct} _obj
    /// @param {function} _callback
    static check_child_collisions = function(_obj, _callback)
    {
        // Extract bounds for query
         var _ox1, _oy1, _ox2, _oy2;
        if (struct_exists(_obj, "bbox_left"))
        {
            _ox1 = _obj.bbox_left;
            _oy1 = _obj.bbox_top;
            _ox2 = _obj.bbox_right;
            _oy2 = _obj.bbox_bottom;
        }
        else if (struct_exists(_obj, "pos_x"))
        {
            var _half_w = (_obj[$ "width"] ?? 8) / 2;
            var _half_h = (_obj[$ "height"] ?? 8) / 2;
            _ox1 = _obj.pos_x - _half_w;
            _oy1 = _obj.pos_y - _half_h;
            _ox2 = _obj.pos_x + _half_w;
            _oy2 = _obj.pos_y + _half_h;
        }
        else
        {
            _ox1 = _obj.x;
            _oy1 = _obj.y;
            _ox2 = _obj.x + _obj.width;
            _oy2 = _obj.y + _obj.height;
        }
        
        // Check 4 sub-quadrants
        for (var i = 0; i < 4; ++i)
        {
            var _node = nodes[i];
            
            // BOUNDARY CHECK / "BULK SKIP"
            // If the object doesn't touch this quadrant, skip it entirely!
            if (_ox1 > _node.bounds_x + _node.bounds_w || _ox2 < _node.bounds_x || 
                _oy1 > _node.bounds_y + _node.bounds_h || _oy2 < _node.bounds_y)
            {
                continue; 
            }
            
            // Collide with items in this child node
            var _child_len = array_length(_node.objects);
            for (var j = 0; j < _child_len; ++j)
            {
                _callback(_obj, _node.objects[j]);
            }
            
            // Recurse deeper if needed
            if (_node.has_children)
            {
                _node.check_child_collisions(_obj, _callback);
            }
        }
    }
}
