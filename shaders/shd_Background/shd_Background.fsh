varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D u_textures[64];
uniform float u_texture_length;

uniform vec3 u_colour;
uniform float u_strength;

void main()
{
    vec4 base = texture2D(gm_BaseTexture, v_vTexcoord);
    
    vec3 colour = mix(base.rgb, u_colour, clamp((1.0 - v_vTexcoord.y) * u_strength, 0.0, 1.0));
    
    gl_FragColor = v_vColour * vec4(colour.rgb, base.a);
}
