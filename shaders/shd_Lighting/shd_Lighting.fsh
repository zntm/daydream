//
// Lighting fragment shader — outputs full RGB color for multiplicative tinting
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec4 light = texture2D(gm_BaseTexture, v_vTexcoord);

    gl_FragColor = v_vColour * light;
}
