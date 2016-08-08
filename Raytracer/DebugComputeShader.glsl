#version 430

layout(rgba32f, binding = 0) writeonly uniform image2D outTex;
layout(rgba32f, binding = 1) readonly uniform image2D inTex;

layout(local_size_x = 16, local_size_y = 16) in;

void main()
{
	ivec2 storePos = ivec2(gl_GlobalInvocationID.xy);

	vec4 color = imageLoad(inTex, ivec2(1,1));
	//imageStore(outTex, storePos, vec4(1,0,0,0));
	imageStore(outTex, storePos, color);
}

