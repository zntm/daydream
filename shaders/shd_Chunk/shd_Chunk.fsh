varying vec2 v_vTexcoord;
varying vec2 v_vTexcoord2;
varying vec4 v_vColour;
varying float v_vMixAmount;

void main()
{
    vec4 base_colour = texture2D(gm_BaseTexture, v_vTexcoord);
    vec4 blend_colour = texture2D(gm_BaseTexture, v_vTexcoord2);

    gl_FragColor = v_vColour * mix(base_colour, blend_colour, v_vMixAmount);
}
