#version 330 compatibility
#include "/lib/common.glsl"

uniform sampler2D colortex0;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	color = texelFetch(colortex0, ivec2(texcoord * vec2(viewWidth, viewHeight)), 0);
}