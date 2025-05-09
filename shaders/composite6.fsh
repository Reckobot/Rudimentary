#version 330 compatibility
#include "/lib/common.glsl"
#include "/lib/settings.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex6;
uniform sampler2D colortex10;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

float limitDepth(float og, int depth){
	float factor = (depth);
	return float(int(og*factor)/factor);
}

void main() {
	vec2 coord = texcoord;
	#ifdef CRT_DISTORTION
		coord += (coord - vec2(0.5))*distance(texcoord.xy, vec2(0.5))*MARKIPLIER;
		coord /= 1.1;
		coord += 0.045;
		color = texture(colortex0, coord);
	#else
		color = texture(colortex0, coord);
	#endif
		#ifdef CRT_ASPECT
			if (clamp(coord, vec2(0.5-((viewHeight*1.33333)/viewWidth/2), 0), vec2(0.5+((viewHeight*1.33333)/viewWidth/2), 1)) != coord){
				color = vec4(0);
			}
		#else
			if (clamp(coord, 0, 1) != coord){
				color = vec4(0);
			}
		#endif

	#ifdef WATERMARK
		ivec2 c = ivec2(texcoord*vec2(viewWidth, viewHeight))/ivec2(WATERMARK_SCALE);
		c.y = int(viewHeight/(WATERMARK_SCALE+0.005)) - c.y;
		vec4 watermark = texelFetch(colortex6, c, 0);
		color.rgb = mix(color.rgb, watermark.rgb, watermark.a);
	#endif

	if (texture(colortex10, texcoord) != vec4((0))){
		color.rgb = texture(colortex10, texcoord).rgb;
	}
}