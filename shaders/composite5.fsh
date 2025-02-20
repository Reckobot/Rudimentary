#version 330 compatibility
#include "/lib/common.glsl"
#include "/lib/settings.glsl"

uniform sampler2D colortex0;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

float limitDepth(float og, int depth){
	float factor = (depth);
	return float(int(og*factor)/factor);
}

void main() {
	color = texelFetch(colortex0, ivec2(texcoord * vec2(viewWidth, viewHeight)), 0);

	float threshold = 1.0;
	ivec2 pixelpos = ivec2(texcoord * vec2(viewWidth, viewHeight));
	if (mod(pixelpos.y, 2.0) == 0){
		if (mod(pixelpos.x, 2.0) == 0){
			threshold = 0.125;
		}else{
			threshold = 0.5;
		}
	}else{
		if (mod(pixelpos.x, 2.0) == 0){
			threshold = 1.0;
		}else{
			threshold = 0.25;
		}
	}

	#ifdef DITHERING
		int radius = 2;
		float luminance = getLuminance(color.rgb);
		for (int x = -radius; x <= radius; x++){
			for (int y = -radius; y <= radius; y++){
				vec3 currentpixel = texelFetch(colortex0, pixelpos+ivec2(x,y), 0).rgb;
				if (bool(lessThan(abs(currentpixel - color.rgb), vec3(0.001)))){
					color.rgb = mix(currentpixel, color.rgb*clamp(threshold*2, 0.0, 1.0), threshold);
				}
			}
		}
	#endif

	#ifdef CRT
		color.rgb *= clamp(threshold*3+0.125, 0.0, 1.1);
	#endif

	#ifdef CRT_SCANLINES
		for (int i = 0; i < 2048; i++){
			if (pixelpos.y == int(fract(frameTimeCounter)*16*SCANLINE_SPEED)-(i*SCANLINE_GAP)+(viewHeight)){
				color.rgb *= 0.5;
			}
		}
	#endif

	color.rgb = BSC(color.rgb, BRIGHTNESS, SATURATION, CONTRAST);

	color.r = limitDepth(color.r, COLOR_DEPTH);
	color.g = limitDepth(color.g, COLOR_DEPTH);
	color.b = limitDepth(color.b, COLOR_DEPTH);
}