#version 330 compatibility
#include "/lib/common.glsl"

uniform sampler2D lightmap;
uniform sampler2D gtexture;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 normal;

flat in int isLeaves;
flat in int isGround;
flat in int isWater;

/* RENDERTARGETS: 0,3,4,2,8 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 normalBuffer;
layout(location = 2) out vec4 lightBuffer;
layout(location = 3) out vec4 cloudBuffer;
layout(location = 4) out vec4 nonBlockBuffer;

void main() {
	color = texture(gtexture, texcoord) * glcolor;
	lightBuffer = vec4(lmcoord, 0.0, 1.0);
	if (color.a < alphaTestRef) {
		discard;
	}
	vec3 finalNormal = normal * 0.5 + 0.5;

	vec3 lightVector = normalize(shadowLightPosition);
	vec3 worldLightVector = mat3(gbufferModelViewInverse) * lightVector;

	normalBuffer = vec4(finalNormal, 1.0);
	cloudBuffer = vec4(vec3(0.0), 1.0);
	nonBlockBuffer = vec4(1.0);

	#ifdef ALPHA_FOLIAGE
		if(!bool(isWater)) {
			if(bool(isLeaves)) {
				if(getLuminance(color.rgb) < 0.625) {
					color.rgb = (getLuminance(color.rgb)*2.825) * vec3( 0.4431, 0.6941, 0.2784);
				}
			} else {
				if(getLuminance(color.rgb) < 0.4) {
					color.rgb = (getLuminance(color.rgb)*2.125) * vec3( 0.4431, 0.6941, 0.2784);
				}
			}
		}
	#else
		if(!bool(isWater)) {
			if(bool(isLeaves)) {
				color.rgb *= 1.125;
			} else {
				color.rgb *= 0.975;
			}
		}
	#endif
}