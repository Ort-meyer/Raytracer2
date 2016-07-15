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

//Lights
uniform vec3 lightPos;


struct Ray
{
	vec3 dir;
	vec3 pos;
};

struct Hitdata
{
	float t1;
	float t2;
	bool hit;
	float hitDistance;
	vec3 normal;
	vec3 position;
	vec3 DEBUGcolor;
};

// Copy pasted from 3D lab 1
struct Triangle
{
	vec3 p0;
	vec3 p1;
	vec3 p2;
};

Ray RayDirection() // used to return vec3
{
	float width = 1024;
	float height = 768;
	float normalized_i = ((gl_GlobalInvocationID.x / width) - 0.5);
	float normalized_j = ((gl_GlobalInvocationID.y / height) - 0.5);

	vec3 cameraRight = cross(cameraUp, cameraDirection);
	cameraUp = cross(cameraRight, cameraDirection);

	vec3 imagePoint = normalized_i * cameraRight +
						normalized_j * cameraUp + 
						cameraPosition + cameraDirection;

	Ray retRay;
	retRay.dir = normalize(imagePoint - cameraPosition);
	retRay.pos = imagePoint;
	return retRay;
	//return imagePoint - cameraPosition;
}

// More or less copy pasted from 3D lab 1 
// Kommer inte kunna lösa problem om vi har två objekt efter varandra 
Hitdata RayPwnSphere(vec3 rayPos, vec3 rayDir, vec3 spherePos, float sphereRad)
{
	float b = dot(rayDir, rayPos - spherePos);
	float c = dot((rayPos - spherePos), (rayPos - spherePos)) - pow(sphereRad, 2.0f);
	// float c = 1 - pow(sphereRad, 2.0f); // Shortened. Should work

	float f = pow(b, 2.0f) - c;
	
	Hitdata hitdata;

	hitdata.hit = f >= 0.0f ? true : false;
	

	if(hitdata.hit)
	{
		hitdata.t1 = -b - sqrt(f);
		hitdata.t2 = -b + sqrt(f);
}

	return hitdata;
}
// taken from http://stackoverflow.com/questions/13655457/raytracing-ray-triangle-intersection
Hitdata RayPwnTriangle(Ray ray, Triangle triangle, Hitdata hitdata)
{
	vec3 e1 = triangle.p1 - triangle.p0;
	vec3 e2 = triangle.p2 - triangle.p0;
	vec3 e1e2 = cross(e1, e2);
	vec3 p = cross(ray.dir, e2);
	e1e2 = normalize(e1e2);
	float a = dot(e1, p);
	if(a < 0.000001)
	{
		return hitdata;
	}

	float f = 1 / a;
	vec3 s = ray.pos - triangle.p0;
	float u = f*(dot(s, p));
	if(u < 0.0 || u > 1.0)
	{
		return hitdata;
	}
	vec3 q = cross(s, e1);
	float v = f * dot(ray.dir, q);
	if(v < 0.0 || u+v > 1.0)
	{
		return hitdata;
		
	}


	float t = f * dot(e2, q);

	hitdata.hitDistance = t;
	hitdata.normal = e1e2;
	hitdata.position = ray.pos + ray.dir * t;
	hitdata.hit = true;
	return hitdata;
}


float CalculatePointLightLighting(Hitdata hitdata)
{
	vec3 pointLight = lightPos;
	vec3 lightFactor = pointLight - hitdata.position;

	//return dot(vec3(0,0,1), vec3(0,0,1));

	//return 0.5;
	return dot(normalize(hitdata.normal), normalize(lightFactor));
}


void main()
{

	vec4 sphere = vec4(0,0,2,0.2f);

	Ray ray = RayDirection();
	vec3 direction = ray.dir;
	ivec2 storePos = ivec2(gl_GlobalInvocationID.xy);

	//Hitdata hitdata = RayPwnSphere(ray.pos, ray.dir, vec3(0,0,2), 0.2f);

	Triangle triangle;
	//triangle.p0 = vec3(-0.4f, -0.4f, 2.0f);
	//triangle.p1 = vec3(0.0f,0.4f,2.0f);
	//triangle.p2 = vec3(0.4f, -0.4f, 2.0f);
	triangle.p0 = vec3(-0.4f, -0.4f, 1.0f) * 3;
	triangle.p1 = vec3(0.0f,0.4f,1.0f) * 3;
	triangle.p2 = vec3(0.4f, -0.4f, 1.0f) * 3;

	Hitdata hitdata;
	hitdata.hit = false;
	hitdata = RayPwnTriangle(ray, triangle, hitdata);

	float lightValue = 0;
	if(hitdata.hit)
	{
		lightValue = CalculatePointLightLighting(hitdata);
	}

	//vec4 color = vec4(hitdata.hit,0,0, 1);
	vec4 color = vec4(lightValue,0,0, 1);
	//vec4 color = vec4(hitdata.DEBUGcolor, 1);
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

//
//	







//float RayVsSphere(vec3 rayDir, vec3 rayStartPos, vec4 sphere)
//{
//	float t1;
//	float t2;
//	float b = dot(rayDir, rayStartPos-sphere.xyz);
//	float c = dot(rayStartPos - sphere.xyz, rayStartPos - sphere.xyz) - pow(sphere.w, 2);
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




//float Det(vec3 v1, vec3 v2, vec3 v3) //kanske inte funkar... 
//{
//	float det;
//	det = (v1.x*v2.y*v3.z + v1.y*v2.z*v3.x + v1.z*v2.x*v3.y)-(v1.z * v2.y * v3.x + v1.y*v2.x*v3.z + v1.x * v2.z * v3.y);
//	return det;
//}
//// Kommer inte kunna lösa problem om vi har två objekt efter varandra 
//Hitdata RayPwnTriangle(Ray ray, Triangle triangle)
//{
//	Hitdata hitData;
//	hitData.hitDistance = 100; //ta bort när den kan hantera flera penetrationer.
//	vec3 e1 = triangle.p1-triangle.p0;
//	vec3 e2 = triangle.p2-triangle.p0;
//	vec3 s = ray.pos-triangle.p0;
//	vec3 minusD = vec3(0,0,0)-ray.dir;
//	float t = 1/(Det(minusD, e1, e2))*Det(s,e1,e2);
//	float u = 1/(Det(minusD, e1, e2))*Det(minusD,s,e2);
//	float v= 1/(Det(minusD, e1, e2))*Det(minusD,e1,s);
//	float w = 1-u-v;
//	if((u<=1 && u>=0) && (v<=1 && v>=0) && (w<=1 && w>=0) && t<=hitData.hitDistance && t>0)
//	{
//		
//		hitData.hitDistance = t;
//	}
//
//	return hitData;
//}



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
//		return 0; // Didn't hit, or wasn't the closest hit
//	}
//	 
//	else 
//	{
//		return t;
//	}
//}







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
