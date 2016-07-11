#version 430

uniform vec3 cameraPosition;
uniform vec3 cameraDirection;

//our frustum rays
uniform vec3 ray00;
uniform vec3 ray10;
uniform vec3 ray11;
uniform vec3 ray01;

layout(binding=0,rgba8) uniform image2D destTex;
layout (local_size_x = 16, local_size_y = 16) in;

// Hardcoded up-vector. used to figure out specific ups
vec3 cameraUp = vec3(0,1,0);

vec3 RayDirection()
{
	float width = 1024;
	float height = 768;
	float normalized_i = (gl_GlobalInvocationID.x / width) - 0.5;
	float normalized_j = (gl_GlobalInvocationID.y / height) - 0.5;

	vec3 cameraRight = cross(cameraDirection, cameraUp);
	cameraUp = cross(cameraRight, cameraDirection);

	vec3 imagePoint = normalized_i * cameraRight +
						normalized_j * cameraUp + 
						cameraPosition + cameraDirection;

	return imagePoint - cameraPosition;
}


void main()
{
	vec3 position = vec3((gl_GlobalInvocationID.xy), 0);

	vec3 direction = RayDirection();

	ivec2 storePos = ivec2(gl_GlobalInvocationID.xy);
	
	// vec4 color = vec4(direction.x,0,0, 1);
	// vec4 color = vec4(0 ,0 ,direction.z, 1);
	vec4 color = vec4(0 ,direction.y , 0 , 1);
	imageStore(destTex, storePos, color);
}






//struct box 
//{
//  vec3 min;
//  vec3 max;
//};
//
//#define NUM_BOXES 2
//const box boxes[] = 
//{
//  /* The ground */
//  {vec3(-5.0, -0.1, -5.0), vec3(5.0, 0.0, 5.0)},
//  /* Box in the middle */
//  {vec3(-0.5, 0.0, -0.5), vec3(0.5, 1.0, 0.5)}
//};
//
//float RayVsSphere(vec3 ray, vec3 pos, vec4 sphere)
//{
//	float t1;
//	float t2;
//	float b = dot(ray, pos-sphere.xyz);
//	float c = dot(pos - sphere.xyz, pos - sphere.xyz) - pow(sphere.w, 2);
//
//	bool hit = false;
//	float f = pow(b, 2) - c;
//
//	if(f >=0)
//		hit = true;
//	
//	if(hit)
//	{
//		return 1;
//	}
//	return 0;
//
//}
//
//






















//vec2 intersectBox(vec3 origin, vec3 dir, const box b) 
//{
//  vec3 tMin = (b.min - origin) / dir;
//  vec3 tMax = (b.max - origin) / dir;
//  vec3 t1 = min(tMin, tMax);
//  vec3 t2 = max(tMin, tMax);
//  float tNear = max(max(t1.x, t1.y), t1.z);
//  float tFar = min(min(t2.x, t2.y), t2.z);
//  return vec2(tNear, tFar);
//}
//
//float RayIntersectSphere(vec3 ray, vec3 dir, vec3 center, float radius)
//{
//	vec3 rc = ray-center;
//	float c = dot(rc, rc) - (radius*radius);
//	float b = dot(dir, rc);
//	float d = b*b - c;
//	float t = -b - sqrt(abs(d));
//
//	//float st = step(0.0, min(t,d));
//	//return mix(-1.0, t, st);
//	
//	if (d < 0.0 || t < 0.0) 
//	{
//		return 1; // Didn't hit, or wasn't the closest hit
//	}
//	 
//	else 
//	{
//		return t;
//	}
//}
//
////float RayVsSphere(vec3 ray, vec3 pos, vec4 sphere)
//{
//	float t1;
//	float t2;
//	float b = dot(ray, pos-sphere.xyz);
//	float c = dot(pos - sphere.xyz, pos - sphere.xyz) - pow(sphere.w, 2);
//
//	bool hit = false;
//	float f = pow(b, 2) - c;
//
//	if(f >=0)
//		hit = true;
//	
//	if(hit)
//	{
//		return 1;
//	}
//	return 0;
//
//
//	//float t1;
//	//float t2;
//	//float b = ray.d.Dot(ray.o - sphere.c);
//	//float c = (ray.o - sphere.c).Dot(ray.o - sphere.c) - powf(sphere.r, 2.0f);
//	//bool hit;
//	//float f = powf(b, 2.0f) - c;
//	//hit = f >= 0.0f? true:false;
//	//
//	//if(hit)
//	//{
//	//	
//	//	t1 = -b - sqrtf(f);
//	//	t2 = -b + sqrtf(f);
//	//	if(t1 < hitData.t || hitData.t < 0.0f)
//	//	{
//	//		hitData.t = t1;
//	//		hitData.color = sphere.color;
//	//	}
//	//}
//	//
//	//return hit;
//}

