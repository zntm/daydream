#define CHUNK_SIZE 16
#define CHUNK_DEPTH 8

attribute vec3 in_Position;
// attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

attribute vec2 in_TextureData;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_time;
uniform float u_texel_width;
uniform float u_skew[CHUNK_SIZE * CHUNK_SIZE];
uniform float u_wave[CHUNK_SIZE * CHUNK_SIZE];

const vec4 COLOUR_ALPHA = vec4(1.0, 1.0, 1.0, 1.0);

void main()
{
    v_vColour = COLOUR_ALPHA;
    v_vTexcoord = in_TextureCoord;
    
    // in_TextureData.x = packed animation data (number << 24 | chunk_index << 16 | animation_type)
    // in_TextureData.y = packed index and width (index * 256.0 + width)
    
    float animation_type = mod(in_TextureData.x, 256.0);
    
    // Unpack index and width from in_TextureData.y
    float packed_index_width = in_TextureData.y;
    float sprite_width = mod(packed_index_width, 256.0);
    float frame_index = floor(packed_index_width / 256.0);
    
    // Calculate UV offset in shader: width * texel_width
    float uv_offset = sprite_width * u_texel_width;
    
    // Default (animation_type 0, 1, 2)
    if (animation_type <= 2.0)
    {
        v_vTexcoord.x += frame_index * uv_offset;
        
        gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position.x, in_Position.y, 0.0, 1.0);
    }
    // Increment (animation_type 3)
    else if (animation_type < 4.0)
    {
        float number = mod(floor(in_TextureData.x / 16777216.0), 256.0);
        
        v_vTexcoord.x += frame_index * uv_offset * mod(u_time, max(number - 1.0, 1.0));
        
        gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position.x, in_Position.y, 0.0, 1.0);
    }
    // Foliage (animation_type 4)
    else if (animation_type < 5.0)
    {
        int skew_index = int(mod(floor(in_TextureData.x / 65536.0), 256.0));
        
        v_vTexcoord.x += frame_index * uv_offset;
        
        gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position.x + u_skew[skew_index], in_Position.y, 0.0, 1.0);
    }
    // Wave (animation_type 5) - liquid bobbing with time-based sine + force array
    else
    {
        int wave_index = int(mod(floor(in_TextureData.x / 65536.0), 256.0));
        
        // Time-based sine wave for gentle bobbing effect
        float base_bob = sin(u_time * 2.0 + in_Position.x * 0.3) * 0.8;
        
        // Add force from array (for splash effects)
        float force_bob = u_wave[wave_index];
        
        v_vTexcoord.x += frame_index * uv_offset;
        
        gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position.x, in_Position.y + base_bob + force_bob, 0.0, 1.0);
    }
}