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
    
    float animation_type = mod(in_TextureData.w, 256.0);
    
    // Default
    // if (animation_type == 0.0 || animation_type == 1.0 || animation_type == 2.0)
    if (animation_type <= 2.0)
    {
        v_vTexcoord = vec2(
            in_TextureCoord.x + (in_TextureData.z * u_texture_size.x * in_TextureData.x),
            in_TextureCoord.y
        );
        
        gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position.x, in_Position.y, 0.0, 1.0);
    }
    // Increment
    else if (animation_type == 3.0)
    {
        v_vTexcoord = vec2(
            in_TextureCoord.x + (in_TextureData.z * u_texture_size.x * mod(u_time, in_TextureData.y - 1.0)),
            in_TextureCoord.y
        );
        
        gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position.x, in_Position.y, 0.0, 1.0);
    }
    // Foliage
    else if (animation_type == 4.0)
    {
        v_vTexcoord = vec2(
            in_TextureCoord.x + (floor(in_TextureData.w / 256.0) * u_texture_size.x * in_TextureData.x),
            in_TextureCoord.y
        );
        
        gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position.x + u_skew[int(in_TextureData.z)], in_Position.y, 0.0, 1.0);
    }
}