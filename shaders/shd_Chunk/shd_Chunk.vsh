attribute vec3 in_Position;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;

// index, length, width, height
attribute vec4 in_TextureFrameData;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_textureSize;

uniform float u_time;

void main()
{
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position.x, in_Position.y, 0.0, 1.0);
    
    v_vColour = in_Colour;
    
    if (in_TextureFrameData.w == 1.0)
    {
        v_vTexcoord = vec2(
            in_TextureCoord.x + (in_TextureFrameData.z * u_textureSize.x * in_TextureFrameData.x),
            in_TextureCoord.y
        );
    }
    else if (in_TextureFrameData.w == 2.0)
    {
        v_vTexcoord = vec2(
            in_TextureCoord.x + (in_TextureFrameData.z * u_textureSize.x * mod(u_time, in_TextureFrameData.y - 1.0)),
            in_TextureCoord.y
        );
    }
    else
    {
        v_vTexcoord = in_TextureCoord;
    }
}