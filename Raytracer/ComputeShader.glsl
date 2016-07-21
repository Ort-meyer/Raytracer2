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

//Lights
uniform vec3[50] lightPositions;
uniform int numLights;

//Diffuse lights
uniform vec3[50] diffuseLightingDirections;
uniform int numDiffuseLights;
//Spheres
uniform vec3[5] spherePositions; // Maximum of of 5 spheres
uniform float[5] sphereRadii;
uniform vec3 [5] sphereColors;
uniform int numSpheres;

//Triangles
uniform vec3[3*40] trianglePositions; // 3 corners times maximum of 10 triangles
uniform vec3[40] triangleColors;
uniform int numTrianglePositions;


// Hardcoded up-vector. used to figure out specific ups
vec3 cameraUp = vec3(0,1,0);


struct Ray
{
	vec3 dir;
	vec3 pos;
	bool DEBUG;
};

struct Hitdata
{
	float t1;
	float t2;
	bool hit;
	float hitDistance;
	vec3 normal;
	vec3 position;
	bool hitTriangle; // debuggy
	int hitIndex; // debuggy
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
	if(hitdata.t1 > 0 && hitdata.t2 > 0) // Does not work if we're inside a sphere
	{	
		hitdata.hitDistance = hitdata.t1;
		if(hitdata.t1 > hitdata.t2)
			hitdata.hitDistance = hitdata.t2;

		// Calculate position and normal
		hitdata.position = rayPos + rayDir * hitdata.hitDistance;
		hitdata.normal = normalize(hitdata.position - spherePos);
	}
	else
		hitdata.hit = false;

	return hitdata;
}
// taken from http://stackoverflow.com/questions/13655457/raytracing-ray-triangle-intersection
Hitdata RayPwnTriangle(Ray ray, vec3 p0, vec3 p1, vec3 p2, Hitdata hitdata)
{
	vec3 e1 = p1 - p0;
	vec3 e2 = p2 - p0;
	vec3 e1e2 = cross(e1, e2);
	vec3 p = cross(ray.dir, e2);
	e1e2 = normalize(e1e2);
	float a = dot(e1, p);
	if(a < 0.000001)
	{
		return hitdata;
	}

	float f = 1 / a;
	vec3 s = ray.pos - p0;
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
	if(hitdata.hitDistance > 0)
		hitdata.hit = true;
	return hitdata;
}

// Big method that iterates through each geometry and returns hit data for the object we hit
Hitdata ComputeHit(Ray ray, Hitdata p_hitdata, bool shadow)
{
	Hitdata hitdata;
	hitdata.hit = false;
	hitdata.hitDistance = 100000;

	// Iterate through all spheres
	for(int i = 0; i < numSpheres ; i++)
	{
		//if(!shadow || (shadow && p_hitdata.hitIndex != i))// && !p_hitdata.hitTriangle)) // This is ugly...
		{
	
			Hitdata t_hitdata = RayPwnSphere(ray.pos, ray.dir, spherePositions[i], sphereRadii[i]);
			if(t_hitdata.hit && hitdata.hitDistance > t_hitdata.hitDistance)
			{
				hitdata = t_hitdata;
				hitdata.hitTriangle = false;
				hitdata.hitIndex = i;
			}
		}
	}

	// Iterate through all triangles
	for(int i = 0; i < numTrianglePositions; i+=3)
	{
		//if(!shadow || (shadow && p_hitdata.hitIndex != i && p_hitdata.hitTriangle))
		{
			Hitdata t_hitdata;
			t_hitdata = RayPwnTriangle(ray, trianglePositions[i], trianglePositions[i+1], trianglePositions[i+2], t_hitdata);
			if(t_hitdata.hit && hitdata.hitDistance > t_hitdata.hitDistance)
			{
				if(!(shadow && i < 36))
				{
					hitdata = t_hitdata;
					hitdata.hitTriangle = true;
					hitdata.hitIndex = i / 3;
				}
			}
		}
	}

	return hitdata;
}

