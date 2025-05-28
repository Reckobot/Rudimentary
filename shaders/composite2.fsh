#version 330 compatibility
#include "/lib/common.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex5;
uniform sampler2D colortex6;
uniform sampler2D depthtex0;

in vec2 texcoord;

/* RENDERTARGETS: 0,5 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 godrayBuffer;

void main() {
	//set color
	color = texture(colortex0, texcoord);

	//initialize depth
	float depth = texture(depthtex0, texcoord).r;

	//initialize depth for distant horizons
	if(depth >= 1.0) {
		#ifdef DISTANT_HORIZONS
			depth = texture(dhDepthTex0, texcoord).r;
		#endif
	}

	//blur the godray
	float godray = 0.0;
	int count = 1;
	int radius = 4;
	for(int x = -radius; x <= radius; x++) {
			float sampl = texture(colortex5, texcoord+vec2(x/viewWidth, 0.0)).r;
			godray += sampl;
			count++;
	}
	godray /= count;

	//write to buffer
	godrayBuffer = vec4(godray);
}