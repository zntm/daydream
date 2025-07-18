//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec2 base = texture2D(gm_BaseTexture, v_vTexcoord).ra;
    
    gl_FragColor = v_vColour * vec4(base.x, base.x, base.x, base.y);
}
