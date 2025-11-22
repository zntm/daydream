#define CHUNK_SIZE 16
#define CHUNK_DEPTH 8

attribute vec3 in_Position;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

attribute vec4 in_TextureData;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_texture_size;

uniform float u_time;
uniform float u_skew[CHUNK_SIZE * CHUNK_SIZE];

void main()
{
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
    
    float animation_type = mod(in_TextureData.x, 256.0);
    
    // Default
    // if (animation_type == 0.0 || animation_type == 1.0 || animation_type == 2.0)
    if (animation_type <= 2.0)
    {
        v_vTexcoord.x += in_TextureData.y * in_TextureData.z;
        
        gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position.x, in_Position.y, 0.0, 1.0);
    }
    // Increment
    else if (animation_type == 3.0)
    {
        float number = mod(floor(in_TextureData.x / 256.0), 256.0);
        
        v_vTexcoord.x += in_TextureData.y * in_TextureData.z * mod(u_time, number - 1.0);
        
        gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position.x, in_Position.y, 0.0, 1.0);
    }
    // Foliage
    else if (animation_type == 4.0)
    {
        int skew_index = int(mod(floor(in_TextureData.x / 65536.0), 256.0));
        
        v_vTexcoord.x += in_TextureData.y * in_TextureData.z;
        
        gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position.x + u_skew[skew_index], in_Position.y, 0.0, 1.0);
    }
}