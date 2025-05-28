#version 330 compatibility
#include "/lib/common.glsl"

uniform sampler2D lightmap;
uniform sampler2D gtexture;
uniform sampler2D depthtex1;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 normal;

/* RENDERTARGETS: 0,3,4,2,8 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 normalBuffer;
layout(location = 2) out vec4 lightBuffer;

void main() {
	float depth = texture(depthtex1, vec2(gl_FragCoord.xy)/vec2(viewWidth,viewHeight)).r;
	if (depth < 1.0){
		discard;
	}

	color = texture(gtexture, texcoord) * glcolor;
	lightBuffer = vec4(vec2(0.75, 1.0), 0.0, 1.0);
	if (color.a < alphaTestRef) {
		discard;
	}
	vec3 finalNormal = normal * 0.5 + 0.5;

	vec3 lightVector = normalize(shadowLightPosition);
	vec3 worldLightVector = mat3(gbufferModelViewInverse) * lightVector;

	normalBuffer = vec4(finalNormal, 1.0);
	color.rgb *= clamp(finalNormal.g*1.75, 0.75, 1.0);
}