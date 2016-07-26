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

//BTH logo buffer
layout (std430, binding = 2) buffer shader_data
{
	//vec3 bthCorners[16368];
	//float bthCorners[9];
	float bthCorners[16368*3];
};

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


Hitdata RayPwnSphere(vec3 rayPos, vec3 rayDir, vec3 spherePos, float sphereRad, Hitdata hitdata, int thisIndex)
{
	float b = dot(rayDir, rayPos - spherePos);
	float c = dot((rayPos - spherePos), (rayPos - spherePos)) - pow(sphereRad, 2.0f);
	// float c = 1 - pow(sphereRad, 2.0f); // Shortened. Should work

	float f = pow(b, 2.0f) - c;

	//hitdata.hit = f >= 0.0f ? true : false;
	if(f < 0.0f)
		return hitdata; // Was a miss
	

	hitdata.t1 = -b - sqrt(f);
	hitdata.t2 = -b + sqrt(f);

	if(hitdata.t1 < 0 || hitdata.t2 < 0)
	{
		return hitdata;
	}
	float t = min(hitdata.t1, hitdata.t2);
	if(t < hitdata.hitDistance) // New sphere is closer
	{
		hitdata.hitDistance = t;
		hitdata.position = rayPos + rayDir * hitdata.hitDistance;
		hitdata.normal = normalize(hitdata.position - spherePos);
		hitdata.hitTriangle = false;
		hitdata.hitIndex = thisIndex;
		hitdata.hit = true;
	}


	/*if(hitdata.t1 > 0 && hitdata.t2 > 0) // Does not work if we're inside a sphere
	{	
		hitdata.hitDistance = hitdata.t1;
		if(hitdata.t1 > hitdata.t2)
			hitdata.hitDistance = hitdata.t2;

		// Calculate position and normal
		hitdata.position = rayPos + rayDir * hitdata.hitDistance;
		hitdata.normal = normalize(hitdata.position - spherePos);
	}*/

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
		hitdata = RayPwnSphere(ray.pos, ray.dir, spherePositions[i], sphereRadii[i], hitdata, i);





		/*Hitdata t_hitdata = RayPwnSphere(ray.pos, ray.dir, spherePositions[i], sphereRadii[i]);
		if(t_hitdata.hit && hitdata.hitDistance > t_hitdata.hitDistance && hitdata.hitDistance > 0)
		{
			hitdata = t_hitdata;
			hitdata.hitTriangle = false;
			hitdata.hitIndex = i;
		}*/
	}

	// Iterate through all triangles
	/*for(int i = 0; i < numTrianglePositions; i+=3)
	{
		Hitdata t_hitdata;
		t_hitdata = RayPwnTriangle(ray, trianglePositions[i], trianglePositions[i+1], trianglePositions[i+2], t_hitdata);
		if(t_hitdata.hit && hitdata.hitDistance > t_hitdata.hitDistance && hitdata.hitDistance > 0)
		{
			if(!(shadow && i < 36))
			{
				hitdata = t_hitdata;
				hitdata.hitTriangle = true;
				hitdata.hitIndex = i / 3;
			}
		}
	}
	// Now iterate through all triangles in ssbo. Yup, this is smart
	for(int i = 0; i < 400; i+=9)
	{
		Hitdata t_hitdata;
		vec3 p0 = vec3(bthCorners[i], bthCorners[i+1], bthCorners[i+2]);
		vec3 p1 = vec3(bthCorners[i+3], bthCorners[i+4], bthCorners[i+5]);
		vec3 p2 = vec3(bthCorners[i+6], bthCorners[i+7], bthCorners[i+8]);
		t_hitdata = RayPwnTriangle(ray, p0,p1,p2, t_hitdata);
		if(t_hitdata.hit && hitdata.hitDistance > t_hitdata.hitDistance && hitdata.hitDistance > 0)
		{
			hitdata = t_hitdata;
			hitdata.hitTriangle = true;
			hitdata.hitIndex = i / 3;
		}
	}*/

	return hitdata;
}

float CalculateLightStrength(vec3 vertexToEye, vec3 lightDirection, vec3 hitNormal)
{
	float diffuseIntensity = 0.6;
	float specularPower = 4;
	float matSpecularIntensity = 0.4;
	
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
	//return diffuseFactor + specularFactor + 0.1;

}

