#version 330 compatibility
#include "/lib/common.glsl"

uniform sampler2D gtexture;
uniform sampler2D depthtex0;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 normal;

flat in int isGrass;

/* RENDERTARGETS: 0,3,4,2,8,9,10 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 normalBuffer;
layout(location = 2) out vec4 lightBuffer;
layout(location = 3) out vec4 cloudBuffer;
layout(location = 4) out vec4 nonBlockBuffer;
layout(location = 5) out vec4 grassBuffer;
layout(location = 6) out vec4 particleBuffer;

void main() {
	//initialize
	color = texture(gtexture, texcoord) * glcolor;
	if (color.a < alphaTestRef) {
		discard;
	}

	//buffer writing
	vec3 finalNormal = normal * 0.5 + 0.5;
	lightBuffer = vec4(lmcoord, 0.0, 1.0);
	normalBuffer = vec4(finalNormal, 1.0);
	cloudBuffer = vec4(vec3(0.0), 1.0);
	nonBlockBuffer = vec4(vec3(0.0), 1.0);
	particleBuffer = vec4(vec3(0.0), 1.0);
	grassBuffer = vec4(vec3(isGrass), 1.0);


	//depth test for distant horizons
	vec2 screenTexCoord = vec2(gl_FragCoord.xy)/vec2(viewWidth,viewHeight);

	float depth = texture(depthtex0, screenTexCoord).r;
	vec3 NDCPos = vec3(screenTexCoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);

	float dhdepth = texture(dhDepthTex0, screenTexCoord).r;
	vec3 dhNDCPos = vec3(screenTexCoord.xy, dhdepth) * 2.0 - 1.0;
	vec3 dhviewPos = projectAndDivide(dhProjectionInverse, dhNDCPos);

	if(((length(dhviewPos) < length(viewPos))&&(depth >= 1.0))&&(isEyeInWater != 1)&&(texture(dhDepthTex0, screenTexCoord).r != texture(dhDepthTex1, screenTexCoord).r)) {
		discard;
	}
}