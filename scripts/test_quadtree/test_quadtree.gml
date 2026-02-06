/// @desc Test Quadtree functionality
function test_quadtree()
{
    show_debug_message("--- START QUADTREE TEST ---");
    
    // 1. Create Quadtree
    var _qt = new Quadtree(0, 0, 100, 100, 4, 4);
    
    // 2. Insert Objects
    var _obj1 = { x: 10, y: 10, width: 10, height: 10, id: "A" }
    var _obj2 = { x: 15, y: 15, width: 10, height: 10, id: "B" } // Overlaps A
    var _obj3 = { x: 80, y: 80, width: 10, height: 10, id: "C" } // Far away
    
    _qt.insert(_obj1);
    _qt.insert(_obj2);
    _qt.insert(_obj3);
    
    // 3. Query Rect
    var _res1 = _qt.query_rect(0, 0, 50, 50);
    if (array_length(_res1) != 2) show_debug_message("FAIL: Query Rect expected 2, got " + string(array_length(_res1)));
    else show_debug_message("PASS: Query Rect");
    
    var _res2 = _qt.query_rect(70, 70, 90, 90);
    if (array_length(_res2) != 1) show_debug_message("FAIL: Query Rect C expected 1, got " + string(array_length(_res2)));
    else show_debug_message("PASS: Query Rect C");
    
    // 4. Collision Walk
    var _collisions = 0;
    _qt.walk_collisions(function(_a, _b) {
        show_debug_message("Collision Pair: " + _a.id + " - " + _b.id);
        // We expect A-B collision
        if ((_a.id == "A" && _b.id == "B") || (_a.id == "B" && _b.id == "A"))
        {
             // valid
        }
    });
    
    // Note: walk_collisions iterates all pairs in the same node.
    // A and B are in the same node. C is in a different node.
    // If A and B are in root (capacity > 2), they are compared.
    // If we decrease capacity to force split...
    
    delete _qt;
    
    // Test Split
    show_debug_message("--- TEST SPLIT ---");
    var _qt2 = new Quadtree(0, 0, 100, 100, 1, 4); // Capacity 1 -> Split immediately
    _qt2.insert(_obj1); // Top Left
    _qt2.insert(_obj3); // Bottom Right
    
    // They should be in different nodes. walk_collisions of root should NOT find pair A-C because they don't overlap boundaries?
    // Wait, my walk_collisions checks "Child Collisions".
    // If A is in TL, C is in BR.
    // walk_collisions(root):
    //  objects is empty (pushed down).
    //  Recurse TL: has A. Objects: [A].
    //    A vs A's children: none.
    //  Recurse BR: has C. Objects: [C].
    // Pair (A, C) is NEVER checked. This is CORRECT for a collision optimizer.
    
    var _detected = false;
    _qt2.walk_collisions(function(_a, _b) {
        _detected = true;
    });
    
    if (!_detected) show_debug_message("PASS: No collision between distant objects");
    else show_debug_message("FAIL: False positive collision");
    
    delete _qt2;
    show_debug_message("--- END QUADTREE TEST ---");
}
