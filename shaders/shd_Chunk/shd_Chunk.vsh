#define CHUNK_SIZE 16
#define CHUNK_DEPTH 8

attribute vec3 in_Position;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

attribute vec4 in_TextureFrameData;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_textureSize;

uniform float u_time;
uniform float u_skew[CHUNK_SIZE * CHUNK_SIZE * CHUNK_DEPTH];

void main()
{
    v_vColour = in_Colour;
    
    if (in_TextureFrameData.w == 1.0)
    {
        v_vTexcoord = vec2(
            in_TextureCoord.x + (in_TextureFrameData.z * u_textureSize.x * in_TextureFrameData.x),
            in_TextureCoord.y
        );
        
        gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position.x, in_Position.y, 0.0, 1.0);
    }
    else if (in_TextureFrameData.w == 2.0)
    {
        v_vTexcoord = vec2(
            in_TextureCoord.x + (in_TextureFrameData.z * u_textureSize.x * mod(u_time, in_TextureFrameData.y - 1.0)),
            in_TextureCoord.y
        );
        
        gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position.x, in_Position.y, 0.0, 1.0);
    }
    else if (in_TextureFrameData.w == 3.0)
    {
        v_vTexcoord = in_TextureCoord;
        
        gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position.x + u_skew[int(in_TextureFrameData.z)], in_Position.y, 0.0, 1.0);
    }
    else
    {
        v_vTexcoord = in_TextureCoord;
        
        gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position.x, in_Position.y, 0.0, 1.0);
    }
}