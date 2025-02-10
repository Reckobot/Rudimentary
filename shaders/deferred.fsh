#version 330 compatibility
#include "/lib/common.glsl"
#include "/lib/settings.glsl"

uniform sampler2D depthtex0;
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	color = texture(colortex0, texcoord);

	vec3 encodedNormal = texture(colortex2, texcoord).rgb;
	vec3 normal = normalize((encodedNormal - 0.5) * 2.0);

	vec3 lightVector = normalize(shadowLightPosition);
	vec3 worldLightVector = mat3(gbufferModelViewInverse) * lightVector;

	float depth = texture(depthtex0, texcoord).r;

	if ((depth < 1)&&(texture(colortex3, texcoord) == vec4(0))){
		float mult = 1.0;
		mult *= encodedNormal.r;
		mult *= 1-encodedNormal.r;
		mult *= dot(encodedNormal.rgb, vec3(0,1,0));

		mult = clamp(mult*4+0.25, 0.0, 1.0);
		color.rgb *= mix(ambientColor, sunColor, mult);
		color.rgb *= texture(colortex1, texcoord).rgb;
	}
}