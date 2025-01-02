#version 330 compatibility
#include "/lib/settings.glsl"
#include "/lib/uniforms.glsl"
#include "/lib/tonemap.glsl"
#include "/lib/common.glsl"

uniform sampler2D depthtex0;
uniform sampler2D colortex0;
uniform sampler2D colortex1;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	vec2 coord = texcoord / RESOLUTION;
	color = texture(colortex0, coord);
	color.rgb = reinhard(color.rgb);
	color.rgb = BSC(color.rgb, 1.6, 1.0, 1.5);
}