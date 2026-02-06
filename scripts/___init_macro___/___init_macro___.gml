
#macro IS_MULTIPLAYER_ENABLED 0

#region Chunk

#macro TILE_EMPTY 0
#macro TILE_EMPTY_ID "empty"

#macro TILE_STRUCTURE_VOID -1

#macro TILE_SIZE_BIT 4
#macro TILE_SIZE (1 << TILE_SIZE_BIT)

#macro CHUNK_SIZE_BIT 4
#macro CHUNK_SIZE (1 << CHUNK_SIZE_BIT)

#macro CHUNK_DEPTH 8

#macro CHUNK_SIZE_DIMENSION (CHUNK_SIZE * TILE_SIZE)

#macro CHUNK_DEPTH_DEFAULT       3
#macro CHUNK_DEPTH_WALL          0
#macro CHUNK_DEPTH_TREE_BACK     2
#macro CHUNK_DEPTH_TREE_FRONT    5
#macro CHUNK_DEPTH_TREE          choose(CHUNK_DEPTH_TREE_BACK, CHUNK_DEPTH_TREE_FRONT)
#macro CHUNK_DEPTH_FOLIAGE_BACK  1
#macro CHUNK_DEPTH_FOLIAGE_FRONT 4
#macro CHUNK_DEPTH_FOLIAGE       choose(CHUNK_DEPTH_FOLIAGE_BACK, CHUNK_DEPTH_FOLIAGE_FRONT)
#macro CHUNK_DEPTH_LIQUID        7

#endregion

#region Menu

#macro MENU_TRANSITION_DURATION 0.3
#macro MENU_TRANSITION_FADE_SPEED 0.88
#macro MENU_TRANSITION_SCALE_MIN 0.9
#macro MENU_TRANSITION_SCALE_MAX 1.0

#endregion

#region Physics

// Gravity
#macro PHYSICS_GRAVITY_DEFAULT 3.7

// Movement Speed
#macro PHYSICS_MOVE_SPEED_GROUND 3.1
#macro PHYSICS_MOVE_ACCEL_GROUND 0.3

#macro PHYSICS_MOVE_SPEED_FLY 8.65
#macro PHYSICS_MOVE_ACCEL_FLY 0.25

#macro PHYSICS_MOVE_SPEED_SWIM 2.5
#macro PHYSICS_MOVE_ACCEL_SWIM 0.15
#macro PHYSICS_MOVE_DRAG_SWIM 0.92

#macro PHYSICS_MOVE_SPEED_CLIMB 2.0
#macro PHYSICS_MOVE_ACCEL_CLIMB 0.3

// Jump
#macro PHYSICS_JUMP_HEIGHT 28.5
#macro PHYSICS_JUMP_TIME 12
#macro PHYSICS_JUMP_FALLOFF 2.2
#macro PHYSICS_JUMP_COYOTE_TIME 8

#macro PHYSICS_WALL_JUMP_POWER 4.0
#macro PHYSICS_WALL_JUMP_VERTICAL_DAMPING 0.7

// Collision
#macro PHYSICS_TILE_CHECK_SIZE 8
#macro PHYSICS_TILE_CHECK_STEP 1
#macro PHYSICS_GLOBAL_THRESHOLD_NUDGE 4

// Knockback
#macro PHYSICS_KNOCKBACK_FORCE 4
#macro PHYSICS_KNOCKBACK_Y_RATIO 0.75

// Environment
#macro PHYSICS_TERMINAL_VELOCITY 24
#macro PHYSICS_BUOYANCY 0.5

#endregion

#macro GUI_SAFE_ZONE_X 24
#macro GUI_SAFE_ZONE_Y 24

#region Menu

#macro MENU_BUTTON_COLOUR c_white
#macro MENU_BUTTON_COLOUR_SELECTED c_ltgray

#macro MENU_TITLE_SPLASH_COLOUR #FFDC54

#macro MENU_WORLD_NAME_RANDOM_ONCE  choose("Once", "Thrice", "Twice")
#macro MENU_WORLD_NAME_RANDOM_START choose("The", "Thy", $"{choose("Galloping", "Infinity", MENU_WORLD_NAME_RANDOM_ONCE, "Whispering")}, in the")

#macro MENU_WORLD_NAME_PLACE choose("Area", "Borough", "Dimension", "District", "Domain", "Edge", "Expanse", "Frontier", "Frontline", "Horizon", "Kingdom", "Land", "Lands", "Netherworld", "Outlands", "Outskirts", "Paradise", "Partition", "Periphery", "Place", "Plane", "Province", "Quarter", "Realm", "Region", "Rim", "Sanctuary", "Sector", "Sphere", "Territory", "Turf", "Universe", "Void", "Wilds", "World", "Zone")
#macro MENU_WORLD_NAME_STORY choose("Chronicle", "Epilogue", "Fable", "History", "Legend", "Myth", "Narrative", "Report", "Saga", "Spiel", "Story", "Tale")

#endregion

#macro ATTIRE_ELEMENTS_LENGTH 9
#macro ATTIRE_ELEMENTS_ORDERED_LENGTH 16

#macro ATTRIBUTE_DEFAULT_BUILD_REACH (TILE_SIZE * 6)
#macro ATTRIBUTE_DEFAULT_HARVEST_REACH (TILE_SIZE * 8)