float CalculateLightStrength(vec3 vertexToEye, vec3 lightDirection, vec3 hitNormal)
{
	float diffuseIntensity = 1;
	float specularPower = 2;
	float matSpecularIntensity = 0;
	
	// Simple diffuse calculation
	float diffuseFactor = dot(hitNormal, -lightDirection) * diffuseIntensity;
	// 
	float specularFactor = 0.0f;
	if(diffuseFactor > 0)
	{
		vec3 lightReflect = normalize(reflect(lightDirection, hitNormal));
		specularFactor = dot(vertexToEye, lightReflect);
		if(specularFactor > 0)
		{
			specularFactor = matSpecularIntensity * pow(specularFactor, specularPower);
		}
	}
	//return clamp(specularFactor + diffuseFactor, 0.1, 1.0f);
	return diffuseFactor + clamp(specularFactor, 0.1, 1.0f);

}

float CalculatePointLightLightingOnly(Hitdata hitdata, Ray ray)
{
	float lightFactorColor = 0.1; // some ambient
	for(int i = 0; i < numLights; i++)
	{
		// vector between light and where the ray hit an object
		vec3 hitLightVector = lightPositions[i] - hitdata.position;
		// "Angle" between hitLightVector and normal of hit
		float normalLightDot = dot(hitdata.normal, hitLightVector);
		
		// Check if hit is on the "right side" of the light
		if(true)//normalLightDot > 0)
		{
			float inverseLightStrength = 0.145;
			float currentLightColorFactor = normalLightDot;
			currentLightColorFactor *= 1 - length(hitLightVector) * inverseLightStrength; // This is for light cutoff 
			lightFactorColor += clamp(currentLightColorFactor, 0, 1);
		}
	}
	for(int i = 0; i<numDiffuseLights; i++)
	{
		//// Add them to total light
		//
		//float diffuseIntensity = 0.6;
		//float specularPower = 4;
		//float matSpecularIntensity = 0.4;
		//
		//float specularValue = 0;
		//// First calculate diffuse value
		//float diffuseValue = dot(diffuseLightingDirections[i],hitdata.normal);
		//if(diffuseValue > 0)
		//{
		//	diffuseValue *= diffuseIntensity;
		//
		//	// Now calculate specular lighting
		//	vec3 toEye = normalize(hitdata.position - ray.pos);
		//	vec3 lightReflect = normalize(reflect(diffuseLightingDirections[i], hitdata.normal));
		//
		//	specularValue = dot(toEye, lightReflect);
		//	if(specularValue > 0 )
		//	{
		//		specularValue = matSpecularIntensity * pow(specularValue, specularPower);
		//	}
		//}
		//lightFactorColor += diffuseValue + clamp(specularValue, 0, 1);
	
		lightFactorColor += CalculateLightStrength(normalize(hitdata.position - ray.pos), diffuseLightingDirections[i], hitdata.normal);
	
	
		// Alla diffuselights är starka
		//lightFactorColor += dot( diffuseLightingDirections[i],hitdata.normal);
	}
	// Ensure there's always ambience
	lightFactorColor = clamp(lightFactorColor, 0.1f, 1.0f);
	return lightFactorColor;
}
float CalculatePointLightShadowOnly(Hitdata hitdata, Ray ray)
{

	float lightFactorColor = 1;
	for(int i = 0; i < numLights; i++)
	{
		// vector between light and where the ray hit an object
		vec3 hitLightVector = lightPositions[i] - hitdata.position;
		// "Angle" between hitLightVector and normal of hit
		float normalLightDot = dot(hitdata.normal, hitLightVector);
		if(normalLightDot > 0)
		{
			// First, see if there's anything in the way.
			Ray shadowRay;
			shadowRay.dir = normalize(hitLightVector);
			shadowRay.pos = hitdata.position;
			Hitdata shadowHitdata = ComputeHit(shadowRay, hitdata, true);
			// Hitdata och hitdistance går inte alltid att lita på.
			if(shadowHitdata.hit && length(shadowHitdata.position - shadowRay.pos) <= length(hitLightVector))
			{
				lightFactorColor *= 0.5; // How shadowy shadows become
				
			}
		}
	}
	for(int i = 0; i<numDiffuseLights; i++)
	{
		if(dot(hitdata.normal, diffuseLightingDirections[i]) > 0)
		{
			Ray shadowRay;
			shadowRay.dir = diffuseLightingDirections[i];
			shadowRay.pos = hitdata.position;
			Hitdata shadowHitdata = ComputeHit(shadowRay, hitdata, true);
			if(shadowHitdata.hit)
			{
				lightFactorColor *= 0.5; // How shadowy shadows become
			}
		}

	}
	return lightFactorColor;
}

