#version 430

layout(rgba32f, binding = 0) writeonly uniform image2D outTex;
layout(binding = 1) uniform sampler2D inTex; // Shoudld've been an image2d but didn't work for some reason

layout(local_size_x = 16, local_size_y = 16) in;

void main()
{
	ivec2 storePos = ivec2(gl_GlobalInvocationID.xy);

	// Convert to texture coordinates
	vec2 storePosFloat = vec2(storePos);
	storePosFloat.x /= 1024;
	storePosFloat.y /= 768;
	vec4 color = texture(inTex,storePosFloat);
	imageStore(outTex, storePos, color);
}

