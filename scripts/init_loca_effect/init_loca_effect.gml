function init_loca_effect()
{
	static __default = {
		outlineEnable: true,
		outlineDistance: 2,
		outlineColour: #151221
	}
    
	static __clear = {
		outlineEnable: true,
		outlineDistance: 2,
		outlineColour: #000000
	}
	
	font_enable_effects(global.loca_font, true, __default);
}