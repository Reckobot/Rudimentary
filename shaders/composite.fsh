#version 330 compatibility
#include "/lib/uniforms.glsl"
#include "/lib/tonemap.glsl"
#include "/lib/common.glsl"

uniform sampler2D depthtex0;
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex5;
uniform sampler2D colortex6;
uniform sampler2D colortex7;

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
    vec4 homPos = projectionMatrix * vec4(position, 1.0);
    return homPos.xyz / homPos.w;
}

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	vec3 lightVector = normalize(shadowLightPosition);
	vec3 worldLightVector = mat3(gbufferModelViewInverse) * lightVector;

	vec2 lightmap = texture(colortex1, texcoord).rg;
	vec3 encodedNormal = texture(colortex2, texcoord).rgb;
	vec3 normal = normalize((encodedNormal - 0.5) * 2.0);
	float NoL = dot(normal, worldLightVector);

	float depth = texture(depthtex0, texcoord).r;

	vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
	vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;

	float dist = length(viewPos) / (far*0.7);
	float fogFactor = exp(-4 * (1.0 - dist));

	color = texture(colortex0, texcoord);
	if (texture(colortex7, texcoord) == vec4(0)){
		if (depth >= 1.0){
			color.rgb = mix(color.rgb, texture(colortex5, texcoord).rgb*clamp(1-(playerMood*16), 0.0, 1.0), clamp(fogFactor, 0.0, 1.0));
		}else{
			color.rgb *= mix(vec3(1.0), vec3(1.5, 1.25, 1.0), NoL);
			color.rgb = mix(color.rgb, texture(colortex6, texcoord).rgb*clamp(1-(playerMood*16), 0.0, 1.0), clamp(fogFactor, 0.0, 1.0));
		}
	}

	if (isEyeInWater == 1){
		color.rgb *= BSC(vec3(0,0.5,1.25), 1.0, 0.45, 1.0);
	}
}