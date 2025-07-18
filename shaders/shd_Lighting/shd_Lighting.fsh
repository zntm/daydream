//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    float r = texture2D(gm_BaseTexture, v_vTexcoord).r;
    
    gl_FragColor = v_vColour * vec4(r, r, r, 1.0);
}
