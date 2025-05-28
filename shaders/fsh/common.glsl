#version 330 compatibility
#include "/lib/common.glsl"

uniform sampler2D gtexture;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 normal;

flat in int isGrass;
flat in int isShadow;

/* RENDERTARGETS: 0,3,4,2,8,9,10 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 normalBuffer;
layout(location = 2) out vec4 lightBuffer;
layout(location = 3) out vec4 cloudBuffer;
layout(location = 4) out vec4 nonBlockBuffer;
layout(location = 5) out vec4 grassBuffer;
layout(location = 6) out vec4 particleBuffer;

void main() {
	if(!bool(isShadow)) {
		//initialize
		color = texture(gtexture, texcoord) * glcolor;
		if (color.a < 0.1) {
			discard;
		}

		//buffer writing
		vec3 finalNormal = normal * 0.5 + 0.5;
		lightBuffer = vec4(lmcoord, 0.0, 1.0);
		normalBuffer = vec4(finalNormal, 1.0);
		cloudBuffer = vec4(vec3(0.0), 1.0);
		nonBlockBuffer = vec4(1.0);
		grassBuffer = vec4(vec3(isGrass), 1.0);
		particleBuffer = vec4(vec3(0.0), 1.0);
	} else {
		color = texture(gtexture, texcoord) * glcolor;
		if (color.a < 0.1) {
			discard;
		}
		color.a *= 0.5;
	}
}