float CalculatePointLightLightingOnly(Hitdata hitdata, Ray ray)
{
	float lightFactorColor = 0.1; // some ambient
	for(int i = 0; i < numLights; i++)
	{
		vec3 lightDirection =  hitdata.position - lightPositions[i];
		float distance = length(lightDirection);
		lightDirection = normalize(lightDirection);

		float lightValue = CalculateLightStrength(cameraPosition - hitdata.position, lightDirection, hitdata.normal);

		float constant = 0.1;
		float linear = 0.1;
		float exponant = 0.1;

		float attenuation = constant + linear * distance + exponant * distance * distance;

		lightFactorColor += lightValue / attenuation;

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
		lightFactorColor += CalculateLightStrength(normalize(cameraPosition - hitdata.position), diffuseLightingDirections[i], hitdata.normal);
	}
	// Ensure there's always ambience
	lightFactorColor = clamp(lightFactorColor, 0.4f, 1.0f);
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
		if(dot(hitdata.normal, - diffuseLightingDirections[i]) > 0)
		{
			Ray shadowRay;
			shadowRay.dir = - diffuseLightingDirections[i];
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





void main()
{
	// Get this pixels ray
	Ray ray = RayDirection();
	ray.dir = normalize(ray.dir);
	Hitdata derp;



	// Bounce new shit
	vec3 endColor = vec3(0,0,0);
	for(int i = 0; i < 2; i++)
	{
		float lightValue = 0;
		Hitdata hitdata = ComputeHit(ray, derp, false);
		if(hitdata.hit)
		{
			lightValue = 0.5;
			lightValue = CalculatePointLightLightingOnly(hitdata, ray);
			lightValue *= CalculatePointLightShadowOnly(hitdata, ray);
			if(hitdata.hitTriangle)
				endColor += triangleColors[0] * lightValue;
			else
				endColor += sphereColors[hitdata.hitIndex] * lightValue;
			// Change ray for bounce
			ray.pos = hitdata.position;
			ray.dir = normalize(reflect(normalize(ray.dir), normalize(hitdata.normal)));

		}
		else
			break;
	}

	ivec2 storePos = ivec2(gl_GlobalInvocationID.xy);
	storePos.y = 768 - storePos.y;
	
	//endColor = bthCorners[1];


	imageStore(destTex, storePos, vec4(endColor.xyz,0));
}


//// Calculates light value of pixel
//// Light computation from http://gamedev.stackexchange.com/questions/56897/glsl-light-attenuation-color-and-intensity-formula
//float CalculatePointLightLighting(Hitdata hitdata, Ray ray)
//{
//	float lightFactorColor = 0.1; // some ambient
//	for(int i = 0; i < numLights; i++)
//	{
//		// vector between light and where the ray hit an object
//		vec3 hitLightVector = lightPositions[i] - hitdata.position;
//		// "Angle" between hitLightVector and normal of hit
//		float normalLightDot = dot(hitdata.normal, hitLightVector);
//		
//		// Check if hit is on the "right side" of the light
//		if(normalLightDot > 0)
//		{		
//			// First, see if there's anything in the way.
//			Ray shadowRay;
//			shadowRay.dir = normalize(hitLightVector);
//			shadowRay.pos = hitdata.position;
//			Hitdata shadowHitdata = ComputeHit(shadowRay, hitdata, true);
//			// Hitdata och hitdistance går inte alltid att lita på.
//			if(shadowHitdata.hit && length(shadowHitdata.position - shadowRay.pos) <= length(hitLightVector))
//			{
//				lightFactorColor -= 0.7; // How shadowy shadows become
//				
//			}
//
//			// There wasn't anything in the way
//			else
//			{
//				if(false)
//				{
//					float cutoffDistance = 5;
//					float lightDistance = length(hitLightVector);
//					if(lightDistance < 1000)
//					{
//						float aFactor = 0.1;
//						float bFactor = 0.01;
//						float cFactor = 0.4;
//						float attenuation = 1 / (1 + aFactor * lightDistance + bFactor * lightDistance * lightDistance);
//						float dcont = max(0.0, normalLightDot);
//						lightFactorColor += attenuation * (dcont+cFactor);
//					}
//				}
//
//
//				else
//				{
//					float lightIntensity = clamp(normalLightDot, 0, 1);
//
//
//
//					// Wasn't anything in the way. It's illuminated
//					float currentLightColorFactor = normalLightDot;
//					float inverseLightStrength = 0.15;
//					currentLightColorFactor *= 1 - length(hitLightVector) * inverseLightStrength; // This is for light cutoff 
//					lightFactorColor += clamp(currentLightColorFactor, 0, 1);
//				}
//			}
//		}
//		
//	}
//	// Ensure there's always ambience
//	lightFactorColor = clamp(lightFactorColor, 0.4f, 1.0f);
//	return lightFactorColor;
//}