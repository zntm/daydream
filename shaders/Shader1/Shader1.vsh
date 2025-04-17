//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
//attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_rotation;
uniform vec2  u_scale;
uniform vec2  u_translation;
uniform vec2  u_translation_offset;

void main()
{
    float c = cos(u_rotation);
    float s = sin(u_rotation);
    
    mat4 rotationMatrix = mat4(
         c,   s,   0.0, 0.0,
        -s,   c,   0.0, 0.0,
         0.0, 0.0, 1.0, 0.0,
         0.0, 0.0, 0.0, 1.0
    );
    
    mat4 scaleMatrix = mat4(
        u_scale.x, 0.0,       0.0, 0.0,
        0.0,       u_scale.y, 0.0, 0.0,
        0.0,       0.0,       1.0, 0.0,
        0.0,       0.0,       0.0, 1.0
    );
    
    vec4 rotatedOffset = rotationMatrix * vec4(u_translation_offset * u_scale, 0.0, 0.0);
    
    mat4 translateMatrix = mat4(
        1.0,                               0.0,                               0.0, 0.0,
        0.0,                               1.0,                               0.0, 0.0,
        0.0,                               0.0,                               1.0, 0.0,
        u_translation.x - rotatedOffset.x, u_translation.y - rotatedOffset.y, 1.0, 1.0
    );
    
    vec4 object_space_pos = vec4(in_Position.x, in_Position.y, in_Position.z, 1.0);
    
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * translateMatrix * rotationMatrix * scaleMatrix * object_space_pos;
    
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
}
