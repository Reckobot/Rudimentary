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
	coord *= vec2(viewWidth, viewHeight);
	color = texelFetch(colortex0, ivec2(coord), 0);
	if (logicalHeightLimit == 256){
		color.rgb = BSC(color.rgb, 0.5, 0.0, 0.75);
	}
	color.rgb = reinhard(color.rgb);
	color.rgb = BSC(color.rgb, BRIGHTNESS, SATURATION, CONTRAST);
}