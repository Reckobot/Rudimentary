#version 330 compatibility
#include "/lib/common.glsl"

uniform sampler2D gtexture;

uniform float alphaTestRef = 0.1;

in vec2 texcoord;
in vec4 glcolor;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	color = texture(gtexture, texcoord) * glcolor;
	if (color.a < alphaTestRef) {
		discard;
	}
	#ifdef HORROR
		color.rgb = BSC(color.rgb, 1.0, 0.0, 1.0);
	#endif
}