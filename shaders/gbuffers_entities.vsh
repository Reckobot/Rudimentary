#version 330 compatibility
#include "/lib/settings.glsl"
#include "/lib/uniforms.glsl"
#include "/lib/buffers.glsl"

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;
in vec4 at_tangent;
out mat3 tbnmatrix;

void main() {
	vec4 position = vec4(gl_Vertex);
	vec4 refposition = vec4(gl_Vertex)/1.1;
	vec3 viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
	float dist = SNAP_THRESHOLD/2;

	for (int i = 0; i < 4; i++){
		bool roundDown;

		if (int(refposition[i]) == floor(refposition[i])){
			roundDown = true;
		}else{
			roundDown = false;
		}

		vec3 random = texture(noisetex, position.xz).xyz;
		if (roundDown){
			float diff = abs(refposition[i] - floor(refposition[i]));
			if(diff < dist){
				position[i] = mix(position[i], floor(position[i]), diff/1);
				position.xyz += random/64*WARPING_INTENSITY;
			}
		}else{
			float diff = abs(refposition[i] - ceil(refposition[i]));
			if(diff < dist){
				position[i] = mix(position[i], ceil(position[i]), diff/1);
				position.xyz += random/64*WARPING_INTENSITY;
			}
		}
	}

	gl_Position = gl_ModelViewProjectionMatrix * position;
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	normal = gl_NormalMatrix * gl_Normal;

	vec3 tangent = mat3(gbufferModelViewInverse) * normalize(gl_NormalMatrix * at_tangent.xyz);
	vec3 bitangent = mat3(gbufferModelViewInverse) * normalize(cross(tangent, normal) * at_tangent.w);
	normal = mat3(gbufferModelViewInverse) * normal;
	tbnmatrix = mat3(tangent, bitangent, normal);
}