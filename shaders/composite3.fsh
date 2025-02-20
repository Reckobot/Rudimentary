#version 330 compatibility
#include "/lib/common.glsl"
#include "/lib/settings.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex11;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	vec4 average = vec4(0);

	int radius = 8;
	int count = 0;
	for (int y = -radius; y <= radius; y++){
		average += texture(colortex11, texcoord+vec2(0, y/viewHeight));
		count++;
	}
	average /= count;

	#ifdef GODRAYS
		color.rgb = mix(texture(colortex0, texcoord).rgb, average.rgb, average.a);
	#else
		color.rgb = texture(colortex0, texcoord).rgb;
	#endif
}