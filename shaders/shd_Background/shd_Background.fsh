//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec3 u_colour;
uniform float u_strength;

void main()
{
    vec4 base = texture2D(gm_BaseTexture, v_vTexcoord);
    
    vec3 colour = mix(base.rgb, u_colour, (1.0 - v_vTexcoord.y) * u_strength);
    
    gl_FragColor = v_vColour * vec4(colour.rgb, base.a);
}
