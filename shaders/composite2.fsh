#version 330 compatibility
#include "/lib/common.glsl"
#include "/lib/settings.glsl"

uniform sampler2D colortex11;

in vec2 texcoord;

/* RENDERTARGETS: 11 */
layout(location = 0) out vec4 color;

void main() {
	vec4 average = vec4(0);

	int radius = 8;
	int count = 0;
	for (int x = -radius; x <= radius; x++){
		average += texture(colortex11, texcoord+vec2(x/viewWidth, 0));
		count++;
	}
	average /= count;

	color = average;
}