// Calculates light value of pixel
// Light computation from http://gamedev.stackexchange.com/questions/56897/glsl-light-attenuation-color-and-intensity-formula
float CalculatePointLightLighting(Hitdata hitdata, Ray ray)
{
	float lightFactorColor = 0.1; // some ambient
	for(int i = 0; i < numLights; i++)
	{
		// vector between light and where the ray hit an object
		vec3 hitLightVector = lightPositions[i] - hitdata.position;
		// "Angle" between hitLightVector and normal of hit
		float normalLightDot = dot(hitdata.normal, hitLightVector);
		
		// Check if hit is on the "right side" of the light
		if(normalLightDot > 0)
		{		
			// First, see if there's anything in the way.
			Ray shadowRay;
			shadowRay.dir = normalize(hitLightVector);
			shadowRay.pos = hitdata.position;
			Hitdata shadowHitdata = ComputeHit(shadowRay, hitdata, true);
			// Hitdata och hitdistance går inte alltid att lita på.
			if(shadowHitdata.hit && length(shadowHitdata.position - shadowRay.pos) <= length(hitLightVector))
			{
				lightFactorColor -= 0.7; // How shadowy shadows become
				
			}

			// There wasn't anything in the way
			else
			{
				if(false)
				{
					float cutoffDistance = 5;
					float lightDistance = length(hitLightVector);
					if(lightDistance < 1000)
					{
						float aFactor = 0.1;
						float bFactor = 0.01;
						float cFactor = 0.4;
						float attenuation = 1 / (1 + aFactor * lightDistance + bFactor * lightDistance * lightDistance);
						float dcont = max(0.0, normalLightDot);
						lightFactorColor += attenuation * (dcont+cFactor);
					}
				}


				else
				{
					float lightIntensity = clamp(normalLightDot, 0, 1);



					// Wasn't anything in the way. It's illuminated
					float currentLightColorFactor = normalLightDot;
					float inverseLightStrength = 0.15;
					currentLightColorFactor *= 1 - length(hitLightVector) * inverseLightStrength; // This is for light cutoff 
					lightFactorColor += clamp(currentLightColorFactor, 0, 1);
				}
			}
		}
		
	}
	// Ensure there's always ambience
	lightFactorColor = clamp(lightFactorColor, 0.4f, 1.0f);
	return lightFactorColor;
}




void main()
{
	// Get this pixels ray
	Ray ray = RayDirection();
	Hitdata derp;
	Hitdata hitdata = ComputeHit(ray, derp, false);

	// Calculate light based on hit
	float lightValue = 0;
	if(hitdata.hit)
	{
		//lightValue = CalculatePointLightLighting(hitdata, ray);
		lightValue = CalculatePointLightLightingOnly(hitdata, ray);
		lightValue *= CalculatePointLightShadowOnly(hitdata, ray);
	}

	// Store color
	vec4 color;
	if(!hitdata.hit)
	{
		color = vec4(0,lightValue,0,0);
	}
	else if(!hitdata.hitTriangle)
	{
		color = vec4(sphereColors[hitdata.hitIndex], 0) * lightValue;
	}
	else// if(hitdata.hitTriangle)
	{
		color = vec4(triangleColors[hitdata.hitIndex], 0) * lightValue;	
	}
	ivec2 storePos = ivec2(gl_GlobalInvocationID.xy);
	storePos.y = 768 - storePos.y;
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
