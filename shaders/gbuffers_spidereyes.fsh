#version 330 compatibility
#include "/lib/common.glsl"
#include "/lib/settings.glsl"

uniform sampler2D lightmap;
uniform sampler2D gtexture;
in vec3 normal;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;

/* RENDERTARGETS: 0,10 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 emissive;

void main() {
	color = texture(gtexture, texcoord) * glcolor;
	emissive = color